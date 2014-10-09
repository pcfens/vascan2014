# Profile defining standard firewall rules
class profile::firewall {

  include ::firewall

  resources { 'firewall':
    purge => true,
  }

  firewall { '000 accept icmp traffic':
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '001 accept ssh traffic':
    proto  => 'tcp',
    port   => 22,
    action => 'accept',
  }

  firewall { '002 accept local traffic':
    iniface => 'lo',
    action  => 'accept',
  }

  firewall { '003 accept established connections':
    state  => ['RELATED','ESTABLISHED'],
    action => 'accept',
  }

}
