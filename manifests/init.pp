# == Class: zabbix
#
#  This will install and configure the zabbix-server on a single host.
#
#  Before release 1.0.0, there was one single class that was used for
#  installing zabbix-server components. So, this zabbix-server class
#  could only be used when you have only 1 server. When you want to use
#  multiple servers, than you had an problem (Or you just couldn't use
#  this puppet module).
#
#  With release 1.0.0, this zabbix-server class is split in 3 classes:
#    - zabbix::web
#    - zabbix::server
#    - zabbix::database
#
#  As not everyone is using an multiple host setup, this init.pp is created.
#  Besides some renaming of some parameters, this class can be used like
#  how the zabbix::server was used before release 1.0.0. Instead of using
#  class { 'zabbix::server':
#    zabbix_url => 'zabbix.dj-wasabi.nl',
#  }
#  you can now use:
#  class { 'zabbix':
#    zabbix_url => 'zabbix.dj-wasabi.nl',
#  }
#
# === Requirements
#
# === Parameters
#
#   All of the parameters which can be used in this script can be found in
#   one of the following classes:
#    - zabbix::web
#    - zabbix::server
#    - zabbix::database
#
#   When you want to run an multiple host setup, please check the classes
#   which are mentioned above. This class is single node only.
#
# === Example
#
#  When running everything on a single host, you can use the following
#  setup:
#
#  class { 'zabbix':
#    zabbix_url => 'zabbix.dj-wasabi.nl',
#  }
#
#  This assumes that you want to use the postgresql database. If not and
#  you want to supply your own database crendentials:
#
#  class { 'zabbix':
#    zabbix_url        => 'zabbix.dj-wasabi.nl',
#    database_type     => 'mysql',
#    database_user     => 'zabbix',
#    database_password => 'ThisIsVeryDifficult.nl',
#  }
#
#  When you want to run this module on multiple hosts, you'll have to check
#  the following classes (They have their own documentation):
#    - zabbix::web
#    - zabbix::server
#    - zabbix::database
#
# === Authors
#
# Author Name: ikben@werner-dijkerman.nl
#
# === Copyright
#
# Copyright 2014 Werner Dijkerman
#
class zabbix (
  $zabbix_url                                                                 = '',
  $zabbix_version                                                             = $zabbix::params::zabbix_version,
  $zabbix_package_state                                                       = $zabbix::params::zabbix_package_state,
  $zabbix_timezone                                                            = $zabbix::params::zabbix_timezone,
  $zabbix_web                                                                 = $zabbix::params::zabbix_web,
  $zabbix_server                                                              = $zabbix::params::zabbix_server,
  $zabbix_server_ip                                                           = $zabbix::params::zabbix_server_ip,
  $zabbix_template_dir                                                        = $zabbix::params::zabbix_template_dir,
  $zabbix_web_ip                                                              = $zabbix::params::zabbix_web_ip,
  Zabbix::Databases $database_type                                            = $zabbix::params::database_type,
  $database_path                                                              = $zabbix::params::database_path,
  $manage_database                                                            = $zabbix::params::manage_database,
  $default_vhost                                                              = $zabbix::params::default_vhost,
  $manage_vhost                                                               = $zabbix::params::manage_vhost,
  $manage_firewall                                                            = $zabbix::params::manage_firewall,
  $manage_repo                                                                = $zabbix::params::manage_repo,
  $manage_resources                                                           = $zabbix::params::manage_resources,
  $manage_service                                                             = $zabbix::params::manage_service,
  $apache_use_ssl                                                             = $zabbix::params::apache_use_ssl,
  $apache_ssl_cert                                                            = $zabbix::params::apache_ssl_cert,
  $apache_ssl_key                                                             = $zabbix::params::apache_ssl_key,
  $apache_ssl_cipher                                                          = $zabbix::params::apache_ssl_cipher,
  $apache_ssl_chain                                                           = $zabbix::params::apache_ssl_chain,
  $apache_listen_ip                                                           = $zabbix::params::apache_listen_ip,
  $apache_listenport                                                          = $zabbix::params::apache_listenport,
  $apache_listenport_ssl                                                      = $zabbix::params::apache_listenport_ssl,
  $apache_php_max_execution_time                                              = $zabbix::params::apache_php_max_execution_time,
  $apache_php_memory_limit                                                    = $zabbix::params::apache_php_memory_limit,
  $apache_php_post_max_size                                                   = $zabbix::params::apache_php_post_max_size,
  $apache_php_upload_max_filesize                                             = $zabbix::params::apache_php_upload_max_filesize,
  $apache_php_max_input_time                                                  = $zabbix::params::apache_php_max_input_time,
  $apache_php_always_populate_raw_post_data                                   = $zabbix::params::apache_php_always_populate_raw_post_data,
  Optional[Stdlib::Absolutepath] $ldap_cacert                                 = $zabbix::params::ldap_cacert,
  Optional[Stdlib::Absolutepath] $ldap_clientcert                             = $zabbix::params::ldap_clientcert,
  Optional[Stdlib::Absolutepath] $ldap_clientkey                              = $zabbix::params::ldap_clientkey,
  Optional[Enum['never', 'allow', 'try', 'demand', 'hard']] $ldap_reqcert     = $zabbix::params::ldap_reqcert,
  $zabbix_api_user                                                            = $zabbix::params::server_api_user,
  $zabbix_api_pass                                                            = $zabbix::params::server_api_pass,
  $listenport                                                                 = $zabbix::params::server_listenport,
  $sourceip                                                                   = $zabbix::params::server_sourceip,
  Enum['console', 'file', 'system'] $logtype                                  = $zabbix::params::server_logtype,
  Optional[Stdlib::Absolutepath] $logfile                                     = $zabbix::params::server_logfile,
  $logfilesize                                                                = $zabbix::params::server_logfilesize,
  $debuglevel                                                                 = $zabbix::params::server_debuglevel,
  $pidfile                                                                    = $zabbix::params::server_pidfile,
  $database_host                                                              = $zabbix::params::server_database_host,
  $database_name                                                              = $zabbix::params::server_database_name,
  $database_schema                                                            = $zabbix::params::server_database_schema,
  Boolean $database_double_ieee754                                            = $zabbix::params::server_database_double_ieee754,
  $database_user                                                              = $zabbix::params::server_database_user,
  $database_password                                                          = $zabbix::params::server_database_password,
  $database_socket                                                            = $zabbix::params::server_database_socket,
  $database_port                                                              = $zabbix::params::server_database_port,
  $database_charset                                                           = $zabbix::params::server_database_charset,
  $database_collate                                                           = $zabbix::params::server_database_collate,
  $database_tablespace                                                        = $zabbix::params::server_database_tablespace,
  Optional[Enum['required', 'verify_ca', 'verify_full']] $database_tlsconnect = $zabbix::params::server_database_tlsconnect,
  Optional[Stdlib::Absolutepath] $database_tlscafile                          = $zabbix::params::server_database_tlscafile,
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
  Zabbix::Historyics $historyindexcachesize                                   = $zabbix::params::server_historyindexcachesize,
  $trendcachesize                                                             = $zabbix::params::server_trendcachesize,
  $valuecachesize                                                             = $zabbix::params::server_valuecachesize,
  $timeout                                                                    = $zabbix::params::server_timeout,
  $tlscafile                                                                  = $zabbix::params::server_tlscafile,
  $tlscertfile                                                                = $zabbix::params::server_tlscertfile,
  $tlscrlfile                                                                 = $zabbix::params::server_tlscrlfile,
  $tlskeyfile                                                                 = $zabbix::params::server_tlskeyfile,
  $tlscipherall                                                               = $zabbix::params::server_tlscipherall,
  $tlscipherall13                                                             = $zabbix::params::server_tlscipherall13,
  $tlsciphercert                                                              = $zabbix::params::server_tlsciphercert,
  $tlsciphercert13                                                            = $zabbix::params::server_tlsciphercert13,
  $tlscipherpsk                                                               = $zabbix::params::server_tlscipherpsk,
  $tlscipherpsk13                                                             = $zabbix::params::server_tlscipherpsk13,
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
  Optional[Stdlib::Absolutepath] $socketdir                                   = $zabbix::params::server_socketdir,
  $sslcertlocation_dir                                                        = $zabbix::params::server_sslcertlocation,
  $sslkeylocation_dir                                                         = $zabbix::params::server_sslkeylocation,
  Optional[Stdlib::Absolutepath] $sslcalocation_dir                           = $zabbix::params::server_sslcalocation_dir,
  Boolean $manage_selinux                                                     = $zabbix::params::manage_selinux,
  String $additional_service_params                                           = $zabbix::params::additional_service_params,
  Optional[String[1]] $zabbix_user                                            = $zabbix::params::server_zabbix_user,
  Optional[String] $zabbix_server_name                                        = $zabbix::params::zabbix_server,
  Optional[Stdlib::Absolutepath] $saml_sp_key                                 = $zabbix::params::saml_sp_key,
  Optional[Stdlib::Absolutepath] $saml_sp_cert                                = $zabbix::params::saml_sp_cert,
  Optional[Stdlib::Absolutepath] $saml_idp_cert                               = $zabbix::params::saml_idp_cert,
  Hash[String[1], Variant[ScalarData, Hash]] $saml_settings                   = $zabbix::params::saml_settings,
) inherits zabbix::params {
  class { 'zabbix::web':
    zabbix_url                               => $zabbix_url,
    database_type                            => $database_type,
    manage_repo                              => $manage_repo,
    zabbix_version                           => $zabbix_version,
    zabbix_package_state                     => $zabbix_package_state,
    zabbix_timezone                          => $zabbix_timezone,
    zabbix_template_dir                      => $zabbix_template_dir,
    manage_vhost                             => $manage_vhost,
    manage_resources                         => $manage_resources,
    apache_use_ssl                           => $apache_use_ssl,
    apache_ssl_cert                          => $apache_ssl_cert,
    apache_ssl_key                           => $apache_ssl_key,
    apache_ssl_cipher                        => $apache_ssl_cipher,
    apache_ssl_chain                         => $apache_ssl_chain,
    apache_listen_ip                         => $apache_listen_ip,
    apache_listenport                        => $apache_listenport,
    apache_listenport_ssl                    => $apache_listenport_ssl,
    zabbix_api_user                          => $zabbix_api_user,
    zabbix_api_pass                          => $zabbix_api_pass,
    database_host                            => $database_host,
    database_name                            => $database_name,
    database_schema                          => $database_schema,
    database_double_ieee754                  => $database_double_ieee754,
    database_user                            => $database_user,
    database_password                        => $database_password,
    database_socket                          => $database_socket,
    database_port                            => $database_port,
    zabbix_server                            => $zabbix_server,
    zabbix_server_name                       => $zabbix_server_name,
    zabbix_listenport                        => $listenport,
    apache_php_max_execution_time            => $apache_php_max_execution_time,
    apache_php_memory_limit                  => $apache_php_memory_limit,
    apache_php_post_max_size                 => $apache_php_post_max_size,
    apache_php_upload_max_filesize           => $apache_php_upload_max_filesize,
    apache_php_max_input_time                => $apache_php_max_input_time,
    apache_php_always_populate_raw_post_data => $apache_php_always_populate_raw_post_data,
    ldap_cacert                              => $ldap_cacert,
    ldap_clientcert                          => $ldap_clientcert,
    ldap_clientkey                           => $ldap_clientkey,
    ldap_reqcert                             => $ldap_reqcert,
    saml_sp_key                              => $saml_sp_key,
    saml_sp_cert                             => $saml_sp_cert,
    saml_idp_cert                            => $saml_idp_cert,
    saml_settings                            => $saml_settings,
    manage_selinux                           => $manage_selinux,
    require                                  => Class['zabbix::server'],
  }

  class { 'zabbix::server':
    database_type             => $database_type,
    database_path             => $database_path,
    zabbix_version            => $zabbix_version,
    zabbix_package_state      => $zabbix_package_state,
    manage_firewall           => $manage_firewall,
    manage_repo               => $manage_repo,
    manage_database           => $manage_database,
    manage_service            => $manage_service,
    listenport                => $listenport,
    sourceip                  => $sourceip,
    logfile                   => $logfile,
    logfilesize               => $logfilesize,
    logtype                   => $logtype,
    debuglevel                => $debuglevel,
    pidfile                   => $pidfile,
    database_host             => $database_host,
    database_name             => $database_name,
    database_schema           => $database_schema,
    database_user             => $database_user,
    database_password         => $database_password,
    database_socket           => $database_socket,
    database_port             => $database_port,
    database_tlsconnect       => $database_tlsconnect,
    database_tlscafile        => $database_tlscafile,
    startpollers              => $startpollers,
    startipmipollers          => $startipmipollers,
    startpollersunreachable   => $startpollersunreachable,
    startpreprocessors        => $startpreprocessors,
    starttrappers             => $starttrappers,
    startpingers              => $startpingers,
    startalerters             => $startalerters,
    startdiscoverers          => $startdiscoverers,
    startescalators           => $startescalators,
    starthttppollers          => $starthttppollers,
    starttimers               => $starttimers,
    javagateway               => $javagateway,
    javagatewayport           => $javagatewayport,
    startjavapollers          => $startjavapollers,
    startlldprocessors        => $startlldprocessors,
    startvmwarecollectors     => $startvmwarecollectors,
    vmwarefrequency           => $vmwarefrequency,
    vmwarecachesize           => $vmwarecachesize,
    vmwaretimeout             => $vmwaretimeout,
    snmptrapperfile           => $snmptrapperfile,
    startsnmptrapper          => $startsnmptrapper,
    listenip                  => $listenip,
    housekeepingfrequency     => $housekeepingfrequency,
    maxhousekeeperdelete      => $maxhousekeeperdelete,
    cachesize                 => $cachesize,
    cacheupdatefrequency      => $cacheupdatefrequency,
    startdbsyncers            => $startdbsyncers,
    historycachesize          => $historycachesize,
    trendcachesize            => $trendcachesize,
    historyindexcachesize     => $historyindexcachesize,
    valuecachesize            => $valuecachesize,
    timeout                   => $timeout,
    tlscafile                 => $tlscafile,
    tlscertfile               => $tlscertfile,
    tlscrlfile                => $tlscrlfile,
    tlskeyfile                => $tlskeyfile,
    tlscipherall              => $tlscipherall,
    tlscipherall13            => $tlscipherall13,
    tlsciphercert             => $tlsciphercert,
    tlsciphercert13           => $tlsciphercert13,
    tlscipherpsk              => $tlscipherpsk,
    tlscipherpsk13            => $tlscipherpsk13,
    trappertimeout            => $trappertimeout,
    unreachableperiod         => $unreachableperiod,
    unavailabledelay          => $unavailabledelay,
    unreachabledelay          => $unreachabledelay,
    alertscriptspath          => $alertscriptspath,
    externalscripts           => $externalscripts,
    fpinglocation             => $fpinglocation,
    fping6location            => $fping6location,
    sshkeylocation            => $sshkeylocation,
    logslowqueries            => $logslowqueries,
    tmpdir                    => $tmpdir,
    startproxypollers         => $startproxypollers,
    proxyconfigfrequency      => $proxyconfigfrequency,
    proxydatafrequency        => $proxydatafrequency,
    allowroot                 => $allowroot,
    include_dir               => $include_dir,
    loadmodulepath            => $loadmodulepath,
    loadmodule                => $loadmodule,
    sslcertlocation_dir       => $sslcertlocation_dir,
    sslkeylocation_dir        => $sslkeylocation_dir,
    sslcalocation_dir         => $sslcalocation_dir,
    manage_selinux            => $manage_selinux,
    additional_service_params => $additional_service_params,
    require                   => Class['zabbix::database'],
  }

  class { 'zabbix::database':
    zabbix_type         => 'server',
    zabbix_web          => $zabbix_web,
    zabbix_server       => $zabbix_server,
    zabbix_web_ip       => $zabbix_web_ip,
    zabbix_server_ip    => $zabbix_server_ip,
    manage_database     => $manage_database,
    database_type       => $database_type,
    database_name       => $database_name,
    database_user       => $database_user,
    database_password   => $database_password,
    database_host       => $database_host,
    database_charset    => $database_charset,
    database_collate    => $database_collate,
    database_tablespace => $database_tablespace,
  }
}
