 #!/usr/bin/perl
 
require DBI;
use Net::LDAP;
use Digest::SHA1;
use MIME::Base64;
use Net::LDAP::Entry;


#Declaring array for storing data
my %AddArray0;
my %AddArray;
my %AddArray1;
my %AddArray2;
my %AddArray3;
my %AddArray5;

#Include configuration file

require ('config.pl');

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

#LDAP bind function

$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'vishnu');

#Mysql database connectivity.

$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=localhost', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";

#Query for selecting client id,domain name from client_domains table.

$query="select distinct client_domains.client_id,client_domains.name from client_domains INNER JOIN pop_accounts on client_domains.client_id=pop_accounts.client_id where pop_accounts.created>='$time' and pop_accounts.created<='$current_time' OR pop_accounts.modified>='$time' and pop_accounts.modified<='$current_time'";

#print $query;
#exit;

$sth = $dbh->prepare($query);
$sth->execute();
while (@row = $sth->fetchrow_array) 
{
	
        ($id,$name)=@row;
 
        #print $id;
      
        $dn = 'o='.$id.',dc=qlc.in';
      
        if($name) { $AddArray0{'o'} = $name;}
   
	$AddArray0{'objectclass'} = ['top', 'organization'];
    
        print "$dn \n";

	$result = $ldap->add ( $dn, attrs => [ %AddArray0 ] );
         
        $result->code && warn "failed to add entry: ", $result->error;

	$dn = 'ou=People,o='.$id.',dc=qlc.in';

        $AddArray5{'ou'} = 'People';
        
        $AddArray5{'objectclass'} = ['top', 'organizationalUnit'];
	
        print "$dn \n";

	$result = $ldap->add ( $dn, attrs => [ %AddArray5 ] );
	
        $result->code && warn "failed to add entry: ", $result->error ;
        
      
# for ou addressbook

	$dn = 'ou=addressbook,o='.$id.',dc=qlc.in';
    
	if($name) 
        { 
                $AddArray1{'ou'} = 'addressbook';
                $AddArray1{'description'} = 'organization addressbook';
	}
	$AddArray1{'objectclass'} = ['top','organizationalUnit' ];
        
        $result = $ldap->add ( $dn, attrs => [ %AddArray1 ] );
	
        $result->code && warn "failed to add entry: ", $result->error ;

        #Query for selecting client id from client_domains table.

        $query5="select distinct client_domains.client_id from client_domains INNER JOIN pop_accounts on client_domains.client_id=pop_accounts.client_id where pop_accounts.created>='$time' and pop_accounts.created<='$current_time' OR pop_accounts.modified>='$time' and pop_accounts.modified<='$current_time'";

#print $query5;
#exit;

        $sth5 = $dbh->prepare($query5);
        $sth5->execute();
        while (@row5 = $sth5->fetchrow_array) 
        {
          ($id)=@row5;
#Query for displaying newly added and modified mailbox clients.
        
        #print $id;
        #exit;
   $query1="select if(client_users.client_domain_id=0,client_users.email_address,concat(client_users.email_address,\'@\',client_domains.name))as user,password,full_name from client_users  INNER JOIN client_domains  on client_domains.id=client_users.client_domain_id INNER JOIN clients  on clients.id=client_users.client_id INNER JOIN pop_accounts  on client_users.id=pop_accounts.client_user_id where client_users.client_id=$id and(( pop_accounts.created>='$time' and pop_accounts.created<='$current_time') OR (pop_accounts.modified>='$time' and pop_accounts.modified<='$current_time'))";

#print "--$query1";
#exit;

	$sth1 = $dbh->prepare($query1);
	$sth1->execute();
	while (@row1 = $sth1->fetchrow_array)
	{
		($uid1,$password,$full_name)=@row1;
        
               if(!$password) { $password=$uid1;}
                if($uid1,$full_name) 
                {
                   #  print "***$uid1";
                    # exit;
			    $dn = 'cn='.$uid1.',ou=People,o='.$id.',dc=qlc.in';

		            print "$dn\n";  
                            $AddArray{$cn}{'cn'} = $full_name;
                   
                       print $AddArray{$cn}{'cn'};
                        exit;
		       	    $AddArray{'sn'} = $uid1;
			    $hashedPasswd = md5Password($password);
			    $AddArray{'ou'} = 'People';
	          	    $AddArray{'userPassword'} = $hashedPasswd;
                            $AddArray{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];
                   	    $mesg = $ldap->delete( $dn );
                            $result = $ldap->add ( $dn, attrs => [ %AddArray ]);
                            # $result = $ldap->add( $dn,
                            # attr => [
                            # 'cn'   => ['Barbara Jensen', 'Barbs Jensen'],
                            # 'sn'   => 'Jensen',
                            # 'mail' => 'b.jensen@umich.edu',
                             #     'objectclass' => ['top', 'person',
                              #             'organizationalPerson',
                               #            'inetOrgPerson' ],
                       #]
                    # );
                           # print %AddArray;
                           #  exit;   
                            
                            $result->code && warn "failed to add entry: ", $result->error ;                                                                         }
        }
        
                           



     
#query for selecting email from address_books table.
 
	$query6= "select email as user from  address_books where client_id=$id";

   	$sth6 = $dbh->prepare($query6);
        $sth6->execute();
        while (@row6 = $sth6->fetchrow_array)
        {
                ($uid1)=@row6;
               #print "##$uid1";
               #exit; 
                if($uid1) 
                {
                   $dn = 'cn='.$uid1.',ou=addressbook,o='.$id.',dc=qlc.in';
                   $AddArray2{'cn'} = $uid1;
                   $AddArray2{'sn'} = $uid1; 
                   $AddArray2{'mail'} = $uid1; 
                   $AddArray2{'ou'} = 'addressbook';
                   $AddArray2{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];
		   $mesg = $ldap->delete( $dn );
                   $result = $ldap->add ( $dn, attrs => [ %AddArray2 ] );  
                   $result->code && warn "failed to add entry: ", $result->error ;                                                         
                }
        }


}


#Query for displaying newly added and modified pop emails.
	$query = "select b.client_id as id,concat(a.email_address,'\@',b.name) as email ,a.mobile as mobile,a.email_address as name, a.full_name as user_name,b.name as organization  from client_domains as b, pop_email_aliases as a  where  a.client_id=b.client_id AND b.id = a.client_domain_id AND ((a.created>='$time' and a.created<='$current_time') OR (a.modified>='$time' and a.modified<='$current_time'))"; 

#print "#####$query";
#exit;

	$sth = $dbh->prepare($query);
	$sth->execute();
	while (@row = $sth->fetchrow_array) 
	{
      	     ($id,$email,$mobile,$name,$user_name,$organization)=@row;
#print "**$mobile";
#exit;         

             $nickname = trim($user_name);
             $uid = trim($name);
	     $sn = trim($email);
	     $gn = trim($user_name);
	     $o = trim($organization);
	     $l = trim($work_city);
	     $street = trim($work_street);
	     $st = trim($work_state);
	     $postalCode = trim($work_zip_code);
	     $homePhone = trim($work_phone);
	     $telephoneNumber = trim($work_phone);
	     $mail = trim($email);
	     $mobile = trim($mobile);
             $title = trim($job_title);
	     $department = trim($department);
	     if($uid) 
             {
		  $dn = 'cn='.$uid.',ou=addressbook,o='.$id.',dc=qlc.in';    
                  $AddArray3{'cn'} = $user_name;		
                  if($nickname) {  $AddArray3{'uid'} = $nickname;  }
		  print "$dn\n";      
		  $AddArray3{'sn'} = $uid; 
                  if($gn) { $AddArray3{'gn'} = $user_name; }
                  if($o) { $AddArray3{'o'} = $o;}
		  if($l) { $AddArray3{'l'} = $l; }
		  if($street) { $AddArray3{'street'} = $street; }
		  if($st) {  $AddArray3{'st'} = $st; }
		  if($postalCode) { $AddArray3{'postalCode'} = $postalCode; }
		  if($homePhone) {  $AddArray3{'homePhone'} = $homePhone;  }
		  if($telephoneNumber) { $AddArray3{'telephoneNumber'} = $telephoneNumber; }
		  if($mail) { $AddArray3{'mail'} = $mail;  }
		  if($mobile) { $AddArray3{'mobile'} = $mobile;  }
                  if($title) {$AddArray3{'title'} = $title; }
		  $AddArray3{'userPassword'} = $hashedPasswd;
		  $AddArray3{'ou'} = 'addressbook';
		  $AddArray3{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];
                  $mesg = $ldap->delete( $dn );
                  $result = $ldap->add ( $dn, attrs => [ %AddArray3 ] );
                # print  %AddArray3;
                # exit;   
                 $result->code && warn "failed to add entry: ", $result->error ;
	   }

      }

}






#Query for displaying newly deleted pop accounts.

	$sql="select audit_logs.comment as audit_logs,audit_logs.client_id from audit_logs INNER JOIN clients  on audit_logs.client_id=clients.id where audit_logs.created_on>='$time' and audit_logs.created_on<='$current_time' and audit_logs.module_action='delete' and module_identifier='mailbox account'";
        
#print $sql;
#exit;

        $sth = $dbh->prepare($sql);
	$sth->execute();
	while (@row = $sth->fetchrow_array)
	{
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
                }
         }

 #Query for displaying newly deleted pop emails.

	$sql="select audit_logs.comment,audit_logs.client_id from audit_logs  INNER JOIN clients  on audit_logs.client_id=clients.id where audit_logs.created_on>='$time' and audit_logs.created_on<='$current_time' and audit_logs.module_action='delete' and module_identifier='routing'";

	$sth = $dbh->prepare($sql);
	$sth->execute();
	while (@row = $sth->fetchrow_array)
	{
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
                    $ldap->delete( $dn );
                  #  $result->code && warn "failed to add entry: ", $result->error ;                                                         
                }
                                                                                                                                                             }


  
                                                                                                                                              
$dbh-finish;
$dbh->disconnect();
$mesg = $ldap->unbind;  





