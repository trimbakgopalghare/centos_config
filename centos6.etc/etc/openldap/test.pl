  #!/usr/bin/perl
  
  require DBI;
  use Net::LDAP;
  use Digest::SHA1;
  use MIME::Base64;
  use Net::LDAP::Entry;
 
$ldap = Net::LDAP->new('localhost');

#LDAP bind function
#
$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'qlc');

print $mesg;

my $result = $ldap->search(
    base   => "cn=,ou=People,o=10020,dc=qlc.in",
    filter => "(&(cn=*))"
);
 
print $ldap;
#exit;

#die $result->error if $result->code;
 
printf "COUNT: %s\n", $result->count;
 
foreach my $entry ($result->entries) {
    $entry->dump;
}
print "===============================================\n";
 
foreach my $entry ($result->entries) {
    printf "%s <%s>\n",

$entry->get_value("displayName"),
        ($entry->get_value("mail") || '');
}
 
$ldap->unbind;




















#print "--$mesg";
#exit;
                         
                                        # End of that DN
        
                                                                   #
                                                                    #  end of as_struct method
                                                                     #
                                                                      #--------
 
 
                                                                       #------------
                                                                        #
                                                                         # handle each of the results independently
                                                                          # ... i.e. using the walk through method
                                                                           #
                                                            # skip binary we can't handle
                   
 
                                                                                                              #
                                                                                                               # end of walk through method
                                                                                                                #------------
 
