# == Class: bacula::common
#
# This class enforces common resources needed by all
# bacula components
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the bacula user and groups exist
# * Enforce the +/var/spool/bacula+ is a director and +/var/lib/bacula+
#   points to it
#
class bacula::common(
  $db_backend       = 'sqlite',
  $db_database      = 'bacula',
  $db_host          = 'localhost',
  $db_password      = '',
  $db_port          = '3306',
  $db_user          = '',
  $is_client        = true,
  $is_director      = false,
  $is_storage       = false,
  $manage_bat       = false,
  $manage_console   = false,
  $manage_db_tables = true,
  $packages         = undef
) {
  include bacula::params

  if $packages {
    $packages_notify = $manage_db_tables ? {
      true    => Exec['make_db_tables'],
      default => undef,
    }
    package { $packages:
      ensure => installed,
      notify => $packages_notify,
    }
  }

# The user and group are actually created by installing the bacula-common
# package which is pulled in when any other bacula package is installed.
# To work around the issue where every package resource is a separate run of
# yum we add requires for the packages we already have to the group resource.
  if $is_client {
    $require_package = 'bacula-client'
  } elsif $is_director {
    $require_package = $bacula::director::db_package
  } elsif $is_storage {
    $require_package = $bacula::storage::db_package
  } elsif $manage_console {
    $require_package =$bacula::params::console_package
  } elsif $manage_bat {
    $require_package = $bacula::params::bat_console_package
  }

# Specify the user and group are present before we create files.
  group { 'bacula':
    ensure  => present,
    require => Package[$require_package],
  }

  user { 'bacula':
    ensure  => present,
    gid     => 'bacula',
    require => Group['bacula'],
  }

  file { '/var/lib/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$require_package],
  }

  file { '/var/spool/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$require_package],
  }

  file { '/var/log/bacula':
    ensure  => directory,
    recurse => true,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$require_package],
  }

  file { '/var/run/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    require => Package[$require_package],
  }
}
