 #!/usr/bin/perl
 require DBI;
 use Net::LDAP;
 use Digest::SHA1;
 use MIME::Base64;
 use Net::LDAP::Entry;
 use Data::Dumper;	

use Fcntl ':flock';
INIT
{
        die "Not able to open $0\n" unless (open ME, $0);
        die "I'm already running !!\n" unless(flock ME, LOCK_EX|LOCK_NB);
}



#Array declaration for storing data
my %ldapuserdata;
my %mailserve;
my %mailserveuserdata;
my %mailserveusers;
my %mailserveaddressbook;

#Array declaration for storing data of pop_accounts
my %popdnvalue;
my %Addpoporganization;
my %Addpopdnvalues;
my %Addpopdnvalue;
my %organizationpoparray;
my %Array2;

#Array declaration for storing data of pop_email_aliases
my %Adddnemail;
my %Adddnpopemails;
my %popemaildnvalue;
my %organizationemail;
my %popemaildn;
my %Addorganizationemail;


#Array declaration for storing data of addressbooks
my %modifyaddressbookdn;
my %Adddnaddressbook;
my %Adddn;
my %organizationaddressbook;
my %addressbookdn;
my %Addorganization;

#Array declaration for storing data of ldap_accounts
my %ldapdnarray;
my %addorganizationldap;
my %addldapdn;
my %addldapdnarray;
my %organizationldap;
my %ldapdnvalue;


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

#Ldap connectivity

$ldap = Net::LDAP->new( '192.168.1.187' );

#Ldap bind function

$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'vishnu');


#Database connectivity 

$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=192.168.1.187', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";

#Distinguished name

$dn = 'dc=qlc.in';

#Ldap Search function

$mesg1 = $ldap->search( base => $dn,  filter =>"(objectClass=*)", attrs => ['cn','ou','o','userPassword','uid','mobile']);

#print Dumper($mesg1);
#exit;
my $entry;

my @entries = $mesg1->entries;

#For getting each values from ldap server

foreach $entry (@entries) 
{ 
          
 	my $attr;
	$cn = "";
	$o = "";
	$displayName = "";
        foreach $attr ( sort $entry->attributes ) 
        {
              $cn = $entry->get_value("cn");
              $o = $entry->get_value("o");
              $ou=$entry->get_value("ou");
              $uid=$entry->get_value("uid");
              $mobile=$entry->get_value("mobile");
              $displayName = $entry->get_value("displayName");
              $pass= $entry->get_value("userPassword");
        }      
        $ldapuserdata{$uid}{'cn'}   = $cn;
        $ldapuserdata{$uid}{'ou'}   = $ou;
        $ldapuserdata{$uid}{'mobile'}   = $mobile; 
        $ldapuserdata{$uid}{'o'}   = $o;
        $ldapuserdata{$uid}{'uid'} = $uid;
	$ldapuserdata{$uid}{'displayName'}   = $displayName;
        $ldapuserdata{$uid}{'userPassword'} =$pass;
        $ldapuserdata{$uid}{'found'} =0;   
}

#Query for displaying all pop_accounts
  $query1="select concat(client_users.email_address,\'@\',client_domains.name)as cn,client_users.client_id as o,client_users.full_name as first_name,client_users.mobile from client_users  INNER JOIN client_domains  on client_domains.id=client_users.client_domain_id INNER JOIN clients  on clients.id=client_users.client_id INNER JOIN pop_accounts  on client_users.id=pop_accounts.client_user_id where client_users.client_id=17";


$sth = $dbh->prepare($query1);
$sth->execute();

while (@row= $sth->fetchrow_array)
{
   ($mysqluid,$mysqlo,$first_name,$mobile)=@row;
   @row= "uid=$mysqluid\no=$mysqlo\nfullname=$first_name\nmobile=$mobile";
   $mailserveuserdata{$mysqluid}{'uid'} = $mysqluid;
   $mailserveuserdata{$mysqluid}{'cn'}=$first_name;
   $mailserveuserdata{$mysqluid}{'o'} = $mysqlo;
   $mailserveuserdata{$mysqluid}{'mobile'} = $mobile;
}

#Function for comapring both ldap and mailserve data 

foreach $mysqluid (keys (%mailserveuserdata))
{
      #Checking of if mailserve data is already present in ldap
      if ($ldapuserdata{$mysqluid}{'uid'} eq $mailserveuserdata{$mysqluid}{'uid'} &&  $ldapuserdata{$mysqluid}{'cn'} eq $mailserveuserdata{$mysqluid}{'cn'} && $ldapuserdata{$mysqluid}{'o'} == $mailserveuserdata{$mysqluid}{'o'} && $ldapuserdata{$mysqluid}{'mobile'} == $mailserveuserdata{$mysqluid}{'mobile'}) 
     {
          print "Already present in ldap\n";   
	
     } 
     elsif($ldapuserdata{$mysqluid}{'uid'} eq $mailserveuserdata{$mysqluid}{'uid'})#Checking for if any records in mailserve is modified
     {
          $dn = 'o='.$mailserveuserdata{$mysqluid}{'o'}.',dc=qlc.in';
          if ($mailserveuserdata{$mysqluid}{'o'}) { $organizationpoparray{'o'} = $mailserveuserdata{$mysqluid}{'o'};}
          $organizationpoparray{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %organizationpoparray ] );
          $dn = 'ou=addressbook,o='.$mailserveuserdata{$mysqluid}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $Array2{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %Array2 ] );
          $dn = 'uid='.$mailserveuserdata{$mysqluid}{'uid'}.',ou=addressbook,o='.$mailserveuserdata{$mysqluid}{'o'}.',dc=qlc.in';
	  print "==$dn\n";
          $popdnvalue{'cn'} = $mailserveuserdata{$mysqluid}{'cn'};
          $popdnvalue{'uid'}=$mailserveuserdata{$mysqluid}{'uid'};
          if($mailserveuserdata{$mysqluid}{'mobile'} eq '') { $popdnvalue{'mobile'}='undef' }
          else{ $popdnvalue{'mobile'} = $mailserveuserdata{$mysqluid}{'mobile'}};
          $popdnvalue{'o'}=$mailserveuserdata{$mysqluid}{'o'};
          $popdnvalue{'sn'} = $mailserveuserdata{$mysqluid}{'cn'};
          $popdnvalue{'mail'}= $mailserveuserdata{$mysqluid}{'uid'};
          $popdnvalue{'ou'} = 'addressbook';
          $popdnvalue{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap->delete ( $dn);
          $result = $ldap->add ( $dn, attrs => [ %popdnvalue ]);       
      }    
      #Checking for adding new records in LDAP                                                                               
      else 
      {
          $dn = 'o='.$mailserveuserdata{$mysqluid}{'o'}.',dc=qlc.in';
          if ($mailserveuserdata{$mysqluid}{'o'}) { $Addpoporganization{'o'} = $mailserveuserdata{$mysqluid}{'o'};}
          $Addpoporganization{'objectclass'} = ['top', 'organization'];        
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %Addpoporganization ] );
          $dn = 'ou=addressbook,o='.$mailserveuserdata{$mysqluid}{'o'}.',dc=qlc.in';
          $Addpopdnvalue{'ou'} = 'addressbook';
          $Addpopdnvalue{'objectclass'} = ['top', 'organizationalUnit'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %Addpopdnvalue ] );
          $dn = 'uid='.$mailserveuserdata{$mysqluid}{'uid'}.',ou=addressbook,o='.$mailserveuserdata{$mysqluid}{'o'}.',dc=qlc.in';
          print "====$dn\n";
          my ($email, $domain) = split('@',$mailserveuserdata{$mysqluid}{'uid'});
          $Addpopdnvalues{'uid'}=$mailserveuserdata{$mysqluid}{'uid'};
          if($mailserveuserdata{$mysqluid}{'cn'} eq '') { $Addpopdnvalues{'cn'}='undef' }
          else{ $Addpopdnvalues{'cn'} = $mailserveuserdata{$mysqluid}{'cn'}};
          $Addpopdnvalues{'o'}=$mailserveuserdata{$mysqluid}{'o'};
          $Addpopdnvalues{'sn'} = $mailserveuserdata{$mysqluid}{'cn'};
          if($mailserveuserdata{$mysqluid}{'mobile'} eq '') { $Addpopdnvalues{'mobile'}='undef' }
          else{ $Addpopdnvalues{'mobile'} = $mailserveuserdata{$mysqluid}{'mobile'}};     
          $Addpopdnvalues{'mail'}= $mailserveuserdata{$mysqluid}{'uid'}; 
          $Addpopdnvalues{'ou'} = 'addressbook';
          $Addpopdnvalues{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];
          $mesg = $ldap->delete( $dn );
          $result = $ldap->add ( $dn, attrs => [ %Addpopdnvalues ]);    
      }  
  $ldapuserdata{$mysqluid}{'found'} =1;
}

#print Dumper(%ldapuserdata);
#exit;
#Query for displaying LDAP accounts users.
  
 $query5="select concat(client_users.email_address,\'@\',client_domains.name)as cn,client_users.client_id as o,client_users.full_name as first_name,client_users.password from client_users  INNER JOIN client_domains  on client_domains.id=client_users.client_domain_id INNER JOIN clients  on clients.id=client_users.client_id INNER JOIN ldap_accounts  on client_users.id=ldap_accounts.client_user_id where ldap_accounts.status=1 and client_users.client_id=17";


$sth = $dbh->prepare($query5);
$sth->execute();

while (@row= $sth->fetchrow_array)
{
   ($uid,$o,$first_name,$pass)=@row;
   $hashedPasswd = md5Password($pass);
   @row= "uid=$uid\no=$o\nfullname=$first_name\npassword=$hashedPasswd";
   $mailserve{$uid}{'uid'} = $uid;
   $mailserve{$uid}{'cn'}=$first_name;
   $mailserve{$uid}{'o'} = $o;
   $mailserve{$uid}{'displayName'} = $first_name;
   $mailserve{$uid}{'userPassword'} = $hashedPasswd;
}

#Function for comparing mailserve user data and ldap user data

foreach $uid (keys (%mailserve))
{ 
   #Checking of if mailserve data is already present in ldap
    if ($ldapuserdata{$uid}{'uid'} eq $mailserve{$uid}{'uid'} && $ldapuserdata{$uid}{'o'} == $mailserve{$uid}{'o'} && $ldapuserdata{$uid}{'cn'} eq  $mailserve{$uid}{'cn'} && $ldapuserdata{$uid}{'userPassword'} eq  $mailserve{$uid}{'userPassword'}) 
    {
          print "Already present in ldap\n";

    }
    #Checking for if any records in mailserve is modified
    elsif($ldapuserdata{$uid}{'uid'} eq $mailserve{$uid}{'uid'})      
    {
          $dn = 'o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          if ($mailserve{$uid}{'o'}) { $organizationldap{'o'} = $mailserve{$uid}{'o'};}
          $organizationldap{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %organizationldap ] );
          $dn = 'ou=people,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $ldapdnvalue{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %ldapdnvalue ] );
          $dn = 'uid='.$mailserve{$uid}{'uid'}.',ou=people,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "**$dn\n";
          $ldapdnarray{'cn'} = $mailserve{$uid}{'cn'};
          $ldapdnarray{'uid'}=$mailserve{$uid}{'uid'};
          $ldapdnarray{'o'}=$mailserve{$uid}{'o'};
          $ldapdnarray{'sn'} = $mailserve{$uid}{'cn'};
          $ldapdnarray{'mail'}= $mailserve{$uid}{'uid'};
          $ldapdnarray{'userPassword'} = $mailserve{$uid}{'userPassword'} ;
          $ldapdnarray{'ou'} = 'people';
          $ldapdnarray{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap->delete ( $dn);
          $result = $ldap->add ( $dn, attrs => [ %ldapdnarray ]);
     }
     #Checking for adding new records in LDAP
     else 
     {
          $dn = 'o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          if ($mailserve{$uid}{'o'}) { $addorganizationldap{'o'} = $mailserve{$uid}{'o'};}
          $addorganizationldap{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %addorganizationldap ] );
          $dn = 'ou=people,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $addldapdn{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %addldapdn ] );
          $dn = 'uid='.$mailserve{$uid}{'uid'}.',ou=people,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "****$dn\n";
          $addldapdnarray{'cn'} = $mailserve{$uid}{'cn'};
          if($mailserve{$uid}{'displayName'} eq '') { $addldapdnarray{'displayName'}=$mailserve{$uid}{'cn'} }
          else{ $addldapdnarray{'displayName'} = $mailserve{$uid}{'displayName'}};
          $addldapdnarray{'uid'}=$mailserve{$uid}{'uid'};
          $addldapdnarray{'o'}=$mailserve{$uid}{'o'};
          $addldapdnarray{'sn'} = $mailserve{$uid}{'cn'};
          $addldapdnarray{'mail'}= $mailserve{$uid}{'uid'};
          $addldapdnarray{'userPassword'} = $mailserve{$uid}{'userPassword'} ;
          $addldapdnarray{'ou'} = 'people';
          $addldapdnarray{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap->delete ( $dn); 
          $result = $ldap->add ( $dn, attrs => [ %addldapdnarray ]);
     }
 $ldapuserdata{$uid}{'found'} =1;
}



#Query for displaying company addressbooks

$query2="select address_books.email as email,clients.id as id,address_books.fname from address_books,clients where clients.id=address_books.client_id and clients.id=17";


$sth = $dbh->prepare($query2);
$sth->execute();
while (@row = $sth->fetchrow_array)
{
      ($email_address,$id,$user_name)=@row;
      @row= "email=$email_address\no=$id\nfullname=$user_name";
      $mailserveaddressbook{$email_address}{'uid'} = $email_address;
      $mailserveaddressbook{$email_address}{'cn'}=$user_name;
      $mailserveaddressbook{$email_address}{'o'}=$id;
      $mailserveaddressbook{$email_address}{'displayName'}=$user_name;
}

#Function for comparing both mailserve user data and ldap user data

foreach $email_address (keys (%mailserveaddressbook))
{
     #Checking of if mailserve data is already present in ldap
     if ($ldapuserdata{$email_address}{'uid'} eq $mailserveaddressbook{$email_address}{'uid'} && $ldapuserdata{$email_address}{'o'} == $mailserveaddressbook{$email_address}{'o'} && (($ldapuserdata{$email_address}{'cn'} eq  $mailserveaddressbook{$email_address}{'cn'})|| $ldapuserdata{$email_address}{'cn'} eq $mailserveaddressbook{$email_address}{'uid'}))
     {
          print "Already present in ldap\n";

     }
     #Checking for if any records in mailserve is modified
     elsif($ldapuserdata{$email_address}{'uid'} eq $mailserveaddressbook{$email_address}{'uid'})
     {
          $dn = 'o='.$mailserveaddressbook{$email_address}{'o'}.',dc=qlc.in';
          if ($mailserveaddressbook{$email_address}{'o'}) { $organizationaddressbook{'o'} = $mailserveaddressbook{$email_address}{'o'};}
          $organizationaddressbook{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %organizationaddressbook ] );
          $dn = 'ou=addressbook,o='.$mailserveaddressbook{$email_address}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $addressbookdn{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %addressbookdn ] );
          $dn = 'uid='.$mailserveaddressbook{$email_address}{'uid'}.',ou=addressbook,o='.$mailserveaddressbook{$email_address}{'o'}.',dc=qlc.in';
          print "--$dn\n";
          if($mailserveaddressbook{$email_address}{'cn'} eq ''){$AddArray9{'cn'}=$mailserveaddressbook{$email_address}{'uid'}}
          else{$modifyaddressbookdn{'cn'} = $mailserveaddressbook{$email_address}{'cn'}};
          if($mailserveaddressbook{$email_address}{'displayName'} eq '') { $modifyaddressbookdn{'displayName'}=$mailserveaddressbook{$email_address}{'cn'} }
          else{ $modifyaddressbookdn{'displayName'} = $mailserveaddressbook{$email_address}{'displayName'}};
          $modifyaddressbookdn{'givenName'}=$mailserveaddressbook{$email_address}{'cn'};
          $modifyaddressbookdn{'uid'}=$mailserveaddressbook{$email_address}{'uid'};
          $modifyaddressbookdn{'o'}=$mailserveaddressbook{$email_address}{'o'};
          if( $mailserveaddressbook{$email_address}{'cn'} eq ''){$modifyaddressbookdn{'sn'}=$mailserveaddressbook{$email_address}{'uid'}}
          else{$modifyaddressbookdn{'sn'} = $mailserveaddressbook{$email_address}{'cn'}};
          $modifyaddressbookdn{'mail'}= $mailserveaddressbook{$email_address}{'uid'};
          $modifyaddressbookdn{'ou'} = 'addressbook';
          $modifyaddressbookdn{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg = $ldap->delete ( $dn);
          $result = $ldap->add ( $dn, attrs => [ %modifyaddressbookdn ]);

      }
      #Checking for adding new records in LDAP
      else
      {
          $dn = 'o='.$mailserveaddressbook{$email_address}{'o'}.',dc=qlc.in';
          if ($mailserveaddressbook{$email_address}{'o'}) { $Addorganization{'o'} = $mailserveaddressbook{$email_address}{'o'};}
          $Addorganization{'objectclass'} = ['top', 'organization'];
          print "----$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %Addorganization ] );
          $dn = 'ou=addressbook,o='.$mailserveaddressbook{$email_address}{'o'}.',dc=qlc.in';
          print "----$dn \n";
          $Adddn{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %Adddn ] );
          $dn = 'uid='.$mailserveaddressbook{$email_address}{'uid'}.',ou=addressbook,o='.$mailserveaddressbook{$email_address}{'o'}.',dc=qlc.in';
          print "----$dn\n";
          if($mailserveaddressbook{$email_address}{'cn'} eq ''){$Adddnaddressbook{'cn'} = $mailserveaddressbook{$email_address}{'uid'}}
          else{$Adddnaddressbook{'cn'}=$mailserveaddressbook{$email_address}{'cn'}};
          $Adddnaddressbook{'uid'}=$mailserveaddressbook{$email_address}{'uid'};
          $Adddnaddressbook{'o'}=$mailserveaddressbook{$email_address}{'o'};
          if($mailserveaddressbook{$email_address}{'cn'} eq ''){$Adddnaddressbook{'sn'} = $mailserveaddressbook{$email_address}{'uid'}}
          else{$Adddnaddressbook{'sn'} = $mailserveaddressbook{$email_address}{'cn'}};
          $Adddnaddressbook{'mail'}= $mailserveaddressbook{$email_address}{'uid'};
          $Adddnaddressbook{'ou'} = 'addressbook';
          $Adddnaddressbook{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg = $ldap->delete ( $dn);
          $result= $ldap->add ( $dn, attrs => [ %Adddnaddressbook ]);
      }
  $ldapuserdata{$email_address}{'found'} =1;
}

#Query for displaying pop_email_aliases

$query="SELECT concat(PopEmailAlias.email_address,'\@',ClientDomainDu.name),PopEmailAlias.client_id,PopEmailAlias.full_name FROM pop_email_aliases AS PopEmailAlias  LEFT JOIN pop_accounts AS PopAccount ON   (PopAccount.id = PopEmailAlias.pop_account_id) LEFT JOIN client_users AS ClientUser ON (PopAccount.client_user_id = ClientUser.id) LEFT JOIN client_domains AS ClientDomain ON (PopEmailAlias.client_domain_id = ClientDomain.id and ClientUser.client_domain_id = PopEmailAlias.client_domain_id and ClientUser.email_address = PopEmailAlias.email_address) LEFT JOIN client_domains AS ClientDomainDu ON(PopEmailAlias.client_domain_id = ClientDomainDu.id) WHERE PopAccount.client_id = 17 AND concat(ClientUser.email_address,'\@',ClientDomain.name) IS NULL AND ClientDomain.id IS NULL AND PopEmailAlias.status = 1";


$sth = $dbh->prepare($query);
$sth->execute();
while (@row = $sth->fetchrow_array)
{
      ($email,$id,$user_name)=@row;
      @row= "email=$email\no=$id\nfullname=$user_name\n";
      $mailserveusers{$email}{'uid'} = $email;
      $mailserveusers{$email}{'cn'}=$user_name; 
      $mailserveusers{$email}{'o'}=$id;
      $mailserveusers{$email}{'displayName'}=$user_name;
}


#Function for comparing both mailserve user data(pop_email_aliases)and ldap user data.

foreach $email (keys (%mailserveusers))
{
   #Checking of if mailserve data is already present in ldap
   if ($ldapuserdata{$email}{'uid'} eq $mailserveusers{$email}{'uid'} &&  $ldapuserdata{$email}{'cn'} eq $mailserveusers{$email}{'cn'} && $ldapuserdata{$email}{'o'} == $mailserveusers{$email}{'o'})#Checking of if mailserve data is already present in ldap
   {
          print "Already present in ldap\n";

   }
   #Checking for if any records in mailserve is modified
   elsif($ldapuserdata{$email}{'uid'} eq $mailserveusers{$email}{'uid'}) #Checking for if any records in mailserve is modified
   {
          $dn = 'o='.$mailserveusers{$email}{'o'}.',dc=qlc.in';
          if ($mailserveusers{$email}{'o'}) { $organizationemail{'o'} = $mailserveusers{$email}{'o'};}
          $organizationemail{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %organizationemail ] );
          $dn = 'ou=addressbook,o='.$mailserveusers{$email}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $popemaildn{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %popemaildn ] );
          $dn = 'uid='.$mailserveusers{$email}{'uid'}.',ou=addressbook,o='.$mailserveusers{$email}{'o'}.',dc=qlc.in';
          print "&&$dn\n";
          $popemaildnvalue{'cn'} = $mailserveusers{$email}{'cn'};
          if($mailserveusers{$email}{'displayName'} eq '') { $popemaildnvalue{'displayName'}=$mailserveusers{$email}{'cn'} }
          else{ $popemaildnvalue{'displayName'} = $mailserveusers{$email}{'displayName'}};
          $popemaildnvalue{'uid'}=$mailserveusers{$email}{'uid'};
          $popemaildnvalue{'o'}=$mailserveusers{$email}{'o'};
          $popemaildnvalue{'sn'} = $mailserveusers{$email}{'cn'};
          $popemaildnvalue{'mail'}= $mailserveusers{$email}{'uid'};
          $popemaildnvalue{'ou'} = 'addressbook';
          $popemaildnvalue{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $result = $ldap->add ( $dn, attrs => [ %popemaildnvalue ]);

   }
   #Checking for adding new records in LDAP
   else  
      {
          $dn = 'o='.$mailserveusers{$email}{'o'}.',dc=qlc.in';
          if ($mailserveusers{$email}{'o'}) { $Addorganizationemail{'o'} = $mailserveusers{$email}{'o'};}
          $Addorganizationemail{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap->add ( $dn, attrs => [ %Addorganizationemail ] );
          $dn = 'ou=addressbook,o='.$mailserveusers{$email}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $Adddnemail{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap->add ( $dn, attrs => [ %Adddnemail ] );
          $dn = 'uid='.$mailserveusers{$email}{'uid'}.',ou=addressbook,o='.$mailserveusers{$email}{'o'}.',dc=qlc.in';
          print "&&&&$dn\n";
          $Adddnpopemails{'cn'} = $mailserveusers{$email}{'cn'};
          $Adddnpopemails{'uid'}=$mailserveusers{$email}{'uid'};
          if($mailserveusers{$email}{'displayName'} eq '') { $Adddnpopemails{'displayName'}=$mailserveusers{$email}{'cn'} }
          else{ $Adddnpopemails{'displayName'} = $mailserveusers{$email}{'displayName'}};
          $Adddnpopemails{'o'}=$mailserveusers{$email}{'o'};
          $Adddnpopemails{'sn'} = $mailserveusers{$email}{'cn'};
          $Adddnpopemails{'mail'}= $mailserveusers{$email}{'uid'};
          $Adddnpopemails{'ou'} = 'addressbook';
          $Adddnpopemails{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];
          $mesg = $ldap->delete ( $dn);
          $result = $ldap->add ( $dn, attrs => [ %Adddnpopemails ]);
       }
  $ldapuserdata{$email}{'found'} =1;

}     


#Function for deleting pop_accounts
=pod
foreach $mysqluid (keys(%ldapuserdata)) 
{
    if($ldapuserdata{$mysqluid}{'found'}==0)
    {      
        $dn = 'uid='.$ldapuserdata{$mysqluid}{'uid'}.',ou=addressbook,o='.$ldapuserdata{$mysqluid}{'o'}.',dc=qlc.in';
        $mesg=$ldap->delete( $dn );
    }           
           
}

#Function for deleting comapany addressbook
foreach $email_address (keys(%ldapuserdata))
{
    if($ldapuserdata{$email_address}{'found'}==0)
    {
        $dn = 'uid='.$ldapuserdata{$email_address}{'uid'}.',ou=addressbook,o='.$ldapuserdata{$email_address}{'o'}.',dc=qlc.in';
        $mesg=$ldap->delete( $dn );
    }

}

#Function for deleting Ldap accounts users

foreach $uid (keys(%ldapuserdata))
{
    if($ldapuserdata{$uid}{'found'}==0)
    {
        $dn = 'uid='.$ldapuserdata{$uid}{'uid'}.',ou=people,o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
        $mesg=$ldap->delete( $dn );
    }
}

#Function for deleting pop_emails

foreach $email (keys(%ldapuserdata))
{
    if($ldapuserdata{$email}{'found'}==0)
    {
        $dn = 'uid='.$ldapuserdata{$email}{'uid'}.',ou=addressbook,o='.$ldapuserdata{$email}{'o'}.',dc=qlc.in';
        $mesg=$ldap->delete( $dn );
    }
}

=cut



