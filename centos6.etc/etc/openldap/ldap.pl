use Net::LDAP;
$ldap = Net::LDAP->new ( "192.168.1.59" ) or die "$@";
# do an anonymous bind
 $mesg = $ldap->bind ( version => 3 );          # use for searches
# list attributes to be queries
 my @Attrs = ( );
my $result = LDAPsearch ( $ldap, "campusid=000000137118", \@Attrs );
my @entries = $result->entries;


my $entr;
foreach $entr ( @entries ) {
   print "DN: ", $entr->dn, "\n";

   my $attr;
   foreach $attr ( sort $entr->attributes ) {
     # skip binary we can't handle
           next if ( $attr =~ /;binary$/ );
                print "  $attr : ", $entr->get_value ( $attr ) ,"\n";
                   }
     
                      print "#-------------------------------\n";
    } 

$ldap->unbind;

sub LDAPsearch
{
   my ($ldap,$searchString,$attrs,$base) = @_;

   # if they don't pass a base... set it for them
   
       if (!$base ) { $base = "ou=University of California Irvine,o=University of California,C=US"; }
   
          # if they don't pass an array of attributes...
             # set up something for them
   
                if (!$attrs ) { $attrs = [ 'cn','type' ]; }
   
                   my $result = $ldap->search ( base    => "$base",
                                                   scope   => "sub",
                                                                                   filter  => "$searchString",
                                                                                                                   attrs   =>  $attrs);
                                                                                                                                                 }          
