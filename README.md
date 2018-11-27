# CSC_302_Team_project
A repository for instantiation on cloudlab to complete the team project.


TODO:

Fix config for apache2 in /etc/apache2/mods-enabled
      -set the php version in php7.0.load, to use libphp7.2.so
      -use a2dismod mpm_event to fix mpm conflict
      -restart apache with sudo systemctl restart apache2
      
Make sure these get installed
      sudo apt-get install mysql-server
      sudo apt-get install php libapache2-mod-php php-mysqlnd
      sudo apt-get install phpmyadmin
      -WARNING phpmyadmin requires answering questions during setup, look into flags.
      sudo a2enmod rewrite
      -rewrite should already be enabled
      
Setup jupyterhub

Check for the database needed for elgg

Check about pre editing files before copy so that they are good to go upon copy

Make sure /etc/apache2/sites-enabled/000-default.conf & /etc/apache2/sites-available/000-default.conf 
  both have root directory set to /var/www
