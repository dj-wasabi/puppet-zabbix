# == Class: zabbix::repo
#
#  If enabled, this will install the repository used for installing zabbix
#
#  Please note:
#  This class will be called from zabbix::server, zabbix::proxy and
#  zabbix::agent. No need for calling this class manually.
#
# === Parameters
#
# [*manage_repo*]
#   When true, it will create repository for installing the server.
#
# [*zabbix_version*]
#   This is the zabbix version.
#
# [*repo_location*]
#   A custom repo location (e.g. your own mirror)
#
# [*unsupported_repo_location*]
#   A custom repo location for unsupported content (e.g. your own mirror)
#   Currently only supported under RedHat based systems.
#
# === Authors
#
# Author Name:
#   ikben@werner-dijkerman.nl
#   Tim Meusel <tim@bastelfreak.de>
#
# === Copyright
#
# Copyright 2014 Werner Dijkerman
#
class zabbix::repo (
  Boolean                   $manage_repo               = $zabbix::params::manage_repo,
  Boolean                   $manage_apt                = $zabbix::params::manage_apt,
  Optional[Stdlib::HTTPUrl] $repo_location             = $zabbix::params::repo_location,
  Optional[Stdlib::HTTPUrl] $frontend_repo_location    = $zabbix::params::frontend_repo_location,
  Optional[Stdlib::HTTPUrl] $unsupported_repo_location = $zabbix::params::unsupported_repo_location,
  String[1]                 $zabbix_version            = $zabbix::params::zabbix_version,
) inherits zabbix::params {
  if ($manage_repo) {
    case $facts['os']['name'] {
      'PSBM': {
        $majorrelease = '6'
      }
      'Amazon': {
        $majorrelease = '6'
      }
      'oraclelinux': {
        $majorrelease = $facts['os']['release']['major']
      }
      default: {
        $majorrelease = $facts['os']['release']['major']
      }
    }
    case $facts['os']['family'] {
      'RedHat': {
        $gpgkey_zabbix = 'https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-A14FE591'
        $gpgkey_nonsupported = 'https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-79EA5ED4'

        $_repo_location = $repo_location ? {
          undef   => "https://repo.zabbix.com/zabbix/${zabbix_version}/rhel/${majorrelease}/\$basearch/",
          default => $repo_location,
        }

        yumrepo { 'zabbix':
          name     => "Zabbix_${majorrelease}_${facts['os']['architecture']}",
          descr    => "Zabbix_${majorrelease}_${facts['os']['architecture']}",
          baseurl  => $_repo_location,
          gpgcheck => '1',
          gpgkey   => $gpgkey_zabbix,
          priority => '1',
        }

        $_unsupported_repo_location = $unsupported_repo_location ? {
          undef   => "https://repo.zabbix.com/non-supported/rhel/${majorrelease}/\$basearch/",
          default => $unsupported_repo_location,
        }

        yumrepo { 'zabbix-nonsupported':
          name     => "Zabbix_nonsupported_${majorrelease}_${facts['os']['architecture']}",
          descr    => "Zabbix_nonsupported_${majorrelease}_${facts['os']['architecture']}",
          baseurl  => $_unsupported_repo_location,
          gpgcheck => '1',
          gpgkey   => $gpgkey_nonsupported,
          priority => '1',
        }

        # Zabbix 5.0 frontend on CentOS 7 has different location.
        if ($facts['os']['name'] == 'CentOS' and $majorrelease == '7' and $zabbix_version == '5.0') {
          $_frontend_repo_location = $frontend_repo_location ? {
            undef   => "https://repo.zabbix.com/zabbix/${zabbix_version}/rhel/${majorrelease}/\$basearch/frontend",
            default => $frontend_repo_location,
          }

          yumrepo { 'zabbix-frontend':
            name     => "Zabbix_frontend_${majorrelease}_${facts['os']['architecture']}",
            descr    => "Zabbix_frontend_${majorrelease}_${facts['os']['architecture']}",
            baseurl  => $_frontend_repo_location,
            gpgcheck => '1',
            gpgkey   => $gpgkey_zabbix,
            priority => '1',
          }
        }
      }
      'Debian': {
        if ($manage_apt) {
          # We would like to provide the repos with https urls instead of http
          # this requires the apt-transport-https package, but we don't want to manage
          # that package here. That should be handled in a profile :(
          # somebody should implement https here but make it optional
          include apt
        }

        if ($facts['os']['architecture'] == 'armv6l') {
          $_repo_location = $repo_location ? {
            undef   => 'http://naizvoru.com/raspbian/zabbix',
            default => $repo_location,
          }

          apt::source { 'zabbix':
            location => $_repo_location,
            repos    => 'main',
            key      => {
              'id'     => 'BC274A7EA7FD5DD267C9A18FD54A213C80E871A7',
              'source' => 'https://naizvoru.com/raspbian/zabbix/conf/boris@steki.net.gpg.key',
            }
            ,
            include  => {
              'src' => false,
            }
            ,
          }
        } else {
          if ($facts['os']['distro'][id] == 'Raspbian') {
            $operatingsystem = 'raspbian'
          } elsif ($facts['os']['architecture'] == 'aarch64' and $facts['os']['distro']['codename'] == 'focal') {
            $operatingsystem = 'ubuntu-arm64'
            if versioncmp($zabbix_version, '5.0') < 0 {
              fail('Only packages for zabbix version 5.0 and newer are available for arm64!')
            }
          } else {
            $operatingsystem = downcase($facts['os']['name'])
          }
          case $facts['os']['release']['full'] {
            /\/sid$/: { $releasename = regsubst($facts['os']['release']['full'], '/sid$', '') }
            default: { $releasename = $facts['os']['distro']['codename'] }
          }

          $_repo_location = $repo_location ? {
            undef   => "http://repo.zabbix.com/zabbix/${zabbix_version}/${operatingsystem}/",
            default => $repo_location,
          }

          apt::key { 'zabbix-FBABD5F':
            id     => 'FBABD5FB20255ECAB22EE194D13D58E479EA5ED4',
            source => 'https://repo.zabbix.com/zabbix-official-repo.key',
          }
          apt::key { 'zabbix-A1848F5':
            id     => 'A1848F5352D022B9471D83D0082AB56BA14FE591',
            source => 'https://repo.zabbix.com/zabbix-official-repo.key',
          }
          apt::source { 'zabbix':
            location => $_repo_location,
            repos    => 'main',
            release  => $releasename,
            require  => [
              Apt_key['zabbix-FBABD5F'],
              Apt_key['zabbix-A1848F5'],
            ],
          }
        }
        Apt::Source['zabbix'] -> Package<|tag == 'zabbix'|>
        Class['Apt::Update'] -> Package<|tag == 'zabbix'|>
      }
      default: {
        fail("Managing a repo on ${facts['os']['family']} is currently not implemented")
      }
    }
  } # end if ($manage_repo)
}
