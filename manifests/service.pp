# == Class: bitbucket::service
#
# This manages the bitbucket service
#
# @param service_manage
#   Whether to manage the service
# @param service_ensure
#   State of service (running/stopped)
# @param service_enable
#   Whether to enable service
# @param service_file_location
#   Location of service file
# @param service_file_mode
#   File mode for service file
# @param service_file_template
#   Template for service file
# @param service_lockfile
#   Path to service lock file
#
class bitbucket::service (
  Boolean $service_manage                 = $bitbucket::service_manage,
  String $service_ensure                  = $bitbucket::service_ensure,
  Boolean $service_enable                 = $bitbucket::service_enable,
  Stdlib::Absolutepath $service_file_location = $bitbucket::params::service_file_location,
  String $service_file_mode              = $bitbucket::params::service_file_mode,
  String $service_file_template          = $bitbucket::params::service_file_template,
  Stdlib::Absolutepath $service_lockfile = $bitbucket::params::service_lockfile,
) {
  if $bitbucket::service_manage {
    file { $service_file_location:
      content => template($service_file_template),
      mode    => $service_file_mode,
    }

    if ($facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '7') or
    ($facts['os']['family'] == 'Debian' and $facts['os']['release']['major'] == '16.04') {
      exec { 'bitbucket_refresh_systemd':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File[$service_file_location],
        before      => Service['bitbucket'],
      }
    }

    service { 'bitbucket':
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => File[$service_file_location],
    }
  }
}
