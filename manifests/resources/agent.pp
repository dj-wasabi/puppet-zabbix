# == Class zabbix::resources::agent
#
# This will create an resources into puppetdb
# for automatically configuring agent into
# zabbix front-end.
#
# === Requirements
#
# Nothing.
#
# When manage_resource is set to true, this class
# will be loaded from 'zabbix::agent'. So no need
# for loading this class manually.
#
#
class zabbix::resources::agent (
  $hostname                = undef,
  $ipaddress               = undef,
  $use_ip                  = undef,
  $port                    = undef,
  $group                   = undef,
  Array[String[1]] $groups = undef,
  $group_create            = undef,
  $templates               = undef,
  $macros                  = undef,
  $proxy                   = undef,
  $tls_connect             = undef,
  $tls_accept              = undef,
  $tls_issuer              = undef,
  $tls_subject             = undef,
  $tls_psk_identity        = undef,
  $tls_psk                 = undef,
  $purge_templates         = undef,
) {
  if $group and $groups {
    fail("Got group and groups. This isn't support! Please use groups only.")
  } else {
    if $group {
      warning('Passing group to zabbix::resources::agent is deprecated and will be removed. Use groups instead.')
      $_groups = Array($group)
    } else {
      $_groups = $groups
    }
  }

  @@zabbix_host { $hostname:
    ipaddress        => $ipaddress,
    use_ip           => $use_ip,
    port             => $port,
    groups           => $_groups,
    group_create     => $group_create,
    templates        => $templates,
    macros           => $macros,
    proxy            => $proxy,
    tls_connect      => $tls_connect,
    tls_accept       => $tls_accept,
    tls_issuer       => $tls_issuer,
    tls_subject      => $tls_subject,
    tls_psk_identity => $tls_psk_identity,
    tls_psk          => $tls_psk,
    purge_templates  => $purge_templates,
  }
}
