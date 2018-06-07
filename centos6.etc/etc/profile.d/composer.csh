# Composer initialization script

# Add path to commands installed using "composer global require ..."
if ( ${uid} > 0 ) then
  if ( "${path}" !~  *${HOME}/.composer/vendor/bin* ) then
   set path = ( $path ${HOME}/.composer/vendor/bin )
  endif
endif

