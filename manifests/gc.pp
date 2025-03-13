# == Class: bitbucket::gc
#
# Class to run git gc on bitbucket repo's at regular intervals
#
# @param ensure
#   Enable or disable cron job to run git garbage collection (present/absent)
# @param path
#   Path where git gc script will be installed
# @param minute
#   Minute when the cron job will run
# @param hour
#   Hour when the cron job will run
# @param weekday
#   Day of the week when the cron job will run
# @param user
#   User that will run the git gc command
# @param homedir
#   Home directory path where repositories are stored
#
class bitbucket::gc (
  String $ensure                         = 'present',
  Stdlib::Absolutepath $path             = '/usr/local/bin/git-gc.sh',
  Variant[Integer,String] $minute        = 0,
  Variant[Integer,String] $hour          = 0,
  Variant[Integer,String] $weekday       = 'Sunday',
  String $user                           = $bitbucket::user,
  Stdlib::Absolutepath $homedir          = $bitbucket::homedir,
) {
  include bitbucket::params

  if $facts['bitbucket_version'] and versioncmp($facts['bitbucket_version'], '3.2') < 0 {
    $shared = ''
  } else {
    $shared = '/shared'
  }

  file { $path:
    ensure  => $ensure,
    content => template('bitbucket/git-gc.sh.erb'),
    mode    => '0755',
  }

  -> cron { 'git-gc-bitbucket':
    ensure  => $ensure,
    command => "${path} &>/dev/null",
    user    => $user,
    minute  => $minute,
    hour    => $hour,
    weekday => $weekday,
  }
}
