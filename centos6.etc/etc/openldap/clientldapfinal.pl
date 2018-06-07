 #!/usr/bin/perl
require DBI;
use Net::LDAP;
use Digest::SHA1;
use MIME::Base64;


my %AddArray0;
my %AddArray;
my %AddArray1;
my %AddArray2;
my %AddArray3;
my %AddArray5;



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

$ldap = Net::LDAP->new( 'localhost' );
$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'ldap');



#$mesg = $ldap->search( # perform a search
#		base   => "ou=People,o=qlc,dc=qlc.in",
#		filter => "(objectClass=*)",
#		attrs=> [ 'uid','cn' , 'objectclass']
#		);

#$mesg->code && die $mesg->error;
#foreach $entry ($mesg->entries)
#{

#$entry->dump;
#	$cn=$entry->get_value("cn");
#	$dn='cn='.$cn.',ou=People,o=qlc,dc=qlc.in';
#	$mesg = $ldap->delete( $dn );
#print "\n$dn";

#}


$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=localhost', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";


#$query = "select id,user_name,nick_name,email,fname,lname,info,cell,home_phone,organization,department,job_title,work_phone,fax_number,work_street,work_po_box,work_city,work_state,work_zip_code,work_country,home_street,home_po_box,home_city,home_state,home_zip_code,home_country from address_books where user_name != '' and nick_name != '' ";


#####vishnu####$query = "select id,nick_name,nick_name,email,fname,lname,info,cell,home_phone,organization,department,job_title,work_phone,fax_number,work_street,work_po_box,work_city,work_state,work_zip_code,work_country,home_street,home_po_box,home_city,home_state,home_zip_code,home_country from address_books where user_name != '' and nick_name != '' ";

####### to create company address book an ou=people ..by vishnu

$query = "select distinct client_id, name from client_domains";
#print $query;
#exit;

$sth = $dbh->prepare($query);
$sth->execute();
while (@row = $sth->fetchrow_array) {


	($id,$name)=@row;
                    
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
    
	if($name) { $AddArray1{'ou'} = 'addressbook';
         
		$AddArray1{'description'} = 'organization addressbook';
	}
	$AddArray1{'objectclass'} = ['top','organizationalUnit' ];
       

	$result = $ldap->add ( $dn, attrs => [ %AddArray1 ] );
	$result->code && warn "failed to add entry: ", $result->error ;


$query5 = "select distinct client_id from client_domains";

$sth5 = $dbh->prepare($query5);
$sth5->execute();
while (@row5 = $sth5->fetchrow_array) {
($id)=@row5;


	#$query1= "select email_address as user , password  from client_users where client_id =$id";
	$query1= "select if(client_users.client_domain_id=0,client_users.email_address, concat(client_users.email_address,\'@\',client_domains.name)) as user , password  from client_users LEFT JOIN client_domains ON client_users.client_domain_id  = client_domains.id ";

#print $query1;
#exit;
	$sth1 = $dbh->prepare($query1);
	$sth1->execute();
	while (@row1 = $sth1->fetchrow_array)
	{
		($uid1,$password)=@row1;

if(!$password) { $password=$uid1;}

		if($uid1) {
			$dn = 'cn='.$uid1.',ou=People,o='.$id.',dc=qlc.in';
			print "$dn \n $password";
			$AddArray{'cn'} = $uid1;
			$AddArray{'sn'} = $uid1;
			#$ctx = Digest::SHA1->new;
			#$ctx->add($password);
			#$hashedPasswd = '{SHA}' . encode_base64($ctx->digest,'');
			$hashedPasswd = md5Password($password);
			$AddArray{'ou'} = 'People';
	          	$AddArray{'userPassword'} = $hashedPasswd;
			$AddArray{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];

			$mesg = $ldap->delete( $dn );

			$result = $ldap->add ( $dn, attrs => [ %AddArray ] );                                                                         $result->code && warn "failed to add entry: ", $result->error ;                                                                                                                                
      }
 }

$query6= "select email as user from  address_books limit 10";
#print $query6;
#exit; 
       $sth6 = $dbh->prepare($query6);
       #print $sth6;
       #exit; 
       $sth6->execute();
        while (@row6 = $sth6->fetchrow_array)
        {
                ($uid1)=@row6;

                if($uid1) {
                        $dn = 'cn='.$uid1.',ou=addressbook,o='.$id.',dc=qlc.in';
                        print "$dn \n";
                        $AddArray2{'cn'} = $uid1;
                        $AddArray2{'sn'} = $uid1;
                        $AddArray2{'mail'} = $uid1; 
                        $AddArray2{'ou'} = 'addressbook';
                        $AddArray2{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];

                        $mesg = $ldap->delete( $dn );

        $result = $ldap->add ( $dn, attrs => [ %AddArray2 ] );                                                                         $result->code && warn "failed to add entry: ", $result->error ;                                                         
      }
 }
}#while



$query = "select b.client_id as id,concat(a.email_address,'\@',b.name) as email ,a.email_address as name, a.full_name as user_name,b.name as organization  from client_domains as b, pop_email_aliases as a  where a.client_id=b.client_id AND b.id = a.client_domain_id";

#print $query;
#exit;


$sth = $dbh->prepare($query);
$sth->execute();
while (@row = $sth->fetchrow_array) {

#print "@row\n";
#print "\n$row[0]";


	($id,$email,$name,$user_name,$organization)=@row;
      
        $nickname = trim($user_name);
       
	$uid = trim($name);
	#print $uid;
	#exit; 
	$sn = trim($lname);
	$gn = trim($fname);
	$o = trim($organization);
	$l = trim($work_city);
	$street = trim($work_street);
	$st = trim($work_state);
	$postalCode = trim($work_zip_code);
	$homePhone = trim($work_phone);
	$telephoneNumber = trim($work_phone);
	$mail = trim($email);
	$mobile = trim($cell);

	$title = trim($job_title);
	$department = trim($department);

	if($uid) {
		$dn = 'cn='.$uid.',ou=addressbook,o='.$id.',dc=qlc.in';
		#print $dn;
               # exit;     
                $AddArray3{'cn'} = $uid;
#print $AddArray3{'cn'}$AddArray3{'cn'};		
if($nickname) {  $AddArray3{'uid'} = $nickname;  }
		print "$dn\n";      
		$AddArray3{'sn'} = $uid; 
		if($gn) { $AddArray3{'gn'} = $gn; }

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
		$result->code && warn "failed to add entry: ", $result->error ;
# }

}

}



$dbh-finish;
$dbh->disconnect();

$mesg = $ldap->unbind;  # take down session

}




