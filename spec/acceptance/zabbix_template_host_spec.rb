require 'spec_helper_acceptance'
require 'serverspec_type_zabbixapi'

describe 'zabbix_template_host type' do
  context 'create zabbix_template_host resources' do
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

        zabbix_host { 'test1.example.com':
          ipaddress    => '127.0.0.1',
          use_ip       => true,
          port         => 10050,
          group        => 'TestgroupOne',
          group_create => true,
          templates    => [ 'Template OS Linux by Zabbix agent', ],
          require      => [ Service['zabbix-server'], Package['zabbixapi'], ],
        }

        zabbix_template { 'TestTemplate1':
          template_source => '/root/TestTemplate1.xml',
          require         => [ Service['zabbix-server'], Package['zabbixapi'], ],
        }

        zabbix_template_host{"TestTemplate1@test1.example.com":
          require => [ Service['zabbix-server'], Package['zabbixapi'], ],
        }
      EOS

      shell("echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?><zabbix_export><version>4.0</version><date>2018-12-13T15:00:46Z</date><groups><group><name>Templates/Applications</name></group></groups><templates><template><template>TestTemplate1</template><name>TestTemplate1</name><description/><groups><group><name>Templates/Applications</name></group></groups><applications/><items/><discovery_rules/><macros/><templates/><screens/></template></templates></zabbix_export>' > /root/TestTemplate1.xml")

      # Cleanup old database
      prepare_host

      apply_manifest(pp, catch_failures: true)
    end

    let(:result_hosts) do
      zabbixapi('localhost', 'Admin', 'zabbix', 'host.get', selectParentTemplates: ['host'],
                                                            selectInterfaces: %w[dns ip main port type useip],
                                                            selectGroups: ['name'], output: ['host', '']).result
    end

    context 'test1.example.com' do
      let(:test1) { result_hosts.select { |h| h['host'] == 'test1.example.com' }.first }

      it 'has template TestTemplate1 attached' do
        expect(test1['parentTemplates'].map { |t| t['host'] }.sort).to include('TestTemplate1')
      end
    end
  end
end
