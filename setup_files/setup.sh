#!/bin/bash
set -x

#
# Update Ubuntu's repository
#
sudo apt -y update

#
# Install & setup apache2
#
sudo apt install -y apache2
sudo ufw allow in "Apache Full"
sudo systemctl enable apache2

#
# Install mysql for Elgg
#
sudo apt install -y mysql-server

#
# Configure mysql
# Make sure the database can be added.
#
sudo mysql -e"FLUSH PRIVILEGES;"
sudo mysql -e"set password for 'root'@'localhost' ='seedubuntu';"

#
# Add the seed labs database
#
sudo mysql -uroot -pseedubuntu < /local/repository/setup_files/Seed_Databases.sql

#
# Configure mysql
# Make sure the correct passwords are set and all permissions are good.
#
sudo mysql -e"FLUSH PRIVILEGES;"
sudo mysql -e"set password for 'root'@'localhost' ='seedubuntu';"
mysql -uroot -pseedubuntu "set password for 'phpmyadmin'@'localhost' ='seedubuntu';"
#sudo mysqladmin -uroot password seedubuntu

#
# Install dependencies for Elgg
#
sudo apt install -y php libapache2-mod-php php-mysqlnd
sudo env DEBIAN_FRONTEND=noninteractive apt -yq install phpmyadmin
sudo apt install -y composer

#
# Add files from seed labs
# There is also the original zips they came from in that directory.
# They were unpackaged so specific files could be edited, they are also a bit easier to copy this way.
#
sudo \cp -Rf /local/repository/setup_files/www /var/
sudo \cp -Rf /local/repository/setup_files/elgg /var/
sudo \cp -Rf /local/repository/setup_files/apache2 /etc/
sudo \cp -Rf /local/repository/setup_files/php /etc/
sudo \cp -Rf /local/repository/setup_files/phpmyadmin /etc/
sudo \cp -Rf /local/repository/setup_files/mysql /etc/

#
# Disable Apache2 mods
# These were in seed labs but conflict with the new versions of things.
#
sudo a2dismod mpm_event
sudo a2dismod php7.0

#
# Enable Apache2 mods
# Need to enable the most recent version of php.
#
sudo a2enmod php7.2

#
# Restart Apache2 to apply changes.
#
sudo systemctl restart apache2

#
# Open port 8888 and 22 then enable the firewall
# Used for jupyter and ssh respectivly
#
sudo ufw allow 8888
sudo ufw allow 22
sudo ufw --force enable

#
# Setup Anaconda
# Legacy path commands are left incase needed in the future.
#
wget https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh
sudo bash -c "bash Anaconda3-5.3.0-Linux-x86_64.sh -b -p /opt/anaconda3"
#sudo bash -c "echo 'ANACONDA_HOME=/opt/anaconda3/' >> /etc/profile"
sudo bash -c "echo 'PATH="/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' > /etc/environment"
#sudo bash -c "echo 'unset XDG_RUNTIME_DIR' >> /etc/profile"
sudo bash -c "echo 'ANACONDA_HOME=/opt/anaconda3/' >> /etc/environment"
#sudo bash -c "echo 'PATH=/opt/anaconda3/bin:$PATH' >> /etc/profile"
#sudo su seed -p -c "source /etc/profile"

#
# Create a user named seed with password dees. 
#
sudo useradd -m -p WchOyJRR.1Qrc -s /bin/bash seed

#
# Update root password
# 
sudo usermod -p WcQ5Q3no8GLAk root

#
# Add seed to sudo and root for jupyter
#
sudo usermod -aG sudo seed
sudo usermod -aG root seed

#
# Touch the file so that sudo message goes away.
#
sudo su seed -c "touch ~/.sudo_as_admin_successful"

#
# Start jupyter notebook as seed
# This uses nohup, and outputs to a file in the /home/seed directory.
# Not configured for a error file.
#
sudo su seed -c "cd ~/ && unset XDG_RUNTIME_DIR && nohup jupyter notebook --NotebookApp.token='' --ip * --no-browser > ~/nohup_jupyter.out &"

#
# Install git and gdb-peda
#
sudo apt install git -y
sudo mkdir /var/peda
git clone https://github.com/longld/peda.git /var/peda
#sudo su seed -c 'git clone https://github.com/longld/peda.git ~/peda'
sudo su seed -c 'echo "source /var/peda/peda.py" >> ~/.gdbinit'

#
# Add the class repository so it can be seen from jupyter
#
sudo su seed -c 'git clone https://github.com/linhbngo/Computer-Security.git ~/Computer-Security/'

#
# Get new elgg then unzip
#
sudo mkdir /var/setup
wget https://elgg.org/about/getelgg?forward=elgg-2.3.9.zip -O /var/setup/elgg-2.3.9.zip
cd /var/setup && unzip elgg-2.3.9.zip
#sudo su seed -c "wget https://elgg.org/about/getelgg?forward=elgg-2.3.9.zip -O /var/setup/elgg-2.3.9.zip"
#sudo su seed -c "cd ~/setup && unzip elgg-2.3.9.zip"

#
# Overwrite old elgg installs from seed lab
# This needs to be done, as there are errors that are fixed in the latest version.
# The old version seemed to be incompatible with php7.2.
#
sudo \cp -Rf /var/setup/elgg-2.3.9/* /var/www/CSRF/Elgg/
sudo \cp -Rf /var/setup/elgg-2.3.9/* /var/www/XSS/Elgg/

#
# Get current public IP and make it into a system-wide system variable
#
sudo su root -c "echo IPADDR=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' -m1) >> /etc/environment"

#
# Source the new system variable to make sure it is useable
#
source /etc/environment

#
# Create text files that contain the URL of the web pages.
# This will be used to input them into the database.
#
sudo echo -n 'http://' > /var/setup/CSRFurl.txt; echo -n $IPADDR >> /var/setup/CSRFurl.txt; echo -n '/CSRF/Elgg/' >> /var/setup/CSRFurl.txt
sudo echo -n 'http://' > /var/setup/XSSurl.txt; echo -n $IPADDR >> /var/setup/XSSurl.txt; echo -n '/XSS/Elgg/' >> /var/setup/XSSurl.txt
#sudo su seed -c "echo -n 'http://' > /var/setup/CSRFurl.txt; echo -n $IPADDR >> /var/setup/CSRFurl.txt; echo -n '/CSRF/Elgg/' >> /var/setup/CSRFurl.txt"
#sudo su seed -c "echo -n 'http://' > /var/setup/XSSurl.txt; echo -n $IPADDR >> /var/setup/XSSurl.txt; echo -n '/XSS/Elgg/' >> /var/setup/XSSurl.txt"

#
# These are legacy commands that helped to establish how to use thier seperate parts 
#
##sudo su seed -c "testingip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' -m1); echo -n '"'; echo -n $testingip> ~/ip.txt; echo -n '/CSRF/Elgg' >> ~/ip.txt"
##echo -n $testingip > ~/ip.txt; echo -n '/CSRF/Elgg/' >> ~/ip.txt

#
# Copy the text files to where mysql can see them
#
sudo \cp -f /var/setup/CSRFurl.txt /var/lib/mysql-files/
sudo \cp -f /var/setup/XSSurl.txt /var/lib/mysql-files/

#
# Load the data in the files into the database to replace the old site URLs
#
mysql -uroot -pseedubuntu -e 'UPDATE 'elgg_csrf'.'elgg_sites_entity' SET url=LOAD_FILE("/var/lib/mysql-files/CSRFurl.txt") WHERE guid=1;'
mysql -uroot -pseedubuntu -e 'UPDATE 'elgg_csrf'.'elgg_csrfsites_entity' SET url=LOAD_FILE("/var/lib/mysql-files/CSRFurl.txt") WHERE guid=1;'
mysql -uroot -pseedubuntu -e 'UPDATE 'elgg_xss'.'elgg_xsssites_entity' SET url=LOAD_FILE("/var/lib/mysql-files/XSSurl.txt") WHERE guid=1;'

#
# These commands are very useful for debugging and finding what to replace
#
#sudo grep -r "csrflabelgg" /var/
#sudo grep -r "xsslabelgg" /var/

#
# Replace the old URL with the new one in the cache files
#
sudo sed -i -- "s@http:\/\/www.csrflabelgg.com@http:\/\/$IPADDR\/CSRF\/Elgg@g" /var/elgg/csrf/views_simplecache/1501099611/default/*.js
sudo sed -i -- "s@http://www.csrflabelgg.com@http://$IPADDR/CSRF/Elgg@g" /var/elgg/csrf/views_simplecache/1501099611/default/elgg/*.js
sudo sed -i -- "s@http://www.csrflabelgg.com@http://$IPADDR/CSRF/Elgg@g" /var/elgg/csrf/views_simplecache/1501099611/default/*.css
sudo sed -i -- "s@http:\/\/www.xsslabelgg.com@http:\/\/$IPADDR\/XSS\/Elgg@g" /var/elgg/xss/views_simplecache/1501099743/default/*.js
sudo sed -i -- "s@http://www.xsslabelgg.com@http://$IPADDR/XSS/Elgg@g" /var/elgg/xss/views_simplecache/1501099743/default/elgg/*.js
sudo sed -i -- "s@http://www.xsslabelgg.com@http://$IPADDR/XSS/Elgg@g" /var/elgg/xss/views_simplecache/1501099743/default/*.css

#
# Set the permissions so elgg can modify them
# Yes, 777 is excessive, but I wanted to be sure.
#
sudo chmod -R 777 /var/elgg
sudo chmod -R 777 /var/www

#
# Run the files to have elgg recognize the new version and change things accordingly
# After this command the sites should be good to go, and able to be logged into.
#
sudo su seed -c 'php /var/www/CSRF/Elgg/upgrade.php'
sudo su seed -c 'php /var/www/XSS/Elgg/upgrade.php'

#
# Needed for a finished product. ;)
# Thanks for a great semester Dr. Ngo!
# This was one heck of a challenge.
#
sudo apt -y install sl

#
# Set up anaconda
# This might not be needed, but helps so the students don't have to sit around so long at the start of class
#
sudo su seed -c "conda install -c anaconda beautifulsoup4"
sudo su seed -c "conda install -c anaconda requests"
