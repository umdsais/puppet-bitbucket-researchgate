# == Class: bitbucket::install
#
# This installs the bitbucket module
#
# === Parameters
#
# [*version*]
#   Bitbucket version to install
# [*product*]
#   Product name (bitbucket)
# [*format*]
#   Installation archive format
# [*installdir*]
#   Installation directory path
# [*homedir*]
#   Home directory path
# [*logdir*]
#   Log directory path
# [*manage_usr_grp*]
#   Whether to manage user/group
# [*user*]
#   Service user
# [*group*]
#   Service group
# [*uid*]
#   User ID
# [*gid*]
#   Group ID
# [*download_url*]
#   Product download URL
# [*deploy_module*]
#   Module to use for deployment
# [*dburl*]
#   Database URL
# [*checksum*]
#   Download file checksum
# [*webappdir*]
#   Web application directory
#
class bitbucket::install (
  String $webappdir            = $bitbucket::webappdir,
  String $version                        = $bitbucket::version,
  String $product                        = $bitbucket::product,
  String $format                         = $bitbucket::format,
  Stdlib::Absolutepath $installdir       = $bitbucket::installdir,
  Stdlib::Absolutepath $homedir          = $bitbucket::homedir,
  Stdlib::Absolutepath $logdir           = $bitbucket::logdir,
  Boolean $manage_usr_grp                = $bitbucket::manage_usr_grp,
  String $user                           = $bitbucket::user,
  String $group                          = $bitbucket::group,
  Optional[Integer] $uid                 = $bitbucket::uid,
  Optional[Integer] $gid                 = $bitbucket::gid,
  Optional[String] $download_url         = $bitbucket::download_url,
  String $deploy_module                  = $bitbucket::deploy_module,
  String $dburl                          = $bitbucket::dburl,
  Optional[String] $checksum             = $bitbucket::checksum,
) {
  if $manage_usr_grp {
    #Manage the group in the module
    group { $group:
      ensure => present,
      gid    => $gid,
    }
    #Manage the user in the module
    user { $user:
      comment          => 'Bitbucket daemon account',
      shell            => '/bin/bash',
      home             => $homedir,
      password         => '*',
      password_min_age => '0',
      password_max_age => '99999',
      managehome       => true,
      uid              => $uid,
      gid              => $gid,
    }
  }

  if ! defined(File[$installdir]) {
    file { $installdir:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
  }

  # Deploy files using either staging or deploy modules.
  $file = "atlassian-${product}-${version}.${format}"

  if ! defined(File[$webappdir]) {
    file { $webappdir:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
  }

  if versioncmp($version, '5.0.0') >= 0 {
    $archive_dir = "${webappdir}/app"
  } else {
    $archive_dir = "${webappdir}/conf"
  }

  case $deploy_module {
    'staging': {
      require staging
      staging::file { $file:
        source  => "${download_url}/${file}",
        timeout => 1800,
      }
      -> staging::extract { $file:
        target  => $webappdir,
        creates => $archive_dir,
        strip   => 1,
        user    => $user,
        group   => $group,
        notify  => Exec["chown_${webappdir}"],
        before  => File[$homedir],
        require => [
          File[$installdir],
        File[$webappdir]],
      }

      if $manage_usr_grp {
        User[$user] -> Staging::Extract[$file]
      }
    }
    'archive': {
      include 'archive'
      $checksum_verify = $checksum ? { undef => false, default => true }
      archive { "/tmp/${file}":
        ensure          => present,
        extract         => true,
        extract_path    => $installdir,
        source          => "${download_url}/${file}",
        creates         => $archive_dir,
        cleanup         => true,
        checksum_type   => 'md5',
        checksum        => $checksum,
        checksum_verify => $checksum_verify,
        user            => $user,
        group           => $group,
        before          => File[$webappdir],
        require         => File[$installdir],
      }

      if $manage_usr_grp {
        User[$user] -> Archive["/tmp/${file}"]
      }
    }
    default: {
      fail('deploy_module parameter must equal "archive" or staging""')
    }
  }

  file { $homedir:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }

  file { $logdir:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }

  exec { "chown_${webappdir}":
    command     => "/bin/chown -R ${user}:${group} ${webappdir}",
    refreshonly => true,
    subscribe   => File[$webappdir],
    require     => File[$homedir],
  }

  if $manage_usr_grp {
    User[$user] -> File[$homedir]
    User[$user] ~> Exec["chown_${webappdir}"]
  }
}
