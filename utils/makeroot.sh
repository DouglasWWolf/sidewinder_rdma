# This short script will make the pcireg utility execute 
# as the root user
#
# Once this script has been run, be sure to put pcireg,
# hot_reset,  and show_device somewhere convenient in the
# executable search path.     

sudo chown root pcireg
sudo chgrp root pcireg
sudo chmod 4777 pcireg

