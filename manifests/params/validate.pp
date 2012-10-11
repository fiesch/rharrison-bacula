# == Class: bacula::params::validate
#
# This class takes parameters which values need to be validated in some way.
# Because the class should only be called from the main +bacula+ class the
# default values are intended to fail.
#
class bacula::params::validate(
    $console_password   = '',
    $db_backend         = '',
    $db_database        = '',
    $db_host            = '',
    $db_password        = '',
    $db_port            = '',
    $db_user            = '',
    $director_password  = '',
    $director_server    = '',
    $is_client          = '',
    $is_director        = '',
    $is_storage         = '',
    $mail_to            = '',
    $manage_bat         = '',
    $manage_console     = '',
    $manage_db          = '',
    $manage_db_tables   = '',
    $storage_server     = '',
    $use_console        = '',
  ) {

  #Validate our booleans
  validate_bool($manage_console)
  validate_bool($manage_bat)
  validate_bool($is_director)
  validate_bool($is_storage)
  validate_bool($is_client)
  validate_bool($use_console)
  validate_bool($manage_db_tables)
  validate_bool($manage_db)

  if $use_console {
    if empty($console_password) {
      fail 'console_password cannot be empty'
    }
  }

  #Validate mail_to is an email address
  if $is_director {
    validate_re($mail_to, '^[\w-]+@([\w-]+\.)+[\w-]+$')
  }

  # Validate the director and storage servers given are fully qualified
  # domain names
  validate_re($director_server, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')
  validate_re($storage_server, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')

  #Validate server values aren't empty
  if empty($director_server) {
    fail '$director_server cannot be empty'
  }
  if empty($storage_server) {
    fail '$storage_server cannot be empty'
  }

  #Validate the passwords aren't empty
  if $is_director {
    if empty($director_password) {
      fail '$director_password cannot be empty'
    }
  }

  if $manage_console {
    if empty($console_password) {
      fail '$console_password cannot be empty'
    }
  }

  if empty($db_database) {
    fail '$db_database cannot be empty'
  }

  if $db_backend != 'sqlite' {
    if $db_backend != 'mysql' {
      fail '$db_backend must be either \'sqlite\' or \'mysql\''
    }
    if empty($db_host) {
      fail '$db_host cannot be empty'
    }
    if empty($db_user) {
      fail '$db_user cannot be empty'
    }
    if ! is_integer($db_port) {
      fail '$db_port must be a port number'
    }
    if empty($db_password) {
      fail '$db_password cannot be empty'
    }
  }
}
