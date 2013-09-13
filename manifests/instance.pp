# Definition: tomcat::instance
#
# This defined type will setup a new instance of Tomcat each time it is called.
# Each time it is called, the following happens:
# - A new instance of tomcat is created using the 'tomcat7-instance-create' script
#   (which is provided by 'tomcat7-user' in Ubuntu/Debian)
# - This new instance is installed to the directory specified and owned by the user specified.
#
# Tested on:
# - Ubuntu 12.04
#
# Parameters:
# - $owner (REQUIRED) => User who should own tomcat instance
# - $ensure           => Whether to ensure tomcat instance is created ('present', default value) or deleted ('absent')
# - $group            => Group who should own tomcat intance (default = same as $owner)
# - $dir              => Location where tomcat instance should be installed (defaults to the home directory of $owner at ~/tomcat)
# - $port             => Main port that Tomcat should use (default = 8080)
# - $shutdown_port    => Shutdown port for Tomcat (default = 8005)
# - $appBase          => Directory where Tomcat should load its web applications (defaults to "webapps" subdirectory under $dir). 
#                        Can be a relative or absolute path to a directory containing all web applications.
#
# Sample Usage:
#   # CREATES a new instance with default settings in /home/ubuntu/tomcat/, owned by 'ubuntu'
#   tomcat::instance { "testing" : owner => "ubuntu" }
#
#   # DELETES an existing instance from /home/ubuntu/tomcat/
#   tomcat::instance { 'testing': ensure => absent, owner => 'ubuntu' }
#
#
define tomcat::instance($owner,
                        $ensure        = "present",
                        $group         = $owner,
                        $dir           = "/home/${owner}/tomcat",
                        $port          = "8080",
                        $shutdown_port = "8005",
                        $appBase       = "webapps") 
{

  case $ensure 
  {

    # Making sure the instance is present/created
    present: {   

       # Check to ensure tomcat instance directory exists
       file {$dir:
         ensure  => directory,
         owner   => $owner,
         group   => $group,
         require => Exec["create instance at $dir"],
       }

       # Make sure Tomcat instance was created
       # This uses the tomcat-user package scripts to create the instance
       exec { "create instance at $dir":
	     command => "tomcat7-instance-create $dir",
	     user    => $owner,
	     creates => $dir,
	     require => Package['tomcat-user'],
         path    => "/usr/bin:/usr/sbin:/bin",	
       }

       # Override the default server.xml file
       # and use a template to specify the ports & appBase
       file {"${dir}/conf/server.xml":
         ensure  => file,
         owner   => $owner,
         group   => $group,
         mode    => 0644,
         content => template("tomcat/server.xml.erb"),
       }

   # set up defaults file for this instance
       file { "/etc/default/tomcat7-${owner}" :
         ensure  => file,
         owner   => root,
         group   => root,
         content => template("tomcat/default-tomcat7-instance.erb"),
       }  
   
   # set up an init script for this instance
       file { "/etc/init.d/tomcat7-${owner}" :
         ensure  => file,
         owner   => root,
         group   => root,
         mode    => 755,
         content => template("tomcat/init-tomcat7-instance.erb"),
       }

   # copy the contents of the tomcat policy.d folder to this instance's config folder (it won't boot without them)
       exec { "copy policy.d":
         command => "cp -r policy.d ${dir}/conf/ && chown -R ${owner}:${group} ${dir}/conf/policy.d",
         cwd     => "/etc/tomcat7",
         require => Package['tomcat7'],
       }

   # create a default tomcat-users.xml file
       file {"${dir}/conf/tomcat-users.xml":
         ensure  => file,
         owner   => $owner,
         group   => $group,
         mode    => 0644,
         content => template("tomcat/tomcat-users.xml.erb"),
       }


    }

    # Making sure the instance is deleted
    absent: {

       # Check to ensure tomcat instance directory is deleted
       # (along with any subdirectories)
       file {$dir:
         ensure  => absent,
         recurse => true, 
         force   => true,
       }
    }

    default: { fail "Unknown ${ensure} value for ensure" }
  }
}

