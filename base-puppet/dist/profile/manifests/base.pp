# A profile defining the base install for all systems
class profile::base {
  include profile::bash
  include profile::mcollective
  include profile::puppet
  include profile::firewall
  include profile::ntp
  include profile::ssh
}
