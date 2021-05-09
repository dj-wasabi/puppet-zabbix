require 'spec_helper'
require 'deep_merge'

describe 'zabbix::server' do
  let :node do
    'rspec.puppet.com'
  end

  on_supported_os.each do |os, facts|
    next if facts[:osfamily] == 'Archlinux' # zabbix server is currently not supported on archlinux
    next if facts[:os]['name'] == 'windows'
    context "on #{os} " do
      systemd_fact = case facts[:osfamily]
                     when 'Archlinux', 'Fedora', 'Gentoo'
                       { systemd: true }
                     else
                       { systemd: false }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end

      zabbix_version = '5.0'

      describe 'with default settings' do
        it { is_expected.to contain_class('zabbix::repo') }
        it { is_expected.to contain_class('zabbix::params') }
        it { is_expected.to contain_service('zabbix-server').with_ensure('running') }
        it { is_expected.to contain_zabbix__startup('zabbix-server') }
      end

      if facts[:osfamily] == 'RedHat'
        describe 'with enabled selinux' do
          let :params do
            {
              manage_selinux: true
            }
          end

          let :facts do
            facts.deep_merge(os: { selinux: { enabled: true } })
          end

          it { is_expected.to contain_selboolean('zabbix_can_network').with('value' => 'on', 'persistent' => true) }
        end

        describe 'with defaults' do
          it { is_expected.to contain_yumrepo('zabbix-nonsupported') }
          it { is_expected.to contain_yumrepo('zabbix') }
        end
      end

      describe 'with disabled selinux' do
        let :params do
          {
            manage_selinux: false
          }
        end

        it { is_expected.not_to contain_selboolean('zabbix_can_network').with('value' => 'on', 'persistent' => true) }
      end

      describe 'with database_type as postgresql' do
        let :params do
          {
            database_type: 'postgresql',
            server_configfile_path: '/etc/zabbix/zabbix_server.conf',
            include_dir: '/etc/zabbix/zabbix_server.conf.d'
          }
        end

        it { is_expected.to contain_package('zabbix-server-pgsql').with_ensure('present') }
        it { is_expected.to contain_package('zabbix-server-pgsql').with_name('zabbix-server-pgsql') }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_require('Package[zabbix-server-pgsql]') }
      end

      describe 'with database_type as mysql' do
        let :params do
          {
            database_type: 'mysql'
          }
        end

        it { is_expected.to contain_package('zabbix-server-mysql').with_ensure('present') }
        it { is_expected.to contain_package('zabbix-server-mysql').with_name('zabbix-server-mysql') }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_require('Package[zabbix-server-mysql]') }
      end

      # Include directory should be available.
      it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf.d').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf.d').with_require('File[/etc/zabbix/zabbix_server.conf]') }

      context 'with zabbix::database::postgresql class' do
        let :params do
          {
            database_type: 'postgresql',
            database_user: 'zabbix-server',
            database_password: 'zabbix-server',
            database_host: 'localhost',
            database_name: 'zabbix-server'
          }
        end

        it { is_expected.to contain_class('zabbix::database::postgresql').with_zabbix_type('server') }
        it { is_expected.to contain_class('zabbix::database::postgresql').with_zabbix_version(zabbix_version) }
        it { is_expected.to contain_class('zabbix::database::postgresql').with_database_name('zabbix-server') }
        it { is_expected.to contain_class('zabbix::database::postgresql').with_database_user('zabbix-server') }
        it { is_expected.to contain_class('zabbix::database::postgresql').with_database_password('zabbix-server') }
        it { is_expected.to contain_class('zabbix::database::postgresql').with_database_host('localhost') }
      end

      context 'with zabbix::database::mysql class' do
        let :params do
          {
            database_type: 'mysql',
            database_user: 'zabbix-server',
            database_password: 'zabbix-server',
            database_host: 'localhost',
            database_name: 'zabbix-server'
          }
        end

        it { is_expected.to contain_class('zabbix::database::mysql').with_zabbix_type('server') }
        it { is_expected.to contain_class('zabbix::database::mysql').with_zabbix_version(zabbix_version) }
        it { is_expected.to contain_class('zabbix::database::mysql').with_database_name('zabbix-server') }
        it { is_expected.to contain_class('zabbix::database::mysql').with_database_user('zabbix-server') }
        it { is_expected.to contain_class('zabbix::database::mysql').with_database_password('zabbix-server') }
        it { is_expected.to contain_class('zabbix::database::mysql').with_database_host('localhost') }
      end

      # So if manage_firewall is set to true, it should install
      # the firewall rule.
      context 'when declaring manage_firewall is true' do
        let :params do
          {
            manage_firewall: true
          }
        end

        it { is_expected.to contain_firewall('151 zabbix-server') }
      end

      context 'when declaring manage_firewall is false' do
        let :params do
          {
            manage_firewall: false
          }
        end

        it { is_expected.not_to contain_firewall('151 zabbix-server') }
      end

      context 'it creates a startup script' do
        case facts[:osfamily]
        when 'Archlinux', 'Fedora', 'Gentoo'
          it { is_expected.to contain_file('/etc/init.d/zabbix-server').with_ensure('absent') }
          it { is_expected.to contain_file('/etc/systemd/system/zabbix-server.service').with_ensure('file') }
        else
          it { is_expected.to contain_file('/etc/init.d/zabbix-server').with_ensure('file') }
          it { is_expected.not_to contain_file('/etc/systemd/system/zabbix-server.service') }
        end
      end

      context 'when declaring manage_startup_script is false' do
        let :params do
          {
            manage_startup_script: false
          }
        end

        it { is_expected.not_to contain_zabbix__startup('zabbix-server') }
      end

      # If manage_service is true (default), it should create a service
      # and ensure that it is running.
      context 'when declaring manage_service is true' do
        let :params do
          {
            manage_service: true
          }
        end

        it { is_expected.to contain_service('zabbix-server').with_ensure('running') }
      end

      # When the manage_service is false, it may not make the service.
      context 'when declaring manage_service is false' do
        let :params do
          {
            manage_service: false
          }
        end

        it { is_expected.not_to contain_service('zabbix-server') }
      end

      context 'with all zabbix_server.conf-related parameters' do
        let :params do
          {
            alertscriptspath: '${datadir}/zabbix/alertscripts',
            allowroot: '1',
            cachesize: '8M',
            cacheupdatefrequency: '30',
            database_host: 'localhost',
            database_name: 'zabbix-server',
            database_password: 'zabbix-server',
            database_port: 3306,
            database_schema: 'zabbix-server',
            database_socket: '/tmp/socket.db',
            database_user: 'zabbix-server',
            database_tlsconnect: 'verify_ca',
            database_tlscafile: '/etc/zabbix/ssl/ca.cert',
            database_tlscertfile: '/etc/zabbix/ssl/cert.cert',
            database_tlskeyfile: '/etc/zabbix/ssl/key.key',
            database_tlscipher: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
            database_tlscipher13: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
            debuglevel: '3',
            externalscripts: '/usr/lib/zabbix/externalscripts0',
            fping6location: '/usr/sbin/fping6',
            fpinglocation: '/usr/sbin/fping',
            historycachesize: '4M',
            housekeepingfrequency: '1',
            include_dir: '/etc/zabbix/zabbix_server.conf.d',
            javagateway: '192.168.2.2',
            javagatewayport: '10052',
            listenip: '192.168.1.1',
            listenport: '10051',
            loadmodulepath: '${libdir}/modules',
            loadmodule: 'pizza',
            logfilesize: '10',
            logfile: '/var/log/zabbix/zabbix_server.log',
            logtype: 'file',
            logslowqueries: '0',
            maxhousekeeperdelete: '500',
            pidfile: '/var/run/zabbix/zabbix_server.pid',
            proxyconfigfrequency: '3600',
            proxydatafrequency: '1',
            snmptrapperfile: '/tmp/zabbix_traps.tmp',
            sourceip: '192.168.1.1',
            sshkeylocation: '/home/zabbix',
            startdbsyncers: '4',
            startalerters: 10,
            startdiscoverers: '1',
            startescalators: 10,
            starthttppollers: '1',
            startipmipollers: '12',
            startpingers: '1',
            startpollers: '12',
            startpollersunreachable: '1',
            startpreprocessors: 10,
            startproxypollers: '1',
            startsnmptrapper: '1',
            starttimers: '1',
            starttrappers: '5',
            startlldprocessors: 5,
            startvmwarecollectors: '5',
            timeout: '3',
            tmpdir: '/tmp',
            trappertimeout: '30',
            trendcachesize: '4M',
            unavailabledelay: '30',
            unreachabledelay: '30',
            unreachableperiod: '30',
            valuecachesize: '4M',
            vmwarecachesize: '8M',
            vmwarefrequency: '60',
            zabbix_version: '5.0',
            tlsciphercert: 'EECDH+aRSA+AES128:RSA+aRSA+AES128',
            tlsciphercert13: 'EECDH+aRSA+AES128:RSA+aRSA+AES128',
            tlscipherpsk: 'kECDHEPSK+AES128:kPSK+AES128',
            tlscipherpsk13: 'TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
            tlscipherall: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
            tlscipherall13: 'EECDH+aRSA+AES128:RSA+aRSA+AES128:kECDHEPSK+AES128:kPSK+AES128'
          }
        end

        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^AlertScriptsPath=\$\{datadir\}/zabbix/alertscripts} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^AllowRoot=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^CacheSize=8M} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^CacheUpdateFrequency=30} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBHost=localhost} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBName=zabbix-server} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBPassword=zabbix-server} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBPort=3306} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBSchema=zabbix-server} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBSocket=/tmp/socket.db} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBTLSConnect=verify_ca} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBTLSCAFile=/etc/zabbix/ssl/ca.cert} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBTLSCertFile=/etc/zabbix/ssl/cert.cert} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBTLSKeyFile=/etc/zabbix/ssl/key.key} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBTLSCipher=TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBTLSCipher13=TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DBUser=zabbix-server} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^DebugLevel=3} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^ExternalScripts=/usr/lib/zabbix/externalscripts} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^Fping6Location=/usr/sbin/fping6} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^FpingLocation=/usr/sbin/fping} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^HistoryCacheSize=4M} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^HousekeepingFrequency=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^Include=/etc/zabbix/zabbix_server.conf.d} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^JavaGateway=192.168.2.2} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^JavaGatewayPort=10052} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^ListenIP=192.168.1.1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^ListenPort=10051$} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LoadModulePath=\$\{libdir\}/modules} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LoadModule = pizza} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LogFileSize=10} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LogFile=/var/log/zabbix/zabbix_server.log} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LogType=file} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LogSlowQueries=0} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^MaxHousekeeperDelete=500} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^PidFile=/var/run/zabbix/zabbix_server.pid} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^ProxyConfigFrequency=3600} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^ProxyDataFrequency=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartLLDProcessors=5} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^SNMPTrapperFile=/tmp/zabbix_traps.tmp} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^SourceIP=192.168.1.1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^SSHKeyLocation=/home/zabbix} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartDBSyncers=4} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartAlerters=10} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartDiscoverers=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartEscalators=10} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartHTTPPollers=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartIPMIPollers=12} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartPingers=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartPollers=12} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartPollersUnreachable=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartPreprocessors=10} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartProxyPollers=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartSNMPTrapper=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartTimers=1} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartTrappers=5} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^StartVMwareCollectors=5} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^Timeout=3} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TmpDir=/tmp} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TrapperTimeout=30} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TrendCacheSize=4M} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^UnavailableDelay=30} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^UnreachableDelay=30} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^UnreachablePeriod=30} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^ValueCacheSize=4M} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^VMwareCacheSize=8M} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^VMwareFrequency=60} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TLSCipherCert=EECDH\+aRSA\+AES128:RSA\+aRSA\+AES128$} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TLSCipherCert13=EECDH\+aRSA\+AES128:RSA\+aRSA\+AES128$} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TLSCipherPSK=kECDHEPSK\+AES128:kPSK\+AES128$} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TLSCipherPSK13=TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256$} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TLSCipherAll=TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256$} }
        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^TLSCipherAll13=EECDH\+aRSA\+AES128:RSA\+aRSA\+AES128:kECDHEPSK\+AES128:kPSK\+AES128$} }
      end

      context 'with zabbix_server.conf and version 5.0' do
        let :params do
          {
            socketdir: '/var/run/zabbix',
            zabbix_version: '5.0'
          }
        end

        it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^SocketDir=/var/run/zabbix} }
      end

      context 'with zabbix_server.conf and logtype' do
        context 'declared as system' do
          let :params do
            {
              logtype: 'system'
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LogType=system$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').without_content %r{^LogFile=} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').without_content %r{^LogFileSize=} }
        end

        context 'declared as console' do
          let :params do
            {
              logtype: 'console'
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^LogType=console$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').without_content %r{^LogFile=} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').without_content %r{^LogFileSize=} }
        end
      end

      # Zabbix Server 5.2 is not supported on RedHat family
      if facts[:osfamily] != 'RedHat'
        describe 'with zabbix_version 5.2 and Vault parameters defined' do
          let :params do
            {
              zabbix_version: '5.2',
              vaultdbpath: 'secret/zabbix/database',
              vaulttoken: 'FKTYPEGL156DK',
              vaulturl: 'https://127.0.0.1:8200',
            }
          end

          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^VaultDBPath=secret/zabbix/database$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^VaultToken=FKTYPEGL156DK$} }
          it { is_expected.to contain_file('/etc/zabbix/zabbix_server.conf').with_content %r{^VaultURL=https://127.0.0.1:8200$} }
        end
      end
    end
  end
end
