# WordPress Scaffold Plugin

This is a scaffold for creating a plugin for WordPress (https://wordpress.org). I wanted to restructure the project to keep the development files away from the source file for easier production compiling. The scaffold would create files from either `wp scaffold plugin` or @hlashbrooke proposed template 

## Installation
* Clone the repo into a root 
* Create the necessary env variables for the project (maybe via `composer config --json extra` ?)
* Configure using `composer` 

## Behind the scenes
This setup can/will create and configure the following things automatically:
- install [WP CLI](https://wp-cli.org/)
- create project using either [WP CLI](https://developer.wordpress.org/cli/commands/scaffold/plugin/) or [Wordpress Plugin Template](https://github.com/hlashbrooke/WordPress-Plugin-Template) 
- install [PHCS with WP Coding Std.](https://packagist.org/packages/wp-coding-standards/wpcs)
- install [Wordpress Test Suite](https://developer.wordpress.org/cli/commands/scaffold/plugin-tests/)
- install and activate selected plugins using composer script

### TODO
* Neaten how stuff are installed
* Make considerations for themes
* Add more boilerplates
* Better way to install boilerplates??
