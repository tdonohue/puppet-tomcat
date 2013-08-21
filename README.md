Tomcat Puppet Module
====================

This is an extremely simplistic Puppet module which installs Tomcat. It's only been testing on Ubuntu (and will only work on Ubuntu/Debian thus far).

All It Does
-----------

* Installs 'tomcat' package (Tomcat 7 by default)
* Installs 'tomcat-user' package (which is only on Ubuntu/Debian)
   * Note: the 'tomcat-user' package provides the following:
      * Tomcat 'skeleton' configs (/user/share/tomcat7/skel/) - Used by 'tomcat7-instance-create' 
      * 'tomcat7-instance-create' script - which is used to install Tomcat to a specific directory (and allows for easy setup of multiple Tomcat instances per server)
* Provides a "tomcat::instance" script which lets you install one (or more) Tomcat instances on your server.


How To Use It
-------------

1. Install this module (via something like [librarian-puppet](http://librarian-puppet.com/)).
2. Call it from a Puppet script

        # Install Tomcat package
        include tomcat
        # Create a new Tomcat instance at ~ubuntu/tomcat
        tomcat::instance { 'mytomcat':
          owner         => "ubuntu",
          port          => "8080",
          shutdown_port => "8005",
          appBase       => "webapps",  # Tell Tomcat to load webapps from this directory 
        }
   * Other options are available. See the included "instance.pp" script.
