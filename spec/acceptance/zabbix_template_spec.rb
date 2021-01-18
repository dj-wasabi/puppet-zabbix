require 'spec_helper_acceptance'
require 'serverspec_type_zabbixapi'

describe 'zabbix_template type' do
  context 'create zabbix_template resources' do
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

        zabbix_template { 'TestTemplate1':
          template_source => '/root/TestTemplate1.xml',
          require         => [ Service['zabbix-server'], Package['zabbixapi'], ],
        }
      EOS

      shell("echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?><zabbix_export><version>4.0</version><date>2018-12-13T15:00:46Z</date><groups><group><name>Templates/Applications</name></group></groups><templates><template><template>TestTemplate1</template><name>TestTemplate1</name><description/><groups><group><name>Templates/Applications</name></group></groups><applications/><items/><discovery_rules/><macros/><templates/><screens/></template></templates></zabbix_export>' > /root/TestTemplate1.xml")

      # Cleanup old database
      prepare_host

      apply_manifest(pp, catch_failures: true)
    end

    let(:result_templates) do
      zabbixapi('localhost', 'Admin', 'zabbix', 'template.get', selectApplications: ['name'],
                                                                output: ['host']).result
    end

    context 'TestTemplate1' do
      let(:template1) { result_templates.select { |t| t['host'] == 'TestTemplate1' }.first }

      it 'is created' do
        expect(template1['host']).to eq('TestTemplate1')
      end
    end
  end
end
