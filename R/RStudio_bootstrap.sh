#/bin/bash

# AWS EMR bootstrap script 
# for installing RStudio server on AWS EMR master node
#
# tested with AMI 3.1.1 (hadoop 2.4.0)
#
# schmidbe@amazon.de
# 26. August 2014
##############################

# create rstudio user on all machines
# we need a unix user with home directory and password and hadoop permission
sudo adduser rstudio
sudo sh -c "echo 'rstudio' | passwd rstudio --stdin"

# check for master node using security group name
secgroup=$(curl http://169.254.169.254/latest/meta-data/security-groups)

# only run if master node
if [ "$secgroup" == "ElasticMapReduce-master" ]
then
  # install Rstudio server
  # please check and update for latest RStudio version
  wget http://download2.rstudio.org/rstudio-server-0.98.983-x86_64.rpm
  sudo yum install --nogpgcheck -y rstudio-server-0.98.983-x86_64.rpm
  
  # change port - 8787 will not work for many companies
  sudo sh -c "echo 'www-port=80' >> /etc/rstudio/rserver.conf"
  sudo rstudio-server restart  
  
  # and copy R example scripts to user's home dir amd set permission
  wget --no-check-certificate https://s3-eu-west-1.amazonaws.com/schmidbe/emR/rmr2_example.R
  wget --no-check-certificate https://s3-eu-west-1.amazonaws.com/schmidbe/emR/biganalyses_example.R
  sudo mv *.R /home/rstudio/.
  sudo chown rstudio:rstudio -Rf /home/rstudio
fi