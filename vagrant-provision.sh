#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install build-essential ruby1.9.1-dev mysql-server libmysqlclient-dev git libmagickwand-dev
gem install bundler

wget -O redmine-2.5.1.tar.gz http://www.redmine.org/releases/redmine-2.5.1.tar.gz
tar xvzf redmine-2.5.1.tar.gz
ln -s redmine-2.5.1 redmine

cp /vagrant/config/database.yml redmine/config/
cp /vagrant/config/Gemfile.local redmine/
cp /vagrant/config/redmine.conf /etc/init/

mysql -uroot -e "CREATE DATABASE redmine CHARACTER SET utf8;" 2>/dev/null
mysql -uroot -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'redmine';" 2>/dev/null
mysql -uroot -e "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';" 2>/dev/null

cd redmine 
sudo bundle install --without development test
rake generate_secret_token

RAILS_ENV=production rake db:migrate
RAILS_ENV=production REDMINE_LANG=en rake redmine:load_default_data

mkdir -p tmp tmp/pdf public/plugin_assets
sudo chown -R vagrant:vagrant files log tmp public/plugin_assets
sudo chmod -R 755 files log tmp public/plugin_assets

initctl start redmine
