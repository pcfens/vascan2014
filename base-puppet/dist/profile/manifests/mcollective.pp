# Profile installing the latest version of mcollective and
# required agents.
class profile::mcollective {

  $mcollective_plugins = [  'puppet',
                            'service',
                            'package',
                            'nettest',
                            'filemgr',
                            'iptables',
                            'nrpe',
                        ]

  mcollective::plugin { $mcollective_plugins:
    package => true,
  }

  class { '::mcollective':
    version             => 'latest',
    connector           => 'rabbitmq',
    server              => true,
    middleware_hosts    => ['10.0.0.10'],
    middleware_port     => 61613,
    middleware_password => 'super-secret',
    psk                 => 'superdupersecret',
    factsource          => 'yaml',
    collectives         => 'mcollective',
    main_collective     => 'mcollective',
    server_loglevel     => 'warn',
    classesfile         => '/var/lib/puppet/state/classes.txt',
  }

}
