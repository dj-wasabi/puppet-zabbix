# == Class: zabbix::server
#
#  This will install and configure the zabbix-server deamon
#
# === Requirements
#
#
# === Parameters
#
# [*database_type*]
#   Type of database. Can use the following 2 databases:
#   - postgresql
#   - mysql
#
# [*database_path*]
#   When database binaries are not found on the default path:
#   /bin:/usr/bin:/usr/local/sbin:/usr/local/bin
#   you can use this parameter to add the database_path to the above mentioned
#   path.
#
# [*zabbix_version*]
#   This is the zabbix version.
#   Example: 2.4
#
# [*manage_repo*]
#   When true (default) this module will manage the Zabbix repository
#
# [*zabbix_package_state*]
#   The state of the package that needs to be installed: present or latest.
#   Default: present
#
# [*manage_firewall*]
#   When true, it will create iptables rules.
#
# [*manage_service*]
#   When true, it will ensure service running and enabled.
#   When false, it does not care about service
#   Default: true
#
# [*server_configfile_path*]
#   Server config file path defaults to /etc/zabbix/zabbix_server.conf
#
# [*listenport*]
#   Listen port for the zabbix-server. Default: 10051
#
# [*sourceip*]
#   Source ip address for outgoing connections.
#
# [*logfile*]
#   Name of log file.
#
# [*logfilesize*]
#   Maximum size of log file in MB.
#
# [*logtype*]
#   Specifies where log messages are written to. Can be one of:
#   - console
#   - file
#   - system
#
# [*debuglevel*]
#   Specifies debug level.
#
# [*pidfile*]
#   Name of pid file.
#
# [*database_host*]
#   Database host name.
#
# [*database_name*]
#   Database name.
#
# [*database_schema*]
#   Schema name. used for ibm db2.
#
# [*database_user*]
#   Database user. ignored for sqlite.
#
# [*database_password*]
#   Database password. ignored for sqlite.
#
# [*database_socket*]
#   Path to mysql socket.
#
# [*database_port*]
#   Database port when not using local socket. Ignored for sqlite.
#
# [*database_tlsconnect*]
#   Available options:
#   * required - connect using TLS
#   * verify_ca - connect using TLS and verify certificate
#   * verify_full - connect using TLS, verify certificate and verify that database identity specified by DBHost matches its certificate
#
# [*database_tlscafile*]
#   Full pathname of a file containing the top-level CA(s) certificates for database certificate verification.
#
# [*database_tlscertfile*]
#   Full pathname of file containing Zabbix server certificate for authenticating to database.
#
# [*database_tlskeyfile*]
#   Full pathname of file containing the private key for authenticating to database.
#
# [*database_tlscipher*]
#   The list of encryption ciphers that Zabbix server permits for TLS protocols up through TLSv1.2.
#
# [*database_tlscipher13*]
#   The list of encryption ciphersuites that Zabbix server permits for TLSv1.3 protocol.
#
# [*startpollers*]
#   Number of pre-forked instances of pollers.
#
# [*startpreprocessors*]
#   Number of pre-forked instances of preprocessing workers
#
# [*startipmipollers*]
#   Number of pre-forked instances of ipmi pollers.
#
# [*startpollersunreachable*]
#   Number of pre-forked instances of pollers for unreachable hosts (including ipmi).
#
# [*starttrappers*]
#   Number of pre-forked instances of trappers.
#
# [*startpingers*]
#   Number of pre-forked instances of icmp pingers.
#
# [*startalerters*]
#   Number of pre-forked instances of alerters.
#
# [*startdiscoverers*]
#   Number of pre-forked instances of discoverers.
#
# [*startescalators*]
#   Number of pre-forked instances of escalators.
#
# [*starthttppollers*]
#   Number of pre-forked instances of http pollers.
#
# [*starttimers*]
#   Number of pre-forked instances of timers.
#
# [*javagateway*]
#   IP address (or hostname) of zabbix java gateway.
#
# [*javagatewayport*]
#   Port that zabbix java gateway listens on.
#
# [*startjavapollers*]
#   Number of pre-forked instances of java pollers.
#
# [*startlldprocessors*]
#   Number of pre-forked instances of low-level discovery (LLD) workers.
#
# [*startvmwarecollectors*]
#   Number of pre-forked vmware collector instances.
#
# [*vmwarefrequency*]
#   How often zabbix will connect to vmware service to obtain a new datan.
#
# [*vmwarecachesize*]
#   Size of vmware cache, in bytes.
#
# [*vmwaretimeout*]
#   The maximum number of seconds vmware collector will wait for a response from VMware service.
#
# [*snmptrapperfile*]
#   Temporary file used for passing data from snmp trap daemon to the server.
#
# [*startsnmptrapper*]
#   If 1, snmp trapper process is started.
#
# [*listenip*]
#   List of comma delimited ip addresses that the zabbix-server should listen on.
#
# [*housekeepingfrequency*]
#   How often zabbix will perform housekeeping procedure (in hours).
#
# [*maxhousekeeperdelete*]
#   the table "housekeeper" contains "tasks" for housekeeping procedure in the format:
#   [housekeeperid], [tablename], [field], [value].
#   no more than 'maxhousekeeperdelete' rows (corresponding to [tablename], [field], [value])
#   will be deleted per one task in one housekeeping cycle.
#   sqlite3 does not use this parameter, deletes all corresponding rows without a limit.
#   if set to 0 then no limit is used at all. in this case you must know what you are doing!
#
# [*cachesize*]
#   Size of configuration cache, in bytes.
#
# [*cacheupdatefrequency*]
#   How often zabbix will perform update of configuration cache, in seconds.
#
# [*startdbsyncers*]
#   Number of pre-forked instances of db syncers.
#
# [*historycachesize*]
#   Size of history cache, in bytes.
#
# [*historyindexcachesize*]
#   Size of history index cache, in bytes.
#
# [*trendcachesize*]
#   Size of trend cache, in bytes.
#
# [*valuecachesize*]
#   Size of history value cache, in bytes.
#
# [*timeout*]
#   Specifies how long we wait for agent, snmp device or external check (in seconds).
#
# [*tlscafile*]
#   Full pathname of a file containing the top-level CA(s) certificates for peer certificate verification.
#
# [*tlscertfile*]
#   Full pathname of a file containing the server certificate or certificate chain.
#
# [*tlscrlfile*]
#   Full pathname of a file containing revoked certificates.
#
# [*tlskeyfile*]
#   Full pathname of a file containing the server private key.
#
# [*tlscipherall*]
#   GnuTLS priority string or OpenSSL (TLS 1.2) cipher string. Override the default ciphersuite selection criteria
#   for certificate- and PSK-based encryption.
#
# [*tlscipherall13*]
#   Cipher string for OpenSSL 1.1.1 or newer in TLS 1.3. Override the default ciphersuite selection criteria
#   for certificate- and PSK-based encryption.
#
# [*tlsciphercert*]
#   GnuTLS priority string or OpenSSL (TLS 1.2) cipher string. Override the default ciphersuite selection criteria
#   for certificate-based encryption.
#
# [*tlsciphercert13*]
#   Cipher string for OpenSSL 1.1.1 or newer in TLS 1.3. Override the default ciphersuite selection criteria
#   for certificate-based encryption.
#
# [*tlscipherpsk*]
#  GnuTLS priority string or OpenSSL (TLS 1.2) cipher string. Override the default ciphersuite selection criteria
#  for PSK-based encryption.
#
# [*tlscipherpsk13*]
#  Cipher string for OpenSSL 1.1.1 or newer in TLS 1.3. Override the default ciphersuite selection criteria
#  for PSK-based encryption.
#
# [*trappertimeout*]
#   Specifies how many seconds trapper may spend processing new data.
#
# [*unreachableperiod*]
#   After how many seconds of unreachability treat a host as unavailable.
#
# [*unavailabledelay*]
#   How often host is checked for availability during the unavailability period, in seconds.
#
# [*unreachabledelay*]
#   How often host is checked for availability during the unreachability period, in seconds.
#
# [*alertscriptspath*]
#   Full path to location of custom alert scripts.
#
# [*externalscripts*]
#   Full path to location of external scripts.
#
# [*fpinglocation*]
#   Location of fping.
#
# [*fping6location*]
#   Location of fping6.
#
# [*sshkeylocation*]
#   Location of public and private keys for ssh checks and actions.
#
# [*logslowqueries*]
#   How long a database query may take before being logged (in milliseconds).
#
# [*tmpdir*]
#   Temporary directory.
#
# [*startproxypollers*]
#   Number of pre-forked instances of pollers for passive proxies.
#
# [*proxyconfigfrequency*]
#   How often zabbix server sends configuration data to a zabbix proxy in seconds.
#
# [*proxydatafrequency*]
#   How often zabbix server requests history data from a zabbix proxy in seconds.
#
# [*allowroot*]
#   Allow the server to run as 'root'.
#
# [*include_dir*]
#   You may include individual files or all files in a directory in the configuration file.
#
# [*loadmodulepath*]
#   Full path to location of server modules.
#
# [*loadmodule*]
#   Module to load at server startup.
#
# [*sslcertlocation_dir*]
#   Location of SSL client certificate files for client authentication.
#
# [*sslkeylocation_dir*]
#   Location of SSL private key files for client authentication.
#
# [*sslcalocation_dir*]
#   Location of certificate authority (CA) files for SSL server certificate verification.
#
# [*manage_startup_script*]
#  If the init script should be managed by this module. Attention: This might cause problems with some config options of this module (e.g server_configfile_path)
#
# [*socketdir*]
#   IPC socket directory.
#     Directory to store IPC sockets used by internal Zabbix services.
#
# === Example
#
#   When running everything on a single node, please check
#   documentation in init.pp
#   The following is an example of an multiple host setup:
#
#   node 'wdpuppet03.dj-wasabi.local' {
#     #class { 'postgresql::client': }
#     class { 'mysql::client': }
#     class { 'zabbix::server':
#       zabbix_version => '2.4',
#       database_host  => 'wdpuppet04.dj-wasabi.local',
#       database_type  => 'mysql',
#     }
#   }
#
#   The setup of above shows an configuration which used mysql as database.
#   It will require the database "client" classes, this is needed for executing
#   the installation files.
#
#   When database_type = postgres, uncomment the postgresql::client class and change or
#   remove the database_type parameter and comment the mysql::client class.
#
# === Authors
#
# Author Name: ikben@werner-dijkerman.nl
#
# === Copyright
#
# Copyright 2014 Werner Dijkerman
#
class zabbix::server (
  Zabbix::Databases $database_type                                            = $zabbix::params::database_type,
  $database_path                                                              = $zabbix::params::database_path,
  $zabbix_version                                                             = $zabbix::params::zabbix_version,
  $zabbix_package_state                                                       = $zabbix::params::zabbix_package_state,
  Boolean $manage_firewall                                                    = $zabbix::params::manage_firewall,
  Boolean $manage_repo                                                        = $zabbix::params::manage_repo,
  Boolean $manage_database                                                    = $zabbix::params::manage_database,
  Boolean $manage_service                                                     = $zabbix::params::manage_service,
  $server_configfile_path                                                     = $zabbix::params::server_configfile_path,
  $server_config_owner                                                        = $zabbix::params::server_config_owner,
  $server_config_group                                                        = $zabbix::params::server_config_group,
  $server_service_name                                                        = $zabbix::params::server_service_name,
  $pacemaker                                                                  = $zabbix::params::server_pacemaker,
  $pacemaker_resource                                                         = $zabbix::params::server_pacemaker_resource,
  $listenport                                                                 = $zabbix::params::server_listenport,
  $sourceip                                                                   = $zabbix::params::server_sourceip,
  Enum['console', 'file', 'system'] $logtype                                  = $zabbix::params::server_logtype,
  Optional[Stdlib::Absolutepath] $logfile                                     = $zabbix::params::server_logfile,
  $logfilesize                                                                = $zabbix::params::server_logfilesize,
  $debuglevel                                                                 = $zabbix::params::server_debuglevel,
  $pidfile                                                                    = $zabbix::params::server_pidfile,
  $database_schema_path                                                       = $zabbix::params::database_schema_path,
  $database_host                                                              = $zabbix::params::server_database_host,
  $database_name                                                              = $zabbix::params::server_database_name,
  $database_schema                                                            = $zabbix::params::server_database_schema,
  $database_user                                                              = $zabbix::params::server_database_user,
  $database_password                                                          = $zabbix::params::server_database_password,
  $database_socket                                                            = $zabbix::params::server_database_socket,
  Optional[Stdlib::Port::Unprivileged] $database_port                         = $zabbix::params::server_database_port,
  Optional[Enum['required', 'verify_ca', 'verify_full']] $database_tlsconnect = $zabbix::params::server_database_tlsconnect,
  Optional[Stdlib::Absolutepath] $database_tlscafile                          = $zabbix::params::server_database_tlscafile,
  Optional[Stdlib::Absolutepath] $database_tlscertfile                        = $zabbix::params::server_database_tlscertfile,
  Optional[Stdlib::Absolutepath] $database_tlskeyfile                         = $zabbix::params::server_database_tlskeyfile,
  Optional[String[1]] $database_tlscipher                                     = $zabbix::params::server_database_tlscipher,
  Optional[String[1]] $database_tlscipher13                                   = $zabbix::params::server_database_tlscipher13,
  $startpollers                                                               = $zabbix::params::server_startpollers,
  $startipmipollers                                                           = $zabbix::params::server_startipmipollers,
  $startpollersunreachable                                                    = $zabbix::params::server_startpollersunreachable,
  Integer[1, 1000] $startpreprocessors                                        = $zabbix::params::server_startpreprocessors,
  $starttrappers                                                              = $zabbix::params::server_starttrappers,
  $startpingers                                                               = $zabbix::params::server_startpingers,
  Integer[1, 100] $startalerters                                              = $zabbix::params::server_startalerters,
  $startdiscoverers                                                           = $zabbix::params::server_startdiscoverers,
  Integer[1, 100] $startescalators                                            = $zabbix::params::server_startescalators,
  $starthttppollers                                                           = $zabbix::params::server_starthttppollers,
  $starttimers                                                                = $zabbix::params::server_starttimers,
  $javagateway                                                                = $zabbix::params::server_javagateway,
  $javagatewayport                                                            = $zabbix::params::server_javagatewayport,
  $startjavapollers                                                           = $zabbix::params::server_startjavapollers,
  Integer[1, 100] $startlldprocessors                                         = $zabbix::params::server_startlldprocessors,
  $startvmwarecollectors                                                      = $zabbix::params::server_startvmwarecollectors,
  $vmwarefrequency                                                            = $zabbix::params::server_vmwarefrequency,
  $vmwarecachesize                                                            = $zabbix::params::server_vmwarecachesize,
  $vmwaretimeout                                                              = $zabbix::params::server_vmwaretimeout,
  $snmptrapperfile                                                            = $zabbix::params::server_snmptrapperfile,
  $startsnmptrapper                                                           = $zabbix::params::server_startsnmptrapper,
  $listenip                                                                   = $zabbix::params::server_listenip,
  $housekeepingfrequency                                                      = $zabbix::params::server_housekeepingfrequency,
  $maxhousekeeperdelete                                                       = $zabbix::params::server_maxhousekeeperdelete,
  $cachesize                                                                  = $zabbix::params::server_cachesize,
  $cacheupdatefrequency                                                       = $zabbix::params::server_cacheupdatefrequency,
  $startdbsyncers                                                             = $zabbix::params::server_startdbsyncers,
  $historycachesize                                                           = $zabbix::params::server_historycachesize,
  $historyindexcachesize                                                      = $zabbix::params::server_historyindexcachesize,
  $trendcachesize                                                             = $zabbix::params::server_trendcachesize,
  $valuecachesize                                                             = $zabbix::params::server_valuecachesize,
  $timeout                                                                    = $zabbix::params::server_timeout,
  $tlscafile                                                                  = $zabbix::params::server_tlscafile,
  $tlscertfile                                                                = $zabbix::params::server_tlscertfile,
  $tlscrlfile                                                                 = $zabbix::params::server_tlscrlfile,
  $tlskeyfile                                                                 = $zabbix::params::server_tlskeyfile,
  Optional[String[1]] $tlscipherall                                           = $zabbix::params::server_tlscipherall,
  Optional[String[1]] $tlscipherall13                                         = $zabbix::params::server_tlscipherall13,
  Optional[String[1]] $tlsciphercert                                          = $zabbix::params::server_tlsciphercert,
  Optional[String[1]] $tlsciphercert13                                        = $zabbix::params::server_tlsciphercert13,
  Optional[String[1]] $tlscipherpsk                                           = $zabbix::params::server_tlscipherpsk,
  Optional[String[1]] $tlscipherpsk13                                         = $zabbix::params::server_tlscipherpsk13,
  $trappertimeout                                                             = $zabbix::params::server_trappertimeout,
  $unreachableperiod                                                          = $zabbix::params::server_unreachableperiod,
  $unavailabledelay                                                           = $zabbix::params::server_unavailabledelay,
  $unreachabledelay                                                           = $zabbix::params::server_unreachabledelay,
  $alertscriptspath                                                           = $zabbix::params::server_alertscriptspath,
  $externalscripts                                                            = $zabbix::params::server_externalscripts,
  $fpinglocation                                                              = $zabbix::params::server_fpinglocation,
  $fping6location                                                             = $zabbix::params::server_fping6location,
  $sshkeylocation                                                             = $zabbix::params::server_sshkeylocation,
  $logslowqueries                                                             = $zabbix::params::server_logslowqueries,
  $tmpdir                                                                     = $zabbix::params::server_tmpdir,
  $startproxypollers                                                          = $zabbix::params::server_startproxypollers,
  $proxyconfigfrequency                                                       = $zabbix::params::server_proxyconfigfrequency,
  $proxydatafrequency                                                         = $zabbix::params::server_proxydatafrequency,
  $allowroot                                                                  = $zabbix::params::server_allowroot,
  $include_dir                                                                = $zabbix::params::server_include,
  $loadmodulepath                                                             = $zabbix::params::server_loadmodulepath,
  $loadmodule                                                                 = $zabbix::params::server_loadmodule,
  $sslcertlocation_dir                                                        = $zabbix::params::server_sslcertlocation,
  $sslkeylocation_dir                                                         = $zabbix::params::server_sslkeylocation,
  Optional[Stdlib::Absolutepath] $sslcalocation_dir                           = $zabbix::params::server_sslcalocation_dir,
  Boolean $manage_selinux                                                     = $zabbix::params::manage_selinux,
  String $additional_service_params                                           = $zabbix::params::additional_service_params,
  Optional[String[1]] $zabbix_user                                            = $zabbix::params::server_zabbix_user,
  Boolean $manage_startup_script                                              = $zabbix::params::manage_startup_script,
  Optional[Stdlib::Absolutepath] $socketdir                                   = $zabbix::params::server_socketdir,
) inherits zabbix::params {
  # zabbix server 5.2 is not supported on RHEL 7.
  # https://www.zabbix.com/documentation/current/manual/installation/install_from_packages/rhel_centos
  if $facts['os']['family'] == 'RedHat' and versioncmp($zabbix_version, '5.2') == 0 {
    if versioncmp($facts['os']['release']['major'], '7') == 0 {
      fail("${facts['os']['family']} ${$facts['os']['release']['major']} is not supported for zabbix::server (yet)")
    }
  }

  # Only include the repo class if it has not yet been included
  unless defined(Class['Zabbix::Repo']) {
    class { 'zabbix::repo':
      zabbix_version => $zabbix_version,
      manage_repo    => $manage_repo,
    }
  }

  # Get the correct database_type. We need this for installing the
  # correct package and loading the sql files.

  case $database_type {
    'postgresql' : {
      $db = 'pgsql'

      if $manage_database {
        # Execute the postgresql scripts
        class { 'zabbix::database::postgresql':
          zabbix_type          => 'server',
          zabbix_version       => $zabbix_version,
          database_schema_path => $database_schema_path,
          database_name        => $database_name,
          database_user        => $database_user,
          database_password    => $database_password,
          database_host        => $database_host,
          database_port        => $database_port,
          database_path        => $database_path,
          require              => Package["zabbix-server-${db}"],
        }
      }
    }
    'mysql'      : {
      $db = 'mysql'

      if $manage_database {
        # Execute the mysql scripts
        class { 'zabbix::database::mysql':
          zabbix_type          => 'server',
          zabbix_version       => $zabbix_version,
          database_schema_path => $database_schema_path,
          database_name        => $database_name,
          database_user        => $database_user,
          database_password    => $database_password,
          database_host        => $database_host,
          database_port        => $database_port,
          database_path        => $database_path,
          require              => Package["zabbix-server-${db}"],
        }
      }
    }
    default      : {
      fail('unrecognized database type for server.')
    }
  }

  # Installing the packages
  package { "zabbix-server-${db}":
    ensure  => $zabbix_package_state,
    require => Class['zabbix::repo'],
    tag     => 'zabbix',
  }

  # Ensure that the correct config file is used.
  if $manage_startup_script {
    zabbix::startup { 'zabbix-server':
      pidfile                   => $pidfile,
      database_type             => $database_type,
      server_configfile_path    => $server_configfile_path,
      zabbix_user               => $zabbix_user,
      additional_service_params => $additional_service_params,
      manage_database           => $manage_database,
      service_name              => 'zabbix-server',
      require                   => Package["zabbix-server-${db}"],
    }

    $require_for_service = [Package["zabbix-server-${db}"], File[$include_dir], File[$server_configfile_path], Zabbix::Startup['zabbix-server']]
  } else {
    $require_for_service = [Package["zabbix-server-${db}"], File[$include_dir], File[$server_configfile_path]]
  }

  if $server_configfile_path != '/etc/zabbix/zabbix_server.conf' {
    file { '/etc/zabbix/zabbix_server.conf':
      ensure  => absent,
      require => Package["zabbix-server-${db}"],
    }
  }

  # Controlling the 'zabbix-server' service
  if $pacemaker {
    exec { 'prevent zabbix boot-start':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "systemctl disable ${server_service_name}",
      onlyif  => "systemctl is-enabled ${server_service_name} | grep enabled >> /dev/null",
    }

    exec { 'stop zabbix if running without pacemaker':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "systemctl stop ${server_service_name}",
      onlyif  => "systemctl status ${server_service_name} | grep running >> /dev/null",
      unless  => "systemctl status ${server_service_name} | grep pacemaker >> /dev/null",
    }

    service { $server_service_name:
      ensure     => running,
      provider   => 'base',
      hasstatus  => true,
      hasrestart => true,
      status     => "/usr/sbin/pcs status resources | grep ${pacemaker_resource} | grep Started; echo $?",
      restart    => "/usr/sbin/pcs resource restart ${pacemaker_resource}",
      start      => "/usr/sbin/pcs resource start ${pacemaker_resource}",
      stop       => "/usr/sbin/pcs resource stop ${pacemaker_resource}",
      require    => [
        Package["zabbix-server-${db}"],
        File[$include_dir],
        File[$server_configfile_path],
      ],
    }
  } else {
    if $manage_service {
      service { $server_service_name:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => $require_for_service,
        subscribe  => File[$server_configfile_path],
      }
    }
  }

  # Configuring the zabbix-server configuration file
  file { $server_configfile_path:
    ensure  => file,
    owner   => $server_config_owner,
    group   => $server_config_group,
    mode    => '0640',
    require => Package["zabbix-server-${db}"],
    replace => true,
    content => template('zabbix/zabbix_server.conf.erb'),
  }

  # Include dir for specific zabbix-server checks.
  file { $include_dir:
    ensure  => directory,
    owner   => $server_config_owner,
    group   => $server_config_group,
    require => File[$server_configfile_path],
  }

  # Manage firewall
  if $manage_firewall {
    firewall { '151 zabbix-server':
      dport  => $listenport,
      proto  => 'tcp',
      action => 'accept',
      state  => [
        'NEW',
        'RELATED',
        'ESTABLISHED',
      ],
    }
  }

  $dependency = $manage_service ? {
    true  => Service[$server_service_name],
    false => undef,
  }
  # check if selinux is active and allow zabbix
  if fact('os.selinux.enabled') == true and $manage_selinux {
    ensure_resource ('selboolean',
      [
        'zabbix_can_network',
      ], {
        persistent => true,
        value      => 'on',
    })
    selinux::module { 'zabbix-server':
      ensure    => 'present',
      source_te => 'puppet:///modules/zabbix/zabbix-server.te',
      before    => $dependency,
      require   => Selboolean['zabbix_can_network'],
    }
    selinux::module { 'zabbix-server-ipc':
      ensure    => 'present',
      source_te => 'puppet:///modules/zabbix/zabbix-server-ipc.te',
      before    => $dependency,
    }
  }
}
