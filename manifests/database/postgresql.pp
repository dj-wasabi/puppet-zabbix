# == Class: zabbix::database::postgresql
#
#  This will install and load the sql files for the tables
#  and other data which is needed for zabbix.
#
#  Please note:
#  This class will be called from zabbix::server or zabbix::proxy.
#  No need for calling this class manually.
#
# === Authors
#
# Author Name: ikben@werner-dijkerman.nl
#
# === Copyright
#
# Copyright 2014 Werner Dijkerman
#
class zabbix::database::postgresql (
  $zabbix_type          = '',
  $zabbix_version       = $zabbix::params::zabbix_version,
  $database_schema_path = '',
  $database_name        = '',
  $database_user        = '',
  $database_password    = '',
  $database_host        = '',
  $database_path        = $zabbix::params::database_path,
) inherits zabbix::params {
  assert_private()

  #
  # Adjustments for version 3.0/4.0 - structure of package with sqls differs from previous versions
  case $zabbix_version {
    /^(3|4).\d+$/: {
      if ($database_schema_path == false) or ($database_schema_path == '') {
        case $facts['os']['name'] {
          'CentOS', 'RedHat', 'OracleLinux', 'VirtuozzoLinux': {
            $schema_path   = "/usr/share/doc/zabbix-*-pgsql-${zabbix_version}*/"
          }
          default : {
            $schema_path   = '/usr/share/doc/zabbix-*-pgsql'
          }
        }
      }
      else {
        $schema_path = $database_schema_path
      }

      case $zabbix_type {
        'proxy': {
          $zabbix_proxy_create_sql = "cd ${schema_path} && if [ -f schema.sql.gz ]; then gunzip -f schema.sql.gz ; fi && psql -h '${database_host}' -U '${database_user}' -d '${database_name}' -f schema.sql && touch /etc/zabbix/.schema.done"
        }
        default: {
          $zabbix_server_create_sql = "cd ${schema_path} && if [ -f create.sql.gz ]; then gunzip -f create.sql.gz ; fi && psql -h '${database_host}' -U '${database_user}' -d '${database_name}' -f create.sql && touch /etc/zabbix/.schema.done"
          $zabbix_server_images_sql = 'touch /etc/zabbix/.images.done'
          $zabbix_server_data_sql   = 'touch /etc/zabbix/.data.done'
        }
      }
    }
    default: {
      if ($database_schema_path == false) or ($database_schema_path == '') {
        case $facts['os']['name'] {
          'CentOS', 'RedHat', 'OracleLinux', 'VirtuozzoLinux': {
            $schema_path   = "/usr/share/doc/zabbix-*-pgsql-${zabbix_version}*/create"
          }
          default : {
            $schema_path   = '/usr/share/zabbix-*-pgsql'
          }
        }
      }
      else {
        $schema_path = $database_schema_path
      }
      case $zabbix_type {
        'proxy': {
          $zabbix_proxy_create_sql = "cd ${schema_path} && if [ -f schema.sql.gz ]; then gunzip -f schema.sql.gz ; fi && psql -h '${database_host}' -U '${database_user}' -d '${database_name}' -f schema.sql && touch /etc/zabbix/.schema.done"
        }
        default: {
          $zabbix_server_create_sql = "cd ${schema_path} && if [ -f schema.sql.gz ]; then gunzip -f schema.sql.gz ; fi && psql -h '${database_host}' -U '${database_user}' -d '${database_name}' -f schema.sql && touch /etc/zabbix/.schema.done"
          $zabbix_server_images_sql = "cd ${schema_path} && if [ -f images.sql.gz ]; then gunzip -f images.sql.gz ; fi && psql -h '${database_host}' -U '${database_user}' -d '${database_name}' -f images.sql && touch /etc/zabbix/.images.done"
          $zabbix_server_data_sql   = "cd ${schema_path} && if [ -f data.sql.gz ]; then gunzip -f data.sql.gz ; fi && psql -h '${database_host}' -U '${database_user}' -d '${database_name}' -f data.sql && touch /etc/zabbix/.data.done"
        }
      }
    }
  }

  exec { 'update_pgpass':
    command => "echo '${database_host}:5432:${database_name}:${database_user}:${database_password}' >> /root/.pgpass",
    path    => "/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:${database_path}",
    unless  => "grep \"${database_host}:5432:${database_name}:${database_user}:${database_password}\" /root/.pgpass",
    require => File['/root/.pgpass'],
  }

  file { '/root/.pgpass':
    ensure => file,
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
  }

  case $zabbix_type {
    'proxy': {
      exec { 'zabbix_proxy_create.sql':
        command  => $zabbix_proxy_create_sql,
        path     => "/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:${database_path}",
        unless   => 'test -f /etc/zabbix/.schema.done',
        provider => 'shell',
        require  => Exec['update_pgpass'],
      }
    }
    'server': {
      exec { 'zabbix_server_create.sql':
        command  => $zabbix_server_create_sql,
        path     => "/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:${database_path}",
        unless   => 'test -f /etc/zabbix/.schema.done',
        provider => 'shell',
        require  => Exec['update_pgpass'],
      }
      -> exec { 'zabbix_server_images.sql':
        command  => $zabbix_server_images_sql,
        path     => "/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:${database_path}",
        unless   => 'test -f /etc/zabbix/.images.done',
        provider => 'shell',
        require  => Exec['update_pgpass'],
      }
      -> exec { 'zabbix_server_data.sql':
        command  => $zabbix_server_data_sql,
        path     => "/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:${database_path}",
        unless   => 'test -f /etc/zabbix/.data.done',
        provider => 'shell',
        require  => Exec['update_pgpass'],
      }
    }
    default: {
      fail 'We do not work.'
    }
  }
}
