 #!/usr/bin/perl
 require DBI;
 use Net::LDAP;
 use Digest::SHA1;
 use MIME::Base64;
 use Net::LDAP::Entry;
 use Data::Dumper;	

my %ldapusers; 
my %mailserveusers;
my %ldap1;
my %ldap2;
my %data;
my %ldapuserdata;
my %mailserveuserdata;


$ldap = Net::LDAP->new( 'localhost' );

$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'vishnu');

$dbh = DBI->connect('DBI:mysql:ldap;host=localhost', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";

$dn = 'ou=People,o=10020,dc=qlc.in';

$mesg = $ldap->search( base => $dn, filter =>"cn=*",attrs=>['cn','givenName'] );

my $entry;
my @entries = $mesg->entries;

foreach $entry (@entries) 
{
   push(@{$ldapusers},$entry->dn);

}

foreach my $value (@{$ldapusers})
{
  
    my ($cn,$ou,$o,$dc) = split /,/, $value;
    $ldapusers{"manesh@maaki.in"}{cn}   = $cn;
    $ldapusers{"manesh@maaki.in"}{ou}    = $ou;
    $ldapusers{"manesh@maaki.in"}{o}   = $o;   
    $ldapusers{"rohan@maaki.in"}{cn}   = $cn;
    $ldapusers{"rohan@maaki.in"}{ou}    = $ou;
    $ldapusers{"rohan@maaki.in"}{o}   = $o;   

    print Dumper \%ldapusers;
   print "----------------\n";

}

#print $ldapuserdata{$cn};
#exit;

@entries = $mesg->count;
print "@entries\n";
  

$query1="select if(client_users.client_domain_id=0,client_users.email_address,concat(client_users.email_address,\'@\',client_domains.name))as cn,client_users.client_id as o,client_users.full_name as first_name from client_users  INNER JOIN client_domains  on client_domains.id=client_users.client_domain_id INNER JOIN clients  on clients.id=client_users.client_id INNER JOIN pop_accounts  on client_users.id=pop_accounts.client_user_id where client_users.client_id=10020";

$sth = $dbh->prepare($query1);
$sth->execute();
while (@row= $sth->fetchrow_array)
{
   ($cn,$o,$first_name)=@row;
   @row= "cn=$cn\no=$o\nfullname=$first_name";
   $mailserveuserdata{'cn'} = $cn;
   $mailserveuserdata{'o'} = $o;
   $mailserveuserdata{'gn'} = $first_name;
   push(@{$mailserveusers},@row);
}

$mesg = $ldap->unbind;

