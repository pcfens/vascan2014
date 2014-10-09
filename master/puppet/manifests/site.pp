package { ['build-essential', 'git', 'curl']:
  ensure => latest,
}

package { 'puppetserver':
  ensure => latest,
}

service { 'puppetserver':
  ensure  => running,
  require => Package['puppetserver'],
}

augeas { 'reduce-puppetserver-memory':
  require => Package['puppetserver'],
  context => '/files/etc/default/puppetserver',
  changes => 'set JAVA_ARGS \'"-Xms1536m -Xmx1536m"\'',
  notify  => Service['puppetserver'],
}

ini_setting { 'remove_puppet_templatedir':
  ensure  => absent,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'templatedir',
}

ini_setting { 'environmentpath':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'master',
  setting => 'environmentpath',
  value   => '$confdir/environments',
  notify  => Service['puppetserver'],
}

ini_setting { 'ssl_client_header-delete':
  ensure  => absent,
  path    => '/etc/puppet/puppet.conf',
  section => 'master',
  setting => 'ssl_client_header',
  notify  => Service['puppetserver'],
}

ini_setting { 'ssl_client_verify_header-delete':
  ensure  => absent,
  path    => '/etc/puppet/puppet.conf',
  section => 'master',
  setting => 'ssl_client_verify_header',
  notify  => Service['puppetserver'],
}

file { '/etc/puppet/autosign.conf':
  ensure  => present,
  content => "*.${::domain}",
  notify  => Service['puppetserver'],
}

class { 'nginx':
  package_name     => 'nginx-extras',
  package_source   => 'passenger',
  worker_processes => 4,
  confd_purge      => true,
  vhost_purge      => true,
  http_cfg_append  => {
    'passenger_root' => '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini',
  }
}

class { 'rabbitmq':
  config_stomp          => true,
  stomp_port            => 61613,
  config_variables      => {
    'log_levels' => '[{connection, info}]',
  },
  environment_variables => {
    'STOMP_USER'     => 'mcollective',
    'STOMP_PASSWORD' => 'supersecret',
  }
}

rabbitmq_vhost { '/mcollective':
  ensure => present,
}

rabbitmq_user { 'admin':
  password => 'supersecret',
  admin    => true,
}

rabbitmq_user { 'mcollective':
  ensure   => present,
  password => 'super-secret',
  admin    => true,
}

rabbitmq_user_permissions { 'mcollective@/mcollective':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}

rabbitmq_plugin { 'rabbitmq_stomp':
  ensure => present,
}

rabbitmq_exchange { 'mcollective_broadcast@/mcollective':
  ensure   => present,
  type     => 'topic',
  user     => 'mcollective',
  password => 'super-secret',
}

rabbitmq_exchange { 'mcollective_directed@/mcollective':
  ensure   => present,
  type     => 'direct',
  user     => 'mcollective',
  password => 'super-secret',
}

$mcollective_clients = [ 'mcollective-puppet-client',
                          'mcollective-service-client',
                          'mcollective-package-client',
                          'mcollective-nettest-client',
                          'mcollective-filemgr-client',
                          'mcollective-iptables-client',
                          'mcollective-nrpe-client',
                        ]

package { $mcollective_clients:
  ensure => installed,
}

package { 'ruby-dev':
  ensure => latest,
}

package { ['librarian-puppet', 'r10k', 'facter', 'hiera', 'hiera-eyaml', 'fog']:
  ensure   => latest,
  provider => 'gem',
  require  => [ Package['ruby-dev'], Package['build-essential'] ],
}

class { '::mcollective':
  version             => 'latest',
  connector           => 'rabbitmq',
  server              => false,
  client              => true,
  middleware_hosts    => ['127.0.0.1'],
  middleware_port     => 61613,
  middleware_password => 'super-secret',
  psk                 => 'superdupersecret',
  factsource          => 'yaml',
  collectives         => 'mcollective',
  main_collective     => 'mcollective',
  server_loglevel     => 'warn',
  classesfile         => '/var/lib/puppet/state/classes.txt',
}

file { '/etc/puppet/r10k.yaml':
  ensure  => present,
  owner   => 'puppet',
  group   => 'puppet',
  content =>
  "
:cachedir: '/tmp/r10k/cache'

:sources:
  :plops:
    remote: 'https://gitlab.wm.edu/pcfens/base-puppetconfig.git'
    basedir: '/etc/puppet/environments'
  ",
}

exec { 'deploy-puppet':
  command => '/usr/local/bin/r10k deploy environment -p -c /etc/puppet/r10k.yaml',
  path    => ['/usr/bin', '/usr/local/bin', '/bin', '/sbin', '/usr/sbin'],
  require => [ Package['r10k'], File['/etc/puppet/r10k.yaml'], Package['git'] ],
  notify  => Service['puppetserver'],
}

class { 'puppetdb': }

class { 'puppetdb::master::config':
  puppet_service_name => 'nginx',
}

class { 'foreman':
  foreman_url    => 'localhost',
  ssl            => true,
  passenger      => false,
  version        => latest,
  db_type        => 'postgresql',
  db_host        => 'localhost',
  db_database    => 'foreman',
  db_username    => 'foreman',
  db_password    => 'secret_password',
  admin_username => 'admin',
  admin_password => 'admin',
  require        => Package['puppetserver'],
}

class { 'foreman::puppetmaster':
  enc     => false,
  reports => true,
  require => Class['foreman'],
}

ini_setting { 'reports':
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'reports',
  value   => 'log, foreman',
  require => [ Class['foreman::puppetmaster'], Nginx::Resource::Vhost['foreman'] ],
  notify  => [ Service['nginx'] ],
}

nginx::resource::vhost { 'foreman':
  ensure               => present,
  server_name          => ['_'],
  listen_port          => 80,
  ssl                  => true,
  ssl_cert             => "/var/lib/puppet/ssl/certs/${::fqdn}.pem",
  ssl_key              => "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem",
  ssl_port             => 443,
  vhost_cfg_append     => {
    'passenger_enabled'                         => 'on',
    'passenger_friendly_error_pages'            => 'on',
    'passenger_ruby'                            => '/usr/bin/ruby',
    'client_max_body_size'                      => '16M',
    'ssl_crl'                => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    'ssl_client_certificate' => '/var/lib/puppet/ssl/certs/ca.pem',
    'ssl_verify_client'      => 'optional',
    'ssl_verify_depth'       => 1,
  },
  www_root             => '/usr/share/foreman/public',
  use_default_location => false,
  passenger_cgi_param  => {
    'HTTPS'                => 'on',
    'HTTP_X_CLIENT_DN'     => '$ssl_client_s_dn',
    'HTTP_X_CLIENT_VERIFY' => '$ssl_client_verify',
    'PATH'                 => '/usr/bin:/bin/:/usr/sbin:/sbin:/usr/local/bin',
  },
  require              => Class['foreman'],
}

cron { 'sync_puppet_foreman':
  ensure => present,
  command => 'cd /usr/share/foreman && rake puppet:import:hosts_and_facts RAILS_ENV=production',
  user    => 'foreman',
  minute  => '*/2',
}
