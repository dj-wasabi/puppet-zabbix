require 'spec_helper'

describe 'zabbix::sender' do
  let :node do
    'agent.example.com'
  end
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts.merge(
          mocked_facts
        )
      end
      context 'with all defaults' do
        it { should contain_class('zabbix::sender') }
        it { should compile.with_all_deps }
        # Make sure package will be installed, service running and ensure of directory.
        it { should contain_package('zabbix-sender').with_ensure('present') }
        it { should contain_package('zabbix-sender').with_name('zabbix-sender') }
      end
      context 'when declaring manage_repo is true' do
        let :params do
          {
            manage_repo: true
          }
        end
        if facts[:osfamily] == 'Archlinux'
          it 'fails' do
            should raise_error(Puppet::Error, /Unrecognized operating system for webserver/)
          end
        else
          it { should contain_class('zabbix::repo').with_zabbix_version('3.0') }
          it { should contain_package('zabbix-sender').with_require('Class[Zabbix::Repo]') }
        end
      end
    end
  end
end
