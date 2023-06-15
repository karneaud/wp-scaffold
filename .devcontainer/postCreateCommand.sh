#! /bin/bash
REPO_FOLDER="/workspaces/$RepositoryName"
SYMLINK_FOLDER="$REPO_FOLDER/wordpress/wp-content/plugins/$PLUGIN_NAME"

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

LOCALE="en_US"

# WordPress Core install
echo "Setup $WORDPRESS_TITLE"
wp core download --locale=$LOCALE --path=wordpress

if [  ! -f "./wordpress/wp-config.php" ]; then
  echo "Create wp-config.php"
  wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_USER_PASSWORD --dbhost=$MYSQL_HOST --path=./wordpress
  LINE_NUMBER=`grep -n -o 'Add any custom values between this line' ./wordpress/wp-config.php | cut -d ':' -f 1`
  sed -i "${LINE_NUMBER}r ./.devcontainer/wp-config-addendum.txt" ./wordpress/wp-config.php && sed -i -e "s/CODESPACE_NAME/$CODESPACE_NAME/g"  ./wordpress/wp-config.php
  echo "Install with user ${WORDPRESS_USER:-$GITHUB_USER}"
  wp core install --url="https://$CODESPACE_NAME-80.preview.app.github.dev/" --title="$WORDPRESS_TITLE" --admin_user=${WORDPRESS_USER:-$GITHUB_USER} --admin_password=$WORDPRESS_USER_PASSWORD --admin_email=$WORDPRESS_USER_EMAIL --path=./wordpress
  # Install some essential WP plugins
  wp plugin install query-monitor --activate --path=./wordpress

  # Demo content for WordPress
  wp plugin install wordpress-importer --activate --path=./wordpress
  curl https://raw.githubusercontent.com/WPTT/theme-unit-test/master/themeunittestdata.wordpress.xml > demo-content.xml
  wp import demo-content.xml --path=./wordpress
  rm demo-content.xml
fi
#Xdebug
echo xdebug.log_level=0 | sudo tee -a /usr/local/etc/php/conf.d/xdebug.ini

# install dependencies
composer install

# Setup local plugin
# Create the symlink from "./src" to "./wordpress/wp-content/plugins/src"
if [ ! -L "$SYMLINK_FOLDER" ]; then
  echo "Creating the symlink from $REPO_FOLDER/src to $SYMLINK_FOLDER"
  ln -s "$REPO_FOLDER/src" "$SYMLINK_FOLDER"
fi
echo "Setup completed successfully!"

# Setup bash
echo export PATH=\"\$PATH:$REPO_FOLDER/src/vendor/bin\" >> ~/.bashrc
echo "cd $REPO_FOLDER/wordpress" >> ~/.bashrc
source ~/.bashrc
