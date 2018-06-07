use  Net::LDAP;
use  Data::Dumper;
#objectclass=*
my $hostname = "192.168.1.59";
  my $ldap = Net::LDAP->new($hostname)
   or die "Unable to connect to LDAP server $hostname: $@\n";
 my $result = $ldap->bind();
print $result->code;
my @Attrs = ();               # request all available attributes
my $result = $ldap->search( base=>"",filter  => "(&(cn=*))", attrs   => \@Attrs );
print Dumper($result); 
