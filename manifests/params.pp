# == Class: bitbucket::params
#
# @private
# Defines default values for bitbucket module
#
class bitbucket::params {
  case $facts['os']['family'] {
    /RedHat/: {
      $systemd_unit_dir = '/usr/lib/systemd/system'
      $init_template    = 'bitbucket.initscript.redhat.erb'
      $service_lockfile = '/var/lock/subsys/bitbucket'
    } /Debian/: {
      $systemd_unit_dir = '/etc/systemd/system'
      $init_template    = 'bitbucket.initscript.debian.erb'
      $service_lockfile = '/var/lock/bitbucket'
    } default: {
      fail("${facts['os']['name']} ${facts['os']['release']['major']} not supported")
    }
  }

  case $facts['service_provider'] {
    'systemd': {
      $service_file_location = "${systemd_unit_dir}/bitbucket.service"
      $service_file_template = 'bitbucket/bitbucket.service.erb'
      $service_file_mode     = '0644'
    }
    default: {
      $service_file_location = '/etc/init.d/bitbucket'
      $service_file_template = "bitbucket/${init_template}"
      $service_file_mode     = '0754'
    }
  }
}
