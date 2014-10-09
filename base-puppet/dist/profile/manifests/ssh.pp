# Configure SSH server
class profile::ssh {
  class { '::ssh::server':
    storeconfigs_enabled => false,
    options              => {
      'PermitRootLogin' => 'no',
    }
  }
}
