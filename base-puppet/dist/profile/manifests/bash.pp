# A profile to define the version of bash installed on various systems
#
class profile::bash {

  include ::shellshock

  # Vulnerable versions of bash
  $bash_version = $::lsbdistcodename ? {
    'precise'  => '4.2-2ubuntu2',   # Ubuntu 12.04
    'trusty'   => '4.3-6ubuntu1',   # Ubuntu 14.04
    'Santiago' => '4.1.2-15.el6_4', # RedHat 6.5
  }

  package { 'bash':
    ensure => $bash_version,
  }
  
}
