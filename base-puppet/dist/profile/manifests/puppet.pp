# Profile managing the installation and configuration of
# puppet
class profile::puppet {


  $puppet_version = $::osfamily ? {
    'Debian' => '3.7.1-1puppetlabs1',
    'RedHat' => "3.7.1-1.el${::operatingsystemmajrelease}",
    default  => '3.7.1',
  }

  package { 'puppet':
    ensure => $puppet_version,
  }

  augeas { 'start_puppet':
    notify  => Service['puppet'],
    context => '/files/etc/default/puppet',
    changes => 'set START \'"yes"\'',
    require => Package['puppet'],
  }

  augeas { 'remove_puppet_templatedir':
    context => '/files/etc/puppet/puppet.conf',
    changes => 'rm main/templatedir',
    notify  => Service['puppet'],
    require => Package['puppet'],
  }

  augeas { 'set_puppet_server':
    context => '/files/etc/puppet/puppet.conf',
    changes => 'set main/server ip-10-0-0-10.ec2.internal',
    notify  => Service['puppet'],
    require => Package['puppet'],
  }
  
  augeas { 'send_puppet_reports':
    context => '/files/etc/puppet/puppet.conf',
    changes => 'set main/report true',
    notify  => Service['puppet'],
    require => Package['puppet'],
  }

  service { 'puppet':
    ensure  => running,
    require => Package['puppet'],
  }

}
