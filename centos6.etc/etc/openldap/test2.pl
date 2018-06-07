use Data::Dumper;

my %hobbies = (
   'Roger' => 'hang gliding',
 'Penny' => 'diving',
   'Peter' => 'bus surfing',
  'Richard' => 'collects spores and fungi',
  'Clare' => 'competitive drinking',
 'Lisa' => 'pole vaulting',
);

# Iterate over the hash using each.

# print "nUsing each: n";
  while( my ($name, $hobby) = each %hobbies ) {
  # print "$name: $hobby\n";
   }

 foreach my $name(keys %hobbies) {
   my $hobby = $hobbies{$name};
   
  # print "$name: $hobby\n";
}


@fruit = ("apples", 6, "cherries", 8, "oranges", 11);

#print "--@fruit";
#exit;

%fruit = @fruit;

#print Dumper %fruit;
#exit; 

my %color_of;

my $fruit = 'apple';
$color_of{$fruit} = 'red';

#print $fruit;
#exit;



my %color_of = (
    apple  => "red",
    orange => "orange",
    grape  => "purple",
);

my @fruits = keys %color_of;
for my $fruit (@fruits) {
    print "The color of '$fruit' is $color_of{$fruit}\n";
}







