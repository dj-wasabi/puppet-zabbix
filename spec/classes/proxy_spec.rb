require 'spec_helper'

describe 'zabbix::proxy' do
  let :node do
    'rspec.puppet.com'
  end

  on_supported_os.each do |os, facts|
    next if facts[:os]['name'] == 'windows'
    context "on #{os} " do
      let :facts do
        facts
      end

      case facts[:os]['name']
      when 'Archlinux'
        context 'with all defaults' do
          it { is_expected.not_to compile }
        end
      when 'RedHat'
        let :pre_condition do
          "include 'postgresql::server'
           include 'mysql::server'"
        end
        let :params do
          {
            zabbix_server_host: '192.168.1.1',
          }
        end

        it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf.d').with_ensure('directory') }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf.d').with_require('File[/etc/zabbix/zabbix_proxy.conf]') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('zabbix::params') }
        it { is_expected.to contain_exec('update_pgpass') }
        it { is_expected.to contain_exec('zabbix_proxy_create.sql') }
        it { is_expected.to contain_file('/root/.pgpass') }
        it { is_expected.to contain_postgresql__server__pg_hba_rule('Allow zabbix-proxy to access database') }

        describe 'when manage_repo is true and zabbix version is unset' do
          let :params do
            {
              manage_repo: true
            }
          end

          it { is_expected.to contain_class('zabbix::repo').with_zabbix_version('5.0') }
          it { is_expected.to contain_package('zabbix-proxy-pgsql').with_require('Class[Zabbix::Repo]') }
          it { is_expected.to contain_yumrepo('zabbix-nonsupported') }
          it { is_expected.to contain_yumrepo('zabbix') }
        end

        describe 'when manage_repo is true and zabbix version is 4.0' do
          let :params do
            {
              manage_repo: true,
              zabbix_version: '4.0'
            }
          end

          it { is_expected.to contain_class('zabbix::repo').with_zabbix_version('4.0') }
          it { is_expected.to contain_package('zabbix-proxy-pgsql').with_require('Class[Zabbix::Repo]') }
        end

        describe 'with enabled selinux' do
          let :facts do
            super().merge(selinux: true)
          end

          it { is_expected.to contain_selboolean('zabbix_can_network').with('value' => 'on', 'persistent' => true) }
        end

        describe 'when database_type is postgresql' do
          let :params do
            {
              database_type: 'postgresql'
            }
          end

          it { is_expected.to contain_package('zabbix-proxy-pgsql').with_ensure('present') }
          it { is_expected.to contain_package('zabbix-proxy-pgsql').with_name('zabbix-proxy-pgsql') }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_require('Package[zabbix-proxy-pgsql]') }
        end

        describe 'when database_type is mysql' do
          let :params do
            {
              database_type: 'mysql'
            }
          end

          it { is_expected.to contain_package('zabbix-proxy-mysql').with_ensure('present') }
          it { is_expected.to contain_package('zabbix-proxy-mysql').with_name('zabbix-proxy-mysql') }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_require('Package[zabbix-proxy-mysql]') }
        end

        describe 'when manage_resources is true' do
          let :params do
            {
              manage_resources: true,
              listenip: '192.168.1.1'
            }
          end

          it { is_expected.to contain_class('zabbix::resources::proxy') }
          it { is_expected.to contain_zabbix__userparameters('Zabbix_Proxy') }
        end

        context 'with zabbix::database::postgresql class' do
          let :params do
            {
              database_type: 'postgresql',
              manage_database: true
            }
          end

          it { is_expected.to contain_class('zabbix::database::postgresql').with_zabbix_type('proxy') }
          it { is_expected.to contain_class('zabbix::database::postgresql').with_zabbix_version('5.0') }
          it { is_expected.to contain_class('zabbix::database::postgresql').with_database_name('zabbix_proxy') }
          it { is_expected.to contain_class('zabbix::database::postgresql').with_database_user('zabbix-proxy') }
          it { is_expected.to contain_class('zabbix::database::postgresql').with_database_password('zabbix-proxy') }
          it { is_expected.to contain_class('zabbix::database::postgresql').with_database_host('localhost') }
        end

        context 'with zabbix::database::mysql class' do
          let(:params) do
            {
              database_type: 'mysql',
              manage_database: true
            }
          end

          let(:pre_condition) do
            "include 'mysql::server'"
          end

          it { is_expected.to contain_class('zabbix::database::mysql').with_zabbix_type('proxy') }
          it { is_expected.to contain_class('zabbix::database::mysql').with_zabbix_version('5.0') }
          it { is_expected.to contain_class('zabbix::database::mysql').with_database_name('zabbix_proxy') }
          it { is_expected.to contain_class('zabbix::database::mysql').with_database_user('zabbix-proxy') }
          it { is_expected.to contain_class('zabbix::database::mysql').with_database_password('zabbix-proxy') }
          it { is_expected.to contain_class('zabbix::database::mysql').with_database_host('localhost') }
          it { is_expected.to contain_mysql__db('zabbix_proxy') }
        end

        context 'when manage_database is true' do
          let(:params) do
            {
              manage_database: true
            }
          end

          it { is_expected.to contain_class('zabbix::database').with_zabbix_type('proxy') }
          it { is_expected.to contain_class('zabbix::database').with_database_type('postgresql') }
          it { is_expected.to contain_class('zabbix::database').with_database_name('zabbix_proxy') }
          it { is_expected.to contain_class('zabbix::database').with_database_user('zabbix-proxy') }
          it { is_expected.to contain_class('zabbix::database').with_database_password('zabbix-proxy') }
          it { is_expected.to contain_class('zabbix::database').with_database_host('localhost') }
          it { is_expected.to contain_class('zabbix::database').with_zabbix_proxy('localhost') }
          it { is_expected.to contain_class('zabbix::database').with_zabbix_proxy_ip('127.0.0.1') }
        end

        context 'when declaring manage_firewall is true' do
          let(:params) do
            {
              manage_firewall: true
            }
          end

          it { is_expected.to contain_firewall('151 zabbix-proxy') }
        end

        context 'when declaring manage_firewall is false' do
          let(:params) do
            {
              manage_firewall: false
            }
          end

          it { is_expected.not_to contain_firewall('151 zabbix-proxy') }
        end

        # If manage_service is true (default), it should create a service
        # and ensure that it is running.
        context 'when declaring manage_service is true' do
          let :params do
            {
              manage_service: true
            }
          end

          it { is_expected.to contain_service('zabbix-proxy').with_ensure('running') }
          it { is_expected.to contain_service('zabbix-proxy').with_enable('true') }
          it { is_expected.to contain_service('zabbix-proxy').with_require(['Package[zabbix-proxy-pgsql]', 'File[/etc/zabbix/zabbix_proxy.conf.d]', 'File[/etc/zabbix/zabbix_proxy.conf]', 'Class[Zabbix::Database]']) }
        end

        # When the manage_service is false, it may not make the service.
        context 'when declaring manage_service is false' do
          let :params do
            {
              manage_service: false
            }
          end

          it { is_expected.not_to contain_service('zabbix-proxy') }
        end

        # Make sure we have set some vars in zabbix_proxy.conf file. This is configuration file is the same on all
        # operating systems. So we aren't testing this for all opeating systems, just this one.
        context 'with zabbix_proxy.conf settings' do
          let(:params) do
            {
              allowroot: '0',
              cachesize: '8M',
              configfrequency: '3600',
              database_host: 'localhost',
              database_name: 'zabbix-proxy',
              database_password: 'zabbix-proxy',
              database_schema: 'zabbix-proxy',
              database_user: 'zabbix-proxy',
              database_tlsconnect: 'verify_ca',
              database_tlscafile: '/etc/zabbix/ssl/ca.cert',
              database_tlscertfile: '/etc/zabbix/ssl/cert.cert',
              database_tlskeyfile: '/etc/zabbix/ssl/key.key',
              database_tlscipher: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
              database_tlscipher13: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
              datasenderfrequency: '1',
              debuglevel: '4',
              externalscripts: '/usr/lib/zabbix/externalscripts',
              fping6location: '/usr/sbin/fping6',
              fpinglocation: '60',
              heartbeatfrequency: '60',
              historycachesize: '16M',
              historytextcachesize: '8M',
              hostname: 'rspec.puppet.com',
              housekeepingfrequency: '1',
              include_dir: '/etc/zabbix/zabbix_proxy.conf.d',
              javagateway: '192.168.1.2',
              javagatewayport: '10051',
              startjavapollers: '5',
              listenip: '192.168.1.1',
              listenport: '10051',
              loadmodulepath: '${libdir}/modules',
              loadmodule: 'pizza',
              localbuffer: '0',
              logfilesize: '15',
              logfile: '/var/log/zabbix/proxy_server.log',
              logtype: 'file',
              logslowqueries: '0',
              mode: '0',
              offlinebuffer: '1',
              pidfile: '/var/run/zabbix/proxy_server.pid',
              snmptrapper: '0',
              snmptrapperfile: '/tmp/zabbix_traps.tmp',
              sshkeylocation: '/home/zabbix/.ssh/',
              sslcertlocation_dir: '/usr/lib/zabbix/ssl/certs',
              sslkeylocation_dir: '/usr/lib/zabbix/ssl/keys',
              sslcalocation_dir: '/usr/lib/zabbix/ssl/certs',
              startdbsyncers: '4',
              startdiscoverers: '15',
              starthttppollers: '15',
              startipmipollers: '15',
              startpingers: '15',
              startpollers: '15',
              startpollersunreachable: '15',
              startpreprocessors: 10,
              starttrappers: '15',
              startvmwarecollectors: '0',
              timeout: '20',
              tmpdir: '/tmp',
              trappertimeout: '16',
              unavaliabledelay: '60',
              unreachabedelay: '15',
              unreachableperiod: '45',
              vmwarecachesize: '8M',
              vmwarefrequency: '60',
              zabbix_server_host: '192.168.1.1',
              zabbix_server_port: '10051',
              zabbix_version: '5.0',
              tlsciphercert: 'EECDH+aRSA+AES128:RSA+aRSA+AES128',
              tlsciphercert13: 'EECDH+aRSA+AES128:RSA+aRSA+AES128',
              tlscipherpsk: 'kECDHEPSK+AES128:kPSK+AES128',
              tlscipherpsk13: 'TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
              tlscipherall: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
              tlscipherall13: 'EECDH+aRSA+AES128:RSA+aRSA+AES128:kECDHEPSK+AES128:kPSK+AES128'
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ProxyMode=0$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^Server=192.168.1.1$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ServerPort=10051$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^Hostname=rspec.puppet.com$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ListenPort=10051$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LogFile=/var/log/zabbix/proxy_server.log$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LogFileSize=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LogType=file$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DebugLevel=4$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^PidFile=/var/run/zabbix/proxy_server.pid$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBHost=localhost$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBName=zabbix-proxy$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBSchema=zabbix-proxy$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBUser=zabbix-proxy$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBPassword=zabbix-proxy$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBTLSConnect=verify_ca} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBTLSCAFile=/etc/zabbix/ssl/ca.cert} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBTLSCertFile=/etc/zabbix/ssl/cert.cert} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBTLSKeyFile=/etc/zabbix/ssl/key.key} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBTLSCipher=TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DBTLSCipher13=TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ProxyLocalBuffer=0$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ProxyOfflineBuffer=1$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^HeartbeatFrequency=60$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ConfigFrequency=3600$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^DataSenderFrequency=1$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartPollers=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartIPMIPollers=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartPreprocessors=10$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartPollersUnreachable=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartTrappers=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartPingers=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartDiscoverers=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartHTTPPollers=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^JavaGateway=192.168.1.2$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^JavaGatewayPort=10051$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartJavaPollers=5$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartVMwareCollectors=0$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^VMwareFrequency=60$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^VMwareCacheSize=8M$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^SNMPTrapperFile=/tmp/zabbix_traps.tmp$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartSNMPTrapper=0$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ListenIP=192.168.1.1$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^HousekeepingFrequency=1$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^CacheSize=8M$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^StartDBSyncers=4$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^HistoryCacheSize=16M$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^Timeout=20$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TrapperTimeout=16$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^UnreachablePeriod=45$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^UnavailableDelay=60$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^UnreachableDelay=15$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^ExternalScripts=/usr/lib/zabbix/externalscripts$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^FpingLocation=60$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^Fping6Location=/usr/sbin/fping6$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^SSHKeyLocation=/home/zabbix/.ssh/$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LogSlowQueries=0$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TmpDir=/tmp$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^AllowRoot=0$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^Include=/etc/zabbix/zabbix_proxy.conf.d$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^SSLCertLocation=/usr/lib/zabbix/ssl/certs} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^SSLKeyLocation=/usr/lib/zabbix/ssl/keys} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^SSLCALocation=/usr/lib/zabbix/ssl/certs} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LoadModulePath=\$\{libdir\}/modules$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LoadModule=pizza$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCipherCert=EECDH\+aRSA\+AES128:RSA\+aRSA\+AES128$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCipherCert13=EECDH\+aRSA\+AES128:RSA\+aRSA\+AES128$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCipherPSK=kECDHEPSK\+AES128:kPSK\+AES128$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCipherPSK13=TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCipherAll=TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCipherAll13=EECDH\+aRSA\+AES128:RSA\+aRSA\+AES128:kECDHEPSK\+AES128:kPSK\+AES128$} }
        end

        context 'with zabbix_proxy.conf and version 4.0' do
          let :params do
            {
              tlsaccept: 'cert',
              tlscafile: '/etc/zabbix/keys/zabbix-server.ca',
              tlscrlfile: '/etc/zabbix/keys/zabbix-server.crl',
              tlscertfile: '/etc/zabbix/keys/zabbix-server.crt',
              tlskeyfile: '/etc/zabbix/keys/zabbix-server.key',
              tlsservercertissuer: 'Zabbix.Com',
              tlsservercertsubject: 'MyZabbix',
              tlspskidentity: '/etc/zabbix/keys/identity.file',
              tlspskfile: '/etc/zabbix/keys/file.key',
              zabbix_version: '4.0'
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSAccept=cert$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCAFile=/etc/zabbix/keys/zabbix-server.ca$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCRLFile=/etc/zabbix/keys/zabbix-server.crl$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSCertFile=/etc/zabbix/keys/zabbix-server.crt$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSKeyFile=/etc/zabbix/keys/zabbix-server.key$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSServerCertIssuer=Zabbix.Com$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSServerCertSubject=MyZabbix$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSPSKIdentity=/etc/zabbix/keys/identity.file$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^TLSPSKFile=/etc/zabbix/keys/file.key$} }
        end

        context 'with zabbix_proxy.conf and version 5.0' do
          let :params do
            {
              socketdir: '/var/run/zabbix',
              zabbix_version: '5.0'
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^SocketDir=/var/run/zabbix} }
        end

        context 'with zabbix_proxy.conf and logtype' do
          context 'declared as system' do
            let :params do
              {
                logtype: 'system'
              }
            end

            it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LogType=system$} }
            it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').without_content %r{^LogFile=} }
            it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').without_content %r{^LogFileSize=} }
          end

          context 'declared as console' do
            let :params do
              {
                logtype: 'console'
              }
            end

            it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^LogType=console$} }
            it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').without_content %r{^LogFile=} }
            it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').without_content %r{^LogFileSize=} }
          end
        end

        describe 'with zabbix_version 5.2 and Vault parameters defined' do
          let :params do
            {
              zabbix_version: '5.2',
              vaultdbpath: 'secret/zabbix/database',
              vaulttoken: 'FKTYPEGL156DK',
              vaulturl: 'https://127.0.0.1:8200',
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^VaultDBPath=secret/zabbix/database$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^VaultToken=FKTYPEGL156DK$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_proxy.conf').with_content %r{^VaultURL=https://127.0.0.1:8200$} }
        end
      end
    end
  end
end
