require 'spec_helper_acceptance'
require 'serverspec_type_zabbixapi'

describe 'zabbix_application type' do
  context 'create zabbix_application resources' do
    # This will deploy a running Zabbix setup (server, web, db) which we can
    # use for custom type tests
    pp1 = <<-EOS
      $compile_packages = $facts['os']['family'] ? {
        'RedHat' => [ 'make', 'gcc-c++', ],
        'Debian' => [ 'make', 'g++', ],
        default  => [],
      }
      ensure_packages($compile_packages, { before => Package['zabbixapi'], })
      class { 'apache':
          mpm_module => 'prefork',
      }
      include apache::mod::php
      include postgresql::server

      class { 'zabbix':
        zabbix_version   => '4.4',
        zabbix_url       => 'localhost',
        zabbix_api_user  => 'Admin',
        zabbix_api_pass  => 'zabbix',
        apache_use_ssl   => false,
        manage_resources => true,
        require          => [ Class['postgresql::server'], Class['apache'], ],
      }

      EOS

    pp2 = <<-EOS
      zabbix_application { 'TestApplication1':
        template => 'Template OS Linux by Zabbix agent',
      }
    EOS
    # setup zabbix. Apache module isn't idempotent and requires a second run
    it 'works with no error on the first apply' do
      # Cleanup old database
      prepare_host

      apply_manifest(pp1, catch_failures: true)
    end
    it 'works with no error on the second apply' do
      apply_manifest(pp1, catch_failures: true)
    end

    # configure the applications within zabbix
    it 'works with no error on the third apply' do
      apply_manifest(pp2, catch_failures: true)
    end
    it 'works without changes on the fourth apply' do
      apply_manifest(pp2, catch_changes: true)
    end
  end

  let(:result_templates) do
    zabbixapi('localhost', 'Admin', 'zabbix', 'template.get', selectApplications: ['name'],
                                                              output: ['host']).result
  end

  context 'TestApplication1' do
    let(:template1) { result_templates.select { |t| t['host'] == 'Template OS Linux by Zabbix agent' }.first }

    it 'is attached to Template OS Linux by Zabbix agent' do
      expect(template1['applications'].map { |a| a['name'] }).to include('TestApplication1')
    end
  end
end
