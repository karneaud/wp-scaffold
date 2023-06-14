#! /bin/bash
REPO_FOLDER="/workspaces/$RepositoryName"
SYMLNK_FOLDER="$REPO_FOLDER/wordpress/wp-content/plugins/$PLUGIN_NAME"

# Create Wordpress Folder
# Check if the "./wordpress" directory exists
if [ ! -d "$REPO_FOLDER/wordpress" ]; then
  echo "Creating the $REPO_FOLDER/wordpress directory..."
  mkdir "$REPO_FOLDER/wordpress"
fi

# Apache
sudo chmod 777 /etc/apache2/sites-available/000-default.conf
sudo sed "s@.*DocumentRoot.*@\tDocumentRoot $PWD/wordpress@" .devcontainer/000-default.conf > /etc/apache2/sites-available/000-default.conf
update-rc.d apache2 defaults 
service apache2 start

LOCALE="en_GB"

# WordPress Core install
wp core download --locale=$LOCALE --path=wordpress
cd wordpress
wp config create --dbname=$(MYSQL_DATABASE) --dbuser=$(MYSQL_USER) --dbpass=$(MYSQL_PASSWORD) --dbhost=$(MYSQL_HOST)
LINE_NUMBER=`grep -n -o 'stop editing!' wp-config.php | cut -d ':' -f 1`
sed -i "${LINE_NUMBER}r ../.devcontainer/wp-config-addendum.txt" wp-config.php && sed -i -e "s/CODESPACE_NAME/$CODESPACE_NAME/g"  wp-config.php
wp core install --url=https://$(CODESPACE_NAME) --title=$(WORDPRESS_TITLE) --admin_user=$(WORDPRESS_USER) --admin_password=$(WORDPRESS_PASSWORD)--admin_email=$(GIT_COMMITTER_EMAIL)

# Demo content for WordPress
wp plugin install wordpress-importer --activate
curl https://raw.githubusercontent.com/WPTT/theme-unit-test/master/themeunittestdata.wordpress.xml > demo-content.xml
wp import demo-content.xml --authors=create
rm demo-content.xml

#Xdebug
echo xdebug.log_level=0 | sudo tee -a /usr/local/etc/php/conf.d/xdebug.ini

# install dependencies
cd $REPO_FOLDER
composer install

# Setup local plugin
# Create the symlink from "./src" to "./wordpress/wp-content/plugins/src"
if [ ! -L "$REPO_FOLDER/src" ]; then
  echo "Creating the symlink from $REPO_FOLDER/src to $SYMLINK_FOLDER..."
  ln -s "$(pwd)/$REPO_FOLDER/src" "$SYMLINK_FOLDER"
fi
echo "Setup completed successfully!"

# Install some essential WP plugins
wp plugin install query-monitor wp-mail-smtp
wp plugin activate query-mnoitor wp-mail-smtp

# Setup bash
echo export PATH=\"\$PATH:$REPO_FOLDER/src/vendor/bin\" >> ~/.bashrc
echo "cd $REPO_FOLDER/wordpress" >> ~/.bashrc
source ~/.bashrc
