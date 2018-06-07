
use strict; 
use warnings; 

sub main
{
  # Declare and initialize a hash.
  #    # In this example, both the keys
  #       # and values are strings. But
  #         # either or both could be numbers.
            my %hobbies = (
                    'Roger' => 'hang gliding',
                    'Penny' => 'diving',
                    'Peter' => 'bus surfing',
                    'Richard' => 'collects spores and fungi',
                    'Clare' => 'competitive drinking',
                     'Lisa' => 'pole vaulting',
                      );
                                                   
                                                      # Add another value to the hash.
                   $hobbies{'John'} = 'running';
                                                           
                                                              # Delete a key-value pair from the hash.
                   delete $hobbies{'Peter'};
                                                                   
                                                                      # Access a value.
                   print "Richard's hobby: ", $hobbies{'Richard'}, "n";
                                                                           
                                                                              # Let's print (display) the entire hash, just
                                                                                # for fun. Note that we use a backslash  on the 
                                                                                   # hash's name. This gives us a reference to 
                                                                                      # the hash, which we pass to Dumper() to
                                                                                         # format the hash as a string for display.
                  use Data::Dumper;
                  print Dumper(%hobbies);
}
  
                 main();
