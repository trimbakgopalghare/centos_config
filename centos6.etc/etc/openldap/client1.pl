 #!/usr/bin/perl
 require DBI;
 use Net::LDAP;
 use Digest::SHA1;
 use MIME::Base64;
 
my %AddArray;
 
$ldap = Net::LDAP->new( 'localhost' );
$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'vishnu');

$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=localhost', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";


$mesg = $ldap->search( base=> "ou=People,o=10020,dc=qlc.in",filter =>"objectclass=*",attrs=>['cn','givenName']);


$mesg->code && die $mesg->error;
foreach $entry ($mesg->entries)
{
#  $entry->dump;
       $cn=$entry->get_value("givenName");
       $gn=$entry->get_value("cn");
       print $cn."\n";
 #      exit;
       $dn='cn='.$cn.',ou=People,dc=qlc.in';
       #$mesg = $ldap->delete( $dn );
      # print "\n$dn";
}

#print $dn;
#exit;
@entries = $mesg->count;
print "\n@entries\n";
