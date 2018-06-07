 #!/usr/bin/perl
 require DBI;
 use Net::LDAP;
 use Digest::SHA1;
 use MIME::Base64;
 use Net::LDAP::Entry; 


 require ('config.pl');

my %delarray;


# Perl trim function to remove whitespace from the start and end of the string
 sub trim($)
 {
         my $string = shift;
                 $string =~ s/^\s+//;
                         $string =~ s/\s+$//;
                                 return $string;
                                 }
                                 # Left trim function to remove leading whitespace
                                 sub ltrim($)
                                 {
                                         my $string = shift;
                                                 $string =~ s/^\s+//;
                                                         return $string;
                                                         }
                                                         # Right trim function to remove trailing whitespace
                                                         sub rtrim($)
{
        my $string = shift;
        $string =~ s/\s+$//;
        return $string;
}
sub md5Password {

        my ($passwd) = @_;
        my @md5 = split "",$passwd;
        my @res;
        for (my $i = 0 ; $i < 32 ; $i+=2)
        {
                my $c = (((hex $md5[$i]) << 4) % 255) | (hex $md5[$i+1]);
                $res[$i/2] = chr $c;
        }

        my $password = "{MD5}".encode_base64(join "", @res);
        return $password;
}


#LDAP connectivity.

$ldap = Net::LDAP->new( 'localhost' );

$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'vishnu');

$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=localhost', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";


$entry=Net::LDAP::Entry->new;


 $sql="select audit_logs.comment as audit_logs,audit_logs.client_id from audit_logs INNER JOIN clients  on audit_logs.client_id=clients.id where audit_logs.created_on>='$time' and audit_logs.created_on<='$current_time' and audit_logs.module_action='delete' and module_identifier='mailbox account'";

#print $sql;
#exit;
$sth = $dbh->prepare($sql);
                #print $sth;
                        #exit;   
$sth->execute();
while (@row = $sth->fetchrow_array)
{
                                                          #print @row;
                                                                      #exit;    
     ($audit_logs,$id)=@row;
     if($audit_logs,$id)
     {
               
              @arr_email=split(":",$audit_logs);
                    $email_address = $arr_email[1];
                    $email=trim($email_address);
                    @array=split("@",$email);
                    $add=$array[0];
    
             $dn = 'cn='.$add.',ou=addressbook,o='.$id.',dc=qlc.in';
                                                                                                                           
             print "$dn\n";
                                                                                                                                                                                                                                                       
             $ldap->delete($dn);
                                                                                                   #print "-----$result";
                                                                                                                       #exit;
                                                                                                                                          #$result->code && warn "failed to delete entry: ", $result->error ; 
                                                                                                                                                            
                                                    
                                                                                                                                                                                      #              $result->code && warn "failed to add entry: ", $result->error ;                                                         
                                                                                                                                                                          }
                    
                                                                                                                                                      }
                                        
