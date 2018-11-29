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

#sudo apt install mysql-server
#sudo apt install php libapache2-mod-php php-mysqlnd
#sudo apt install phpmyadmin

#sudo a2enmod rewrite

sudo systemctl restart apache2

#
# setup nmap
#
#sudo apt-get -y install nmap        # This is not needed

#
# add files from zips
#
#sudo unzip -o /local/repository/setup_files/www.zip -d /var/
#sudo unzip -o /local/repository/setup_files/apache2.zip -d /etc/

#
# open port 9090 and 9999 for all communications
#
#sudo ufw allow 9090                 # I dont think this is needed either

sudo ufw allow 8888
sudo ufw allow 22
sudo ufw enable -y

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
sudo su seed -p -c "touch ~/.sudo_as_admin_successful"
#sudo su seed -p -c "source /etc/profile"
sudo su seed -p -c "jupyter notebook --NotebookApp.token='' --ip * --no-browser"
#sudo su seed -p -c "unset ETC_RUNTIME_DIR && source /etc/profile && jupyter notebook --NotebookApp.token='' --ip * --no-browser"

# set up anaconda
sudo su seed -c "conda install -c anaconda beautifulsoup4"
sudo su seed -c "conda install -c anaconda requests"
