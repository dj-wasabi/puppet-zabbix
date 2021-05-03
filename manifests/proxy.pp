# == Class: zabbix::proxy
#
#  This will install and configure the zabbix-proxy deamon
#
# === Requirements
#
# When 'manage_database' is set to true, the corresponding database class
# in 'database_type' should be required.
#
# === Parameters
#
# [*database_type*]
#   Type of database. Can use the following 3 databases:
#   - postgresql
#   - mysql
#   - sqlite
#
# [*database_path*]
#  When database binaries are not found on the default path:
#  /bin:/usr/bin:/usr/local/sbin:/usr/local/bin
#  you can use this parameter to add the database_path to the above mentiond
#  path.
#
# [*zabbix_version*]
#   This is the zabbix version.
#
# [*zabbix_package_state*]
#   The state of the package that needs to be installed: present or latest.
#   Default: present
#
# [*manage_database*]
#   When true, it will configure the database and execute the sql scripts.
#
# [*manage_firewall*]
#   When true, it will create iptables rules.
#
# [*manage_repo*]
#   When true, it will create repository for installing the proxy.
#
# [*manage_resources*]
#   When true, it will export resources so that the zabbix-server can create
#   via the zabbix-api proxy.
#
# [*use_ip*]
#   When true, when creating proxies via the zabbix-api, it will configure that
#   connection should me made via ip, not fqdn.
#
# [*zbx_templates*]
#   Template which will be added when proxy is configured.
#
# [*proxy_configfile_path*]
#   Proxy config file path defaults to /etc/zabbix/zabbix_proxy.conf
#
# [*mode*]
#   Proxy operating mode.
#
# [*zabbix_server_host*]
#   Hostname or the ipaddress of the zabbix-server.
#
# [*zabbix_server_port*]
#   Port on which the server is listening.
#
# [*hostname*]
#  Hostname for the proxy. Default is $::fqdn or this parameter.
#
# [*listenport*]
#   Listen port for trapper.
#
# [*sourceip*]
#   Source ip address for outgoing connections.
#
# [*enableremotecommands*]
#   Whether remote commands from zabbix server are allowed.
#
# [*logremotecommands*]
#   Enable logging of executed shell commands as warnings.
#
# [*logfile*]
#   Name of log file.
#
# [*logfilesize*]
#   Maximum size of log file in MB.
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
# [*localbuffer*]
#   Proxy will keep data locally for N hours, even if the data have already been synced with the server
#
# [*offlinebuffer*]
#   Proxy will keep data for N hours in case if no connectivity with Zabbix Server
#
# [*heartbeatfrequency*]
#   Unique nodeid in distributed setup.
#
# [*configfrequency*]
#   How often proxy retrieves configuration data from Zabbix Server in seconds.
#
# [*datasenderfrequency*]
#   Proxy will send collected data to the Server every N seconds.
#
# [*startpollers*]
#   Number of pre-forked instances of pollers.
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
# [*startdiscoverers*]
#   Number of pre-forked instances of discoverers.
#
# [*starthttppollers*]
#   Number of pre-forked instances of http pollers.
#
# [*javagateway_host*]
#   IP address (or hostname) of zabbix java gateway.
#
# [*javagateway_port*]
#   Port that zabbix java gateway listens on.
#
# [*startjavapollers*]
#   Number of pre-forked instances of java pollers.
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
# [*snmptrapperfile*]
#   Temporary file used for passing data from snmp trap daemon to the server.
#
# [*startsnmptrapper*]
#   If 1, snmp trapper process is started.
#
# [*listenip*]
#   List of comma delimited ip addresses that the trapper should listen on.
#
# [*housekeepingfrequency*]
#   How often Zabbix will perform housekeeping procedure (in hours).
#
# [*cachesize*]
#   Size of configuration cache, in MB.
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
# [*historytextcachesize*]
#   Size of text history cache, in bytes.
#
# [*timeout*]
#   Specifies how long we wait for agent, snmp device or external check (in seconds).
#
# [*tlsaccept*]
#   What incoming connections to accept from Zabbix server. Used for a passive proxy, ignored on an active proxy.
#
# [*tlscafile*]
#   Full pathname of a file containing the top-level CA(s) certificates for peer certificate verification.
#
# [*tlscertfile*]
#   Full pathname of a file containing the proxy certificate or certificate chain.
#
# [*tlsconnect*]
#   How the proxy should connect to Zabbix server. Used for an active proxy, ignored on a passive proxy.
#
# [*tlscrlfile*]
#   Full pathname of a file containing revoked certificates.
#
# [*tlskeyfile*]
#   Full pathname of a file containing the proxy private key.
#
# [*tlspskfile*]
#   Full pathname of a file containing the pre-shared key.
#
# [*tlspskidentity*]
#   Unique, case sensitive string used to identify the pre-shared key.
#
# [*tlsservercertissuer*]
#   Allowed server certificate issuer.
#
# [*tlsservercertsubject*]
#   Allowed server certificate subject.
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
# [*socketdir*]
#   IPC socket directory.
#     Directory to store IPC sockets used by internal Zabbix services.
#
# === Example
#
#  When you want to run everything on one machine, you can use the following
#  example:
#  class { 'zabbix::proxy':
#    zabbix_server_host => '192.168.1.1',
#    zabbix_server_port => '10051',
#  }
#
#  When you want to use mysql:
#  class { 'zabbix::proxy':
#    zabbix_server_host => '192.168.1.1',
#    zabbix_server_port => '10051',
#    database_type      => 'mysql',
#  }
#
#  The zabbix::proxy can also be split like the server into 2 servers:
#  - zabbix::proxy
#  - zabbix::database
#
#  The following is an example of running the proxy on 2 servers:
#  node 'wdpuppet03.dj-wasabi.local' {
#    #class { 'postgresql::client': }
#    class { 'mysql::client': }
#    class { 'zabbix::proxy':
#      zabbix_server_host => '192.168.1.1',
#      manage_database    => false,
#      database_host      => 'wdpuppet04.dj-wasabi.local',
#      database_type      => 'mysql',
#    }
#  }
#
#  node 'wdpuppet04.dj-wasabi.local' {
#    #class { 'postgresql::server':
#    #    listen_addresses => '192.168.20.14'
#    #  }
#      class { 'mysql::server':
#        override_options => {
#          'mysqld'       => {
#            'bind_address' => '192.168.20.14',
#          },
#        },
#      }
#    class { 'zabbix::database':
#      database_type     => 'mysql',
#      zabbix_type       => 'proxy',
#      #zabbix_proxy_ip   => '192.168.20.13',
#      zabbix_proxy      => 'wdpuppet03.dj-wasabi.local',
#      database_name     => 'zabbix-proxy',
#      database_user     => 'zabbix-proxy',
#      database_password => 'zabbix-proxy',
#    }
#  }
#
#  The example of above is running the proxy with an mysql backend. When
#  you want to use postgresql, you'll need to uncomment the postgresql class
#  and the zabbix_proxy_ip and comment the mysql class, database_type and the
#  zabbix_proxy parameters.
#
# === Authors
#
# Author Name: ikben@werner-dijkerman.nl
#
# === Copyright
#
# Copyright 2014 Werner Dijkerman
#
class zabbix::proxy (
  Zabbix::Databases $database_type          = $zabbix::params::database_type,
  $database_path                            = $zabbix::params::database_path,
  $zabbix_version                           = $zabbix::params::zabbix_version,
  $zabbix_package_state                     = $zabbix::params::zabbix_package_state,
  Boolean $manage_database                  = $zabbix::params::manage_database,
  Boolean $manage_firewall                  = $zabbix::params::manage_firewall,
  Boolean $manage_repo                      = $zabbix::params::manage_repo,
  Boolean $manage_resources                 = $zabbix::params::manage_resources,
  Boolean $manage_service                   = $zabbix::params::manage_service,
  $zabbix_proxy                             = $zabbix::params::zabbix_proxy,
  $zabbix_proxy_ip                          = $zabbix::params::zabbix_proxy_ip,
  $use_ip                                   = $zabbix::params::proxy_use_ip,
  $zbx_templates                            = $zabbix::params::proxy_zbx_templates,
  $proxy_configfile_path                    = $zabbix::params::proxy_configfile_path,
  $proxy_service_name                       = $zabbix::params::proxy_service_name,
  $mode                                     = $zabbix::params::proxy_mode,
  $zabbix_server_host                       = $zabbix::params::proxy_zabbix_server_host,
  $zabbix_server_port                       = $zabbix::params::proxy_zabbix_server_port,
  $hostname                                 = $zabbix::params::proxy_hostname,
  $listenport                               = $zabbix::params::proxy_listenport,
  $sourceip                                 = $zabbix::params::proxy_sourceip,
  Integer[0] $enableremotecommands          = $zabbix::params::proxy_enableremotecommands,
  Integer[0] $logremotecommands             = $zabbix::params::proxy_logremotecommands,
  $logfile                                  = $zabbix::params::proxy_logfile,
  $logfilesize                              = $zabbix::params::proxy_logfilesize,
  $debuglevel                               = $zabbix::params::proxy_debuglevel,
  $pidfile                                  = $zabbix::params::proxy_pidfile,
  $database_schema_path                     = $zabbix::params::database_schema_path,
  $database_host                            = $zabbix::params::proxy_database_host,
  $database_name                            = $zabbix::params::proxy_database_name,
  $database_schema                          = $zabbix::params::proxy_database_schema,
  $database_user                            = $zabbix::params::proxy_database_user,
  $database_password                        = $zabbix::params::proxy_database_password,
  $database_socket                          = $zabbix::params::proxy_database_socket,
  $database_port                            = $zabbix::params::proxy_database_port,
  $localbuffer                              = $zabbix::params::proxy_localbuffer,
  $offlinebuffer                            = $zabbix::params::proxy_offlinebuffer,
  $heartbeatfrequency                       = $zabbix::params::proxy_heartbeatfrequency,
  $configfrequency                          = $zabbix::params::proxy_configfrequency,
  $datasenderfrequency                      = $zabbix::params::proxy_datasenderfrequency,
  $startpollers                             = $zabbix::params::proxy_startpollers,
  $startipmipollers                         = $zabbix::params::proxy_startipmipollers,
  $startpollersunreachable                  = $zabbix::params::proxy_startpollersunreachable,
  $starttrappers                            = $zabbix::params::proxy_starttrappers,
  $startpingers                             = $zabbix::params::proxy_startpingers,
  $startdiscoverers                         = $zabbix::params::proxy_startdiscoverers,
  $starthttppollers                         = $zabbix::params::proxy_starthttppollers,
  $javagateway                              = $zabbix::params::proxy_javagateway,
  $javagatewayport                          = $zabbix::params::proxy_javagatewayport,
  $startjavapollers                         = $zabbix::params::proxy_startjavapollers,
  $startvmwarecollectors                    = $zabbix::params::proxy_startvmwarecollectors,
  $vmwarefrequency                          = $zabbix::params::proxy_vmwarefrequency,
  $vmwareperffrequency                      = $zabbix::params::proxy_vmwareperffrequency,
  $vmwarecachesize                          = $zabbix::params::proxy_vmwarecachesize,
  $vmwaretimeout                            = $zabbix::params::proxy_vmwaretimeout,
  $enablesnmpbulkrequests                   = $zabbix::params::proxy_enablesnmpbulkrequests,
  $snmptrapperfile                          = $zabbix::params::proxy_snmptrapperfile,
  $snmptrapper                              = $zabbix::params::proxy_snmptrapper,
  $listenip                                 = $zabbix::params::proxy_listenip,
  $housekeepingfrequency                    = $zabbix::params::proxy_housekeepingfrequency,
  $cachesize                                = $zabbix::params::proxy_cachesize,
  $startdbsyncers                           = $zabbix::params::proxy_startdbsyncers,
  $historycachesize                         = $zabbix::params::proxy_historycachesize,
  $historyindexcachesize                    = $zabbix::params::proxy_historyindexcachesize,
  $historytextcachesize                     = $zabbix::params::proxy_historytextcachesize,
  $timeout                                  = $zabbix::params::proxy_timeout,
  $tlsaccept                                = $zabbix::params::proxy_tlsaccept,
  $tlscafile                                = $zabbix::params::proxy_tlscafile,
  $tlscertfile                              = $zabbix::params::proxy_tlscertfile,
  $tlsconnect                               = $zabbix::params::proxy_tlsconnect,
  $tlscrlfile                               = $zabbix::params::proxy_tlscrlfile,
  $tlskeyfile                               = $zabbix::params::proxy_tlskeyfile,
  $tlspskfile                               = $zabbix::params::proxy_tlspskfile,
  $tlspskidentity                           = $zabbix::params::proxy_tlspskidentity,
  $tlsservercertissuer                      = $zabbix::params::proxy_tlsservercertissuer,
  $tlsservercertsubject                     = $zabbix::params::proxy_tlsservercertsubject,
  $trappertimeout                           = $zabbix::params::proxy_trappertimeout,
  $unreachableperiod                        = $zabbix::params::proxy_unreachableperiod,
  $unavailabledelay                         = $zabbix::params::proxy_unavailabledelay,
  $unreachabledelay                          = $zabbix::params::proxy_unreachabledelay,
  $externalscripts                          = $zabbix::params::proxy_externalscripts,
  $fpinglocation                            = $zabbix::params::proxy_fpinglocation,
  $fping6location                           = $zabbix::params::proxy_fping6location,
  $sshkeylocation                           = $zabbix::params::proxy_sshkeylocation,
  $logslowqueries                           = $zabbix::params::proxy_logslowqueries,
  $tmpdir                                   = $zabbix::params::proxy_tmpdir,
  $allowroot                                = $zabbix::params::proxy_allowroot,
  $include_dir                              = $zabbix::params::proxy_include,
  $loadmodulepath                           = $zabbix::params::proxy_loadmodulepath,
  $loadmodule                               = $zabbix::params::proxy_loadmodule,
  Boolean $manage_selinux                   = $zabbix::params::manage_selinux,
  Optional[Stdlib::Absolutepath] $socketdir = $zabbix::params::proxy_socketdir,
) inherits zabbix::params {
  # check osfamily, Arch is currently not supported for web
  if $facts['os']['family'] == 'Archlinux' {
    fail('Archlinux is currently not supported for zabbix::proxy ')
  }

  # Find if listenip is set. If not, we can set to specific ip or
  # to network name. If more than 1 interfaces are available, we
  # can find the ipaddress of this specific interface if listenip
  # is set to for example "eth1" or "bond0.73".
  if ($listenip != undef) {
    if ($listenip =~ /^(eth|lo|bond|lxc|eno|tap|tun).*/) {
      $listen_ip = getvar("::ipaddress_${listenip}")
    } elsif $listenip =~ Stdlib::IP::Address {
      $listen_ip = $listenip
    } else {
      $listen_ip = undef
    }
  }

  # So if manage_resources is set to true, we can send some data
  # to the puppetdb. We will include an class, otherwise when it
  # is set to false, you'll get warnings like this:
  # "Warning: You cannot collect without storeconfigs being set"
  if $manage_resources {
    if String($mode) == '0' {
      # Active proxies don't use `ipaddress`, `use_ip` or `port`.
      class { 'zabbix::resources::proxy':
        hostname => $hostname,
        mode     => $mode,
      }
    } else {
      class { 'zabbix::resources::proxy':
        hostname  => $hostname,
        ipaddress => $listen_ip,
        use_ip    => $use_ip,
        mode      => $mode,
        port      => $listenport,
      }
    }

    zabbix::userparameters { 'Zabbix_Proxy': template => 'Template App Zabbix Proxy', }
  }

  # Get the correct database_type. We need this for installing the
  # correct package and loading the sql files.
  case $database_type {
    'postgresql' : { $db = 'pgsql' }
    'mysql'      : { $db = 'mysql' }
    'sqlite'     : { $db = 'sqlite3' }
    default      : { fail("Unrecognized database type for proxy: ${database_type}") }
  }

  if $manage_database {
    case $database_type {
      'postgresql' : {
        # Execute the postgresql scripts
        class { 'zabbix::database::postgresql':
          zabbix_type          => 'proxy',
          zabbix_version       => $zabbix_version,
          database_schema_path => $database_schema_path,
          database_name        => $database_name,
          database_user        => $database_user,
          database_password    => $database_password,
          database_host        => $database_host,
          database_path        => $database_path,
          require              => Package["zabbix-proxy-${db}"],
        }
      }
      'mysql'      : {
        # Execute the mysql scripts
        class { 'zabbix::database::mysql':
          zabbix_type          => 'proxy',
          zabbix_version       => $zabbix_version,
          database_schema_path => $database_schema_path,
          database_name        => $database_name,
          database_user        => $database_user,
          database_password    => $database_password,
          database_host        => $database_host,
          database_path        => $database_path,
          require              => Package["zabbix-proxy-${db}"],
        }
      }

      'sqlite'      : {}

      default      : {
        fail("Unrecognized database type for proxy: ${database_type}")
      }
    }
  }

  # Only include the repo class if it has not yet been included
  unless defined(Class['Zabbix::Repo']) {
    class { 'zabbix::repo':
      manage_repo    => $manage_repo,
      zabbix_version => $zabbix_version,
    }

    Package["zabbix-proxy-${db}"] {
      require => Class['zabbix::repo']
    }
  }

  # Now we are going to install the correct packages.
  case $facts['os']['name'] {
    'redhat', 'centos', 'oraclelinux', 'VirtuozzoLinux': {
      #There is no zabbix-proxy package in 3.0
      if versioncmp('3.0',$zabbix_version) > 0 {
        package { 'zabbix-proxy':
          ensure  => $zabbix_package_state,
          require => Package["zabbix-proxy-${db}"],
          tag     => 'zabbix',
        }
      }

      # Installing the packages
      package { "zabbix-proxy-${db}":
        ensure => $zabbix_package_state,
        tag    => 'zabbix',
      }
    } # END 'redhat','centos','oraclelinux'
    default : {
      # Installing the packages
      package { "zabbix-proxy-${db}":
        ensure => $zabbix_package_state,
        tag    => 'zabbix',
      }
    } # END default
  } # END case $facts['os']['name']

  # Controlling the 'zabbix-proxy' service
  if $manage_service {
    service { $proxy_service_name:
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      subscribe  => [
        File[$proxy_configfile_path],
        Class['zabbix::database']
      ],
      require    => [
        Package["zabbix-proxy-${db}"],
        File[$include_dir],
        File[$proxy_configfile_path],
        Class['zabbix::database']
      ],
    }
  }

  $before_database = $manage_service ? {
    true  => [
      Service[$proxy_service_name],
      Class["zabbix::database::${database_type}"]
    ],
    false => Class["zabbix::database::${database_type}"],
  }

  # if we want to manage the databases, we do
  # some stuff. (for maintaining database only.)
  if $manage_database {
    class { 'zabbix::database':
      database_type     => $database_type,
      zabbix_type       => 'proxy',
      database_name     => $database_name,
      database_user     => $database_user,
      database_password => $database_password,
      database_host     => $database_host,
      zabbix_proxy      => $zabbix_proxy,
      zabbix_proxy_ip   => $zabbix_proxy_ip,
      before            => $before_database,
    }
  }

  # Configuring the zabbix-proxy configuration file
  file { $proxy_configfile_path:
    ensure  => file,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0644',
    require => Package["zabbix-proxy-${db}"],
    replace => true,
    content => template('zabbix/zabbix_proxy.conf.erb'),
  }

  # Include dir for specific zabbix-proxy checks.
  file { $include_dir:
    ensure  => directory,
    require => File[$proxy_configfile_path],
  }

  # Manage firewall
  if $manage_firewall {
    firewall { '151 zabbix-proxy':
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

  # check if selinux is active and allow zabbix
  if fact('os.selinux.enabled') == true and $manage_selinux {
    selboolean { 'zabbix_can_network':
      persistent => true,
      value      => 'on',
    }
  }
}
