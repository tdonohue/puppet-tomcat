# Class: tomcat
#
# This class does the following:
# - installs latest Tomcat from system package manager
# - installs 'tomcat-user' package from system package manager (Ubuntu/Debian specific)
#    * Note: the 'tomcat-user' package provides the following:
#       - Tomcat 'skeleton' configs (/user/share/tomcat7/skel/) - Used by 'tomcat7-instance-create' 
#       - 'tomcat7-instance-create' script - Used by instance.pp
#
# Requires:
# - Java must be installed
#
# Tested on:
# - Ubuntu 12.04
#
# Parameters:
# - $tomcat => Name of the tomcat package (default = "tomcat7")
#
# Sample Usage:
#  include tomcat
#
class tomcat ($tomcat = "tomcat7") 
{

  # Default to requiring all packages be installed
  Package {
    ensure => installed,
  }

  # Require these base packages are installed
  package { 'tomcat':
    name => $tomcat,
  }
  # NOTE: tomcat-user package is Ubuntu specific!!
  # It lets us quickly install Tomcat to any directory (see instance.pp)
  package { 'tomcat-user':
    name    => "${tomcat}-user",
    require => Package['tomcat'],
  }

  # Ensure the tomcat home directory exists
  file { "/usr/share/${tomcat}":
    ensure  => directory,
    require => Package['tomcat'],
  }

  # install the package, but disable the default Tomcat service
  service { 'tomcat':
    name      => $tomcat,
    enable    => false,
    require   => Package['tomcat'],
    ensure    => stopped
  }
}
