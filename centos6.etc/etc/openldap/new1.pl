 #!/usr/bin/perl
 
 require DBI;
 use Net::LDAP;
 use Digest::SHA1;
 use MIME::Base64;
 use Net::LDAP::Entry;
 use Data::Dumper;

 $ldap = Net::LDAP->new( 'localhost' );

#LDAP bind function
#
$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'qlc');

##Mysql database connectivity.
#
$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=localhost', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";
$dn = 'dc=qlc.in';
$mesg = $ldap->search( base => $dn,  filter =>"cn=*", attrs => ['cn','displayName','ou','o','userPassword']);

@entries = $mesg->entries;


foreach $entry (@entries) {
        my $attr=$entry->dn();
        
       $mesg = $ldap->delete( $attr );
       # print "dn: " . $entry->dn() . "\n";
       # exit; 
}




 #!/usr/bin/perl
=c require DBI;
 use Net::LDAP;
 use Digest::SHA1;
 use MIME::Base64;
 use Net::LDAP::Entry;
 use Data::Dumper;

my %mailserve;
my %ldapuserdata;
my %ldapuserdata1;
my %popdnvalue;
my %Addpoporganization;
my %Addpopdnvalues;
my %Addpopdnvalue;
my %organizationpoparray;
my %Array2;


my %ldapdnarray;
my %addorganizationldap;
my %addldapdn;
my %addldapdnarray;
my %organizationldap;
my %ldapdnvalue;


sub trim($)
{
     my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

sub ltrim($)
{
         my $string = shift;
         $string =~ s/^\s+//;
         return $string;
}

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

$ldap = Net::LDAP->new( '192.168.1.187' );

$mesg = $ldap->bind( 'cn=Manager,dc=qlc.in',password=>'qlc');

$ldap1 = Net::LDAP->new( '192.168.1.185' );

$mesg2 = $ldap1->bind( 'cn=Manager,dc=qlc.in',password=>'vishnu');

$dn = 'dc=qlc.in';
 
$mesg1 = $ldap->search( base => $dn,  filter =>"(objectClass=*)", attrs => ['cn','ou','o','userPassword','uid','mobile']);

$mesg3 = $ldap1->search( base => $dn,  filter =>"(objectClass=*)", attrs => ['cn','ou','o','userPassword','uid','mobile']);

$dbh = DBI->connect('DBI:mysql:mailserve_v03;host=192.168.1.184', 'mailserve', 'mail1234') || die "Could not connect to database: $DBI::errstr";

my $entry;

my $entryldap;

my @entries = $mesg1->entries;

my @entries1 = $mesg3->entries;

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


my $entryldap;

my @entries1 = $mesg3->entries;
foreach $entryldap (@entries1)
{
        my $attr;
        $cn = "";
        $o = "";
        $displayName = "";
        foreach $attr ( sort $entryldap->attributes )
        {
              $cn = $entryldap->get_value("cn");
              $o = $entryldap->get_value("o");
              $ou=$entryldap->get_value("ou");
              $uid1=$entryldap->get_value("uid");
              $mobile=$entryldap->get_value("mobile");
              $displayName = $entryldap->get_value("displayName");
              $pass= $entryldap->get_value("userPassword");
        }

        $ldapuserdata1{$uid1}{'cn'}   = $cn;
        $ldapuserdata1{$uid1}{'ou'}   = $ou;
        $ldapuserdata1{$uid1}{'mobile'}   = $mobile;
        $ldapuserdata1{$uid1}{'o'}   = $o;
        $ldapuserdata1{$uid1}{'uid'} = $uid1;
        $ldapuserdata1{$uid1}{'displayName'}   = $displayName;
        $ldapuserdata1{$uid1}{'userPassword'} =$pass;
        $ldapuserdata1{$uid1}{'found'} =0;
}

foreach $uid (keys (%ldapuserdata))
{
     if ($ldapuserdata1{$uid}{'uid'} eq $ldapuserdata{$uid}{'uid'} &&  $ldapuserdata1{$uid}{'cn'} eq $ldapuserdata{$uid}{'cn'} && $ldapuserdata1{$uid}{'o'} == $ldapuserdata{$uid}{'o'})
     {
          print "Already present in ldap\n";
     }
   elsif($ldapuserdata1{$uid}{'uid'} eq $ldapuserdata{$uid}{'uid'})
     {

          $dn = 'o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
          if ($ldapuserdata{$uid}{'o'}) { $organizationpoparray{'o'} = $ldapuserdata{$mysqluid}{'o'};}
          $organizationpoparray{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap1->add ( $dn, attrs => [ %organizationpoparray ] );
          $dn = 'ou=pmeaddressbook,o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $Array2{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap1->add ( $dn, attrs => [ %Array2 ] );
          $dn = 'uid='.$ldapuserdata{$uid}{'uid'}.',ou=pmeaddressbook,o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
          print "==$dn\n";
          if($ldapuserdata{$uid}{'cn'} eq ''){$popdnvalue{'cn'}=$ldapuserdata{$uid}{'uid'}}
          else{$popdnvalue{'cn'} = $ldapuserdata{$uid}{'cn'}};
          $popdnvalue{'uid'}=$ldapuserdata{$uid}{'uid'};
          if($ldapuserdata{$uid}{'mobile'} eq '') { $popdnvalue{'mobile'}=9999999999}
          else{ $popdnvalue{'mobile'} = $ldapuserdata{$uid}{'mobile'}};
          $popdnvalue{'o'}=$ldapuserdata{$uid}{'o'};
          if($ldapuserdata{$uid}{'cn'} eq ''){$popdnvalue{'sn'}=$ldapuserdata{$uid}{'uid'}}
          else{$popdnvalue{'sn'} = $ldapuserdata{$uid}{'cn'}};
           $popdnvalue{'mail'}= $ldapuserdata{$uid}{'uid'};
          $popdnvalue{'ou'} = 'pmeaddressbook';
          $popdnvalue{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap1->delete ( $dn);
          $result = $ldap1->add ( $dn, attrs => [ %popdnvalue ]);
      }
      else
      {
           $dn = 'o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
          if ($ldapuserdata{$uid}{'o'}) { $Addpoporganization{'o'} = $ldapuserdata{$uid}{'o'};}
          $Addpoporganization{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap1->add ( $dn, attrs => [ %Addpoporganization ] );
          $dn = 'ou=pmeaddressbook,o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
          $Addpopdnvalue{'ou'} = 'pmeaddressbook';
          $Addpopdnvalue{'objectclass'} = ['top', 'organizationalUnit'];
          print "$dn \n";
          $result = $ldap1->add ( $dn, attrs => [ %Addpopdnvalue ] );
          $dn = 'uid='.$ldapuserdata{$uid}{'uid'}.',ou=pmeaddressbook,o='.$ldapuserdata{$uid}{'o'}.',dc=qlc.in';
          print "====$dn\n";
          my ($email, $domain) = split('@',$ldapuserdata{$uid}{'uid'});
          $Addpopdnvalues{'uid'}=$ldapuserdata{$uid}{'uid'};
          if($ldapuserdata{$uid}{'cn'} eq '') {$Addpopdnvalues{'cn'}=$ldapuserdata{$uid}{'uid'} }
          else{ $Addpopdnvalues{'cn'} = $ldapuserdata{$uid}{'cn'}};
          $Addpopdnvalues{'o'}=$ldapuserdata{$uid}{'o'};
          if($ldapuserdata{$uid}{'cn'} eq ''){$Addpopdnvalues{'sn'}=$ldapuserdata{$uid}{'uid'}}
          else{$Addpopdnvalues{'sn'} = $ldapuserdata{$uid}{'cn'}};
          if($ldapuserdata{$uid}{'mobile'} eq '') { $Addpopdnvalues{'mobile'}=9999999999 }
          else{ $Addpopdnvalues{'mobile'} = $ldapuserdata{$uid}{'mobile'}};
          $Addpopdnvalues{'mail'}= $ldapuserdata{$uid}{'uid'};
          $Addpopdnvalues{'ou'} = 'pmeaddressbook';
          $Addpopdnvalues{'objectclass'} = ['top', 'person', 'organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap1->delete ( $dn);
           $result = $ldap1->add ( $dn, attrs => [ %Addpopdnvalues ]);
     }
    $ldapuserdata1{$uid}{'found'} =1;

}



$query5="select concat(client_users.email_address,\'@\',client_domains.name)as cn,client_users.client_id as o,client_users.full_name as first_name,client_users.password from client_users  INNER JOIN client_domains  on client_domains.id=client_users.client_domain_id INNER JOIN clients  on clients.id=client_users.client_id INNER JOIN ldap_accounts  on client_users.id=ldap_accounts.client_user_id where ldap_accounts.status=1  and client_users.client_id=34095";


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
foreach $uid (keys (%mailserve))
{
      if ($ldapuserdata1{$uid}{'uid'} eq $mailserve{$uid}{'uid'} && $ldapuserdata1{$uid}{'o'} == $mailserve{$uid}{'o'} && $ldapuserdata1{$uid}{'cn'} eq  $mailserve{$uid}{'cn'} && $ldapuserdata1{$uid}{'userPassword'} eq  $mailserve{$uid}{'userPassword'})
    {
          print "Already present in ldap\n";

    }
     elsif($ldapuserdata1{$uid}{'uid'} eq $mailserve{$uid}{'uid'})
    {
          $dn = 'o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          if ($mailserve{$uid}{'o'}) { $organizationldap{'o'} = $mailserve{$uid}{'o'};}
          $organizationldap{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap1->add ( $dn, attrs => [ %organizationldap ] );
          $dn = 'ou=pmeuser,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $ldapdnvalue{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap1->add ( $dn, attrs => [ %ldapdnvalue ] );
          $dn = 'uid='.$mailserve{$uid}{'uid'}.',ou=pmeuser,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "**$dn\n";
          $ldapdnarray{'cn'} = $mailserve{$uid}{'cn'};
          $ldapdnarray{'uid'}=$mailserve{$uid}{'uid'};
          $ldapdnarray{'o'}=$mailserve{$uid}{'o'};
          $ldapdnarray{'sn'} = $mailserve{$uid}{'cn'};
          $ldapdnarray{'mail'}= $mailserve{$uid}{'uid'};
          $ldapdnarray{'userPassword'} = $mailserve{$uid}{'userPassword'} ;
          $ldapdnarray{'ou'} = 'pmeuser';
          $ldapdnarray{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap1->delete ( $dn);
          $result = $ldap1->add ( $dn, attrs => [ %ldapdnarray ]);
     }
    else
     {
          $dn = 'o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          if ($mailserve{$uid}{'o'}) { $addorganizationldap{'o'} = $mailserve{$uid}{'o'};}
          $addorganizationldap{'objectclass'} = ['top', 'organization'];
          print "$dn \n";
          $result = $ldap1->add ( $dn, attrs => [ %addorganizationldap ] );
          $dn = 'ou=pmeuser,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "$dn \n";
          $addldapdn{'objectclass'} = ['top','organizationalUnit' ];
          $result = $ldap1->add ( $dn, attrs => [ %addldapdn ] );
          $dn = 'uid='.$mailserve{$uid}{'uid'}.',ou=pmeuser,o='.$mailserve{$uid}{'o'}.',dc=qlc.in';
          print "****$dn\n";
          $addldapdnarray{'cn'} = $mailserve{$uid}{'cn'};
          if($mailserve{$uid}{'displayName'} eq '') { $addldapdnarray{'displayName'}=$mailserve{$uid}{'cn'} }
          else{ $addldapdnarray{'displayName'} = $mailserve{$uid}{'displayName'}};
          $addldapdnarray{'uid'}=$mailserve{$uid}{'uid'};
          $addldapdnarray{'o'}=$mailserve{$uid}{'o'};
          $addldapdnarray{'sn'} = $mailserve{$uid}{'cn'};
          $addldapdnarray{'mail'}= $mailserve{$uid}{'uid'};
          $addldapdnarray{'userPassword'} = $mailserve{$uid}{'userPassword'} ;
          $addldapdnarray{'ou'} = 'pmeuser';
          $addldapdnarray{'objectclass'} = ['top', 'person','organizationalPerson', 'inetOrgPerson' ];
          $mesg= $ldap1->delete ( $dn);
          $result = $ldap1->add ( $dn, attrs => [ %addldapdnarray ]);
     }
 $ldapuserdata1{$uid}{'found'} =1;
}



    























=c$query5 = "select distinct client_id from client_domains";
      # print $query5;
             # exit;
$sth5 = $dbh->prepare($query5);
$sth5->execute();
while (@row5 = $sth5->fetchrow_array) {
      
($id)=@row5;
$dn ='o='.$id.',dc=qlc.in';

#print $dn;
#exit;
$mesg = $ldap->delete( $dn );
}

=cut





