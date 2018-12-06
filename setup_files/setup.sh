#this is where all the setup commands go
#!/bin/bash
set -x

#
# update Ubuntu's repository
#
sudo apt -y update
#sudo apt -y upgrade                # This might not be needed

#
# setup git and gdb-peda
#
sudo apt install git -y
sudo su seed -p -c "git clone https://github.com/longld/peda.git ~/peda"
sudo su seed -p -c 'echo "source ~/peda/peda.py" >> ~/.gdbinit'

#
# setup apache2
#
sudo apt install -y apache2
sudo ufw allow in "Apache Full"
sudo systemctl enable apache2

sudo apt install -y mysql-server
sudo mysql -e"FLUSH PRIVILEGES;"
sudo mysql -e"set password for 'root'@'localhost' ='seedubuntu';"
sudo mysql -uroot -pseedubuntu < /local/repository/setup_files/Seed_Databases.sql
sudo mysql -e"FLUSH PRIVILEGES;"
sudo mysql -e"set password for 'root'@'localhost' ='seedubuntu';"
mysql -uroot -pseedubuntu "set password for 'phpmyadmin'@'localhost' ='seedubuntu';"
#sudo mysqladmin -uroot password seedubuntu
sudo apt install -y php libapache2-mod-php php-mysqlnd
sudo env DEBIAN_FRONTEND=noninteractive apt -yq install phpmyadmin

#
# setup nmap
#
#sudo apt-get -y install nmap        # This is not needed

#
# add files from zips
#
sudo \cp -Rf /local/repository/setup_files/www /var/
sudo \cp -Rf /local/repository/setup_files/apache2 /etc/
sudo \cp -Rf /local/repository/setup_files/php /etc/
sudo \cp -Rf /local/repository/setup_files/phpmyadmin /etc/
sudo \cp -Rf /local/repository/setup_files/mysql /etc/

#sudo a2enmod rewrite
sudo a2dismod mpm_event
sudo a2dismod php7.0
sudo a2enmod php7.2
sudo systemctl restart apache2

#
# open port 9090 and 9999 for all communications
#
#sudo ufw allow 9090                 # I dont think this is needed either

sudo ufw allow 8888
sudo ufw allow 22
sudo ufw --force enable

#
# setup Anaconda
#
wget https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh
sudo bash -c "bash Anaconda3-5.3.0-Linux-x86_64.sh -b -p /opt/anaconda3"
#sudo bash -c "echo 'ANACONDA_HOME=/opt/anaconda3/' >> /etc/profile"
sudo bash -c "echo 'PATH="/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' > /etc/environment"
#sudo bash -c "echo 'unset XDG_RUNTIME_DIR' >> /etc/profile"
sudo bash -c "echo 'ANACONDA_HOME=/opt/anaconda3/' >> /etc/environment"
#sudo bash -c "echo 'PATH=/opt/anaconda3/bin:$PATH' >> /etc/profile"

# create a user named seed with password dees. 
sudo useradd -m -p WchOyJRR.1Qrc -s /bin/bash seed

# update root password
# sudo usermod -p WcQ5Q3no8GLAk root
sudo usermod -p $1$WchOyJRR$8RusOKWnvIwQofuLA.eUG. root

# add seed to sudo
sudo usermod -aG sudo seed
sudo usermod -aG root seed
sudo su seed -c "touch ~/.sudo_as_admin_successful"
#sudo su seed -p -c "source /etc/profile"
sudo su seed -c "cd ~/ && unset XDG_RUNTIME_DIR && nohup jupyter notebook --NotebookApp.token='' --ip * --no-browser > ~/nohup_jupyter.out &"
#sudo su seed -p -c "unset ETC_RUNTIME_DIR && source /etc/profile && jupyter notebook --NotebookApp.token='' --ip * --no-browser"

# set up anaconda
sudo su seed -c "conda install -c anaconda beautifulsoup4"
sudo su seed -c "conda install -c anaconda requests"
