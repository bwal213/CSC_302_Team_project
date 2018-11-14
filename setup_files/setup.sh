#this is where all the setup commands go
#!/bin/bash
set -x

#
# update Ubuntu's repository
#
sudo apt -y update
#sudo apt -y upgrade                # This might not be needed

#
# setup apache2
#
sudo apt install -y apache2
sudo ufw allow in "Apache Full"
sudo systemctl enable apache2
sudo systemctl restart apache2

#
# setup nmap
#
#sudo apt-get -y install nmap        # This is not needed

#
# add files from zips
#
sudo unzip /local/repository/www.zip -d /var/ -o
sudo unzip /local/repository/apache2.zip -d /etc/ -o

#
# open port 9090 and 9999 for all communications
#
#sudo ufw allow 9090                 # I dont think this is needed either
sudo ufw allow 8888
sudo ufw allow 22
sudo ufw enable

#
# setup Anaconda
#
wget https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh
sudo bash -c "bash Anaconda3-5.3.0-Linux-x86_64.sh -b -p /opt/anaconda3"
sudo bash -c "echo 'ANACONDA_HOME=/opt/anaconda3/' >> /etc/profile"
sudo bash -c "echo 'PATH=/opt/anaconda3/bin:$PATH' >> /etc/profile"

# create a user named seed with password dees. 
sudo useradd -m -p WchOyJRR.1Qrc -s /bin/bash seed

# add seed to sudo
sudo usermod -a -G sudo seed

# set up anaconda
sudo su seed conda install -c anaconda beautifulsoup4
sudo su seed conda install -c anaconda requests
