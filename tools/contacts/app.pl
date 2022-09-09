use strict;
use warnings;

use Config::General;
use DATA::WhatsOn::Contact;
use DATA::WhatsOn::Organisation;
use DBI;
use Digest::MD5 qw(md5);
use Mail::Chimp3;

# -----------------
# Get configuration
# -----------------

my $cg = new Config::General(
  -ConfigFile => '/usr/local/etc/app.cfg',
  -IncludeRelative => 1,
  -UseApacheInclude => 1
);
my %conf = $cg->getall;

# -----------------------
# Connect to the database
# -----------------------

my $db = $conf{database};
my $dbh = DBI->connect("dbi:SQLite:dbname=$db", '', '');

# ---------------------------
# Create Mailchimp API object
# ---------------------------

my $mc = new Mail::Chimp3(api_key => $conf{mailchimp}{api_key});

# --------------------------------------
# Get Mailchmip members of the DATA list
# --------------------------------------

my $r = $mc->members(
  list_id => $conf{mailchimp}{list_id},
  count => 200
);
my @members = @{ $r->{content}->{members} };

# ---------------------------------------
# Get the contacts from the DATA database
# ---------------------------------------

my @contacts = DATA::WhatsOn::Contact->fetch($dbh);

# ----------------------------------------------------
# Get list of member society rowids and the DATA rowid
# ----------------------------------------------------

my @soc_ids = ();
my $data_id;
my @orgs = DATA::WhatsOn::Organisation->fetch($dbh);
foreach my $org ( @orgs ) {
  push @soc_ids, $org->rowid if $org->type eq 'whatson_society';
  $data_id = $org->rowid if $org->name eq 'DATA';
}

# NOTE: We do not exclude member societies that are no longer active

# ------------------------------------------------------------------
# Go through each contact reporting Mailchimp subscription omissions
# ------------------------------------------------------------------

foreach my $contact ( @contacts ) {
  if ( $contact->email ) {
    my $isMem = 0; # Is (or Was) an individual DATA member
    my $isRep = 0; # Is (or was) a representative of a member society
    my $orgs = ''; # Comma separate list of organisations the contact is in
    foreach my $contact_org ( @{ $contact->organisations } ) {
      my $org_id = $contact_org->organisation_rowid;
      my $org_name = $contact_org->name;
      $isMem = 1 if $org_id == $data_id;
      $isRep = 1 if grep(/^$org_id$/, @soc_ids);
      if ( $orgs ) {
        $orgs .= ",$org_name";
      } else {
        $orgs .= "$org_name";
      }
    }
    my $isSub = 0; # Is subscribed (to DATA mailing list)
    my $hasUnSub = 0; # Has actively unsubscribed
    my $isSubMem = 0; # Is subscribed and has ticked member news interest
    my $isSubRep = 0; # Is subscribed and has ticked guidance to reps interest
    foreach my $member ( @members ) {
      if ( lc($member->{email_address}) eq lc($contact->email) ) {
        #$r = $mc->add_member_note(
        #  list_id => $conf{mailchimp}{list_id},
        #  subscriber_hash = md5(lc($member->{email_address})),
        #  note = "Organisations = $orgs"
        #);
        # TODO: Test bounce status
        if ( $member->{status} eq 'subscribed' ) {
          #use Data::Dumper;
          #print Dumper $member->{interests};
          $isSub = 1;
          $isSubMem = 1 if
            $member->{interests}{$conf{mailchimp}{member_interest_id}};
          $isSubRep = 1 if
            $member->{interests}{$conf{mailchimp}{representative_interest_id}};
        } elsif ( $member->{status} eq 'unsubscribed' ) {
          $hasUnSub = 1;
        }
        last;
      }
    }
    if ($isMem || $isRep) {
      # We have a known contact who is either a DATA member or a representative
      # of a DATA member society. They should be subscribed with a registered
      # interest in member news.
      if ( $isSub && !$isSubMem) {
        # The contact is subscribed but hasn't registered an interest in member
        # news, so register it for them.
        print 'Register interest in member news for ', $contact->email, "\n";
#        $r = $mc->update_member(
#          list_id => $conf{mailchimp}{list_id},
#          subscriber_hash => md5(lc($contact->email))
#          count => 200
#        );
        } elsif ( !$isSub && !$hasUnSub ) {
        # The contact isn't subscribe and neither have they explicity
        # unsubscribed. Subscribe them along with an interest in member news.
        print 'Subscribe ', $contact->email, ' ', $contact->first_name, ' ', $contact->surname, "\n";
      }
    }
  }
}

1;

__END__
