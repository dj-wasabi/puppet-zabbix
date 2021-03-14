require 'spec_helper'

describe 'zabbix::database::postgresql' do
  let :node do
    'rspec.puppet.com'
  end

  let :pre_condition do
    'include postgresql::server'
  end

  on_supported_os.each do |os, facts|
    next if facts[:os]['name'] == 'windows'
    context "on #{os} " do
      let :facts do
        facts
      end

      case facts[:os]['name']
      when 'CentOS', 'RedHat'
        describe 'when zabbix_type is server' do
          let :params do
            {
              database_name: 'zabbix-server',
              database_user: 'zabbix-server',
              database_password: 'zabbix-server',
              database_host: 'node01.example.com',
              zabbix_type: 'server',
              zabbix_version: '2.4'
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('update_pgpass').with_command('echo 'node01.example.com:5432:zabbix-server:zabbix-server:zabbix-server' >> /root/.pgpass') }
          it { is_expected.to contain_exec('zabbix_server_create.sql').with_command("cd /usr/share/doc/zabbix-*-pgsql-2.4*/create && if [ -f schema.sql.gz ]; then gunzip -f schema.sql.gz ; fi && psql -h 'node01.example.com' -U 'zabbix-server' -d 'zabbix-server' -f schema.sql && touch /etc/zabbix/.schema.done") }
          it { is_expected.to contain_exec('zabbix_server_images.sql').with_command("cd /usr/share/doc/zabbix-*-pgsql-2.4*/create && if [ -f images.sql.gz ]; then gunzip -f images.sql.gz ; fi && psql -h 'node01.example.com' -U 'zabbix-server' -d 'zabbix-server' -f images.sql && touch /etc/zabbix/.images.done") }
          it { is_expected.to contain_exec('zabbix_server_data.sql').with_command("cd /usr/share/doc/zabbix-*-pgsql-2.4*/create && if [ -f data.sql.gz ]; then gunzip -f data.sql.gz ; fi && psql -h 'node01.example.com' -U 'zabbix-server' -d 'zabbix-server' -f data.sql && touch /etc/zabbix/.data.done") }
          it { is_expected.to contain_file('/root/.pgpass') }
          it { is_expected.to contain_class('zabbix::params') }
        end

        describe 'when zabbix_type is proxy' do
          let :params do
            {
              database_name: 'zabbix-proxy',
              database_user: 'zabbix-proxy',
              database_password: 'zabbix-proxy',
              database_host: 'node01.example.com',
              zabbix_type: 'proxy',
              zabbix_version: '2.4'
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('update_pgpass').with_command('echo node01.example.com:5432:zabbix-proxy:zabbix-proxy:zabbix-proxy >> /root/.pgpass') }
          it { is_expected.to contain_exec('zabbix_proxy_create.sql').with_command("cd /usr/share/doc/zabbix-*-pgsql-2.4*/create && if [ -f schema.sql.gz ]; then gunzip -f schema.sql.gz ; fi && psql -h 'node01.example.com' -U 'zabbix-proxy' -d 'zabbix-proxy' -f schema.sql && touch /etc/zabbix/.schema.done") }
          it { is_expected.to contain_class('zabbix::params') }
        end
      end
    end
  end
end
