require 'spec_helper_acceptance'
require 'serverspec_type_zabbixapi'

describe 'zabbix_hostgroup type' do
  context 'create zabbix_hostgroup resources' do
    it 'runs successfully' do
      # This will deploy a running Zabbix setup (server, web, db) which we can
      # use for custom type tests
      pp = <<-EOS
        class { 'apache':
            mpm_module => 'prefork',
        }
        include apache::mod::php
        include postgresql::server

        class { 'zabbix':
          zabbix_url       => 'localhost',
          zabbix_api_user  => 'Admin',
          zabbix_api_pass  => 'zabbix',
          apache_use_ssl   => false,
          manage_resources => true,
          require          => [ Class['postgresql::server'], Class['apache'], ],
        }

        Zabbix_hostgroup {
          require => [ Service['zabbix-server'], Package['zabbixapi'], ],
        }

        zabbix_hostgroup { 'Testgroup2': }
        zabbix_hostgroup { 'Linux servers':
          ensure => absent,
        }
      EOS

      # Cleanup old database
      prepare_host

      apply_manifest(pp, catch_failures: true)
    end

    let(:result_hostgroups) do
      zabbixapi('localhost', 'Admin', 'zabbix', 'hostgroup.get', output: 'extend').result
    end

    context 'Testgroup2' do
      it 'is created' do
        expect(result_hostgroups.map { |t| t['name'] }).to include('Testgroup2')
      end
    end

    context 'Linux servers' do
      it 'is absent' do
        expect(result_hostgroups.map { |t| t['name'] }).not_to include('Linux servers')
      end
    end
  end
end
