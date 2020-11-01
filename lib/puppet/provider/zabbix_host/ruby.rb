require_relative '../zabbix'
Puppet::Type.type(:zabbix_host).provide(:ruby, parent: Puppet::Provider::Zabbix) do
  confine feature: :zabbixapi

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.instances
    proxies = zbx.proxies.all
    api_hosts = zbx.query(
      method: 'host.get',
      params: {
        selectParentTemplates: ['host'],
        selectInterfaces: %w[interfaceid type main ip port useip],
        selectGroups: ['name'],
        selectMacros: %w[macro value],
        output: %w[host proxy_hostid tls_accept tls_connect tls_issuer tls_subject tls_psk tls_psk_identity]
      }
    )

    api_hosts.map do |h|
      interface = h['interfaces'].select { |i| i['main'].to_i == 1 }.first
      use_ip = !interface['useip'].to_i.zero?
      new(
        ensure: :present,
        id: h['hostid'].to_i,
        name: h['host'],
        interfaceid: interface['interfaceid'].to_i,
        interfacetype: interface['type'].to_i,
        ipaddress: interface['ip'],
        use_ip: use_ip,
        port: interface['port'].to_i,
        groups: h['groups'].map { |g| g['name'] },
        group_create: nil,
        templates: h['parentTemplates'].map { |x| x['host'] },
        macros: h['macros'].map { |macro| { macro['macro'] => macro['value'] } },
        proxy: proxies.select { |_name, id| id == h['proxy_hostid'] }.keys.first,
        tls_accept: h['tls_accept'].to_i,
        tls_connect: h['tls_connect'].to_i,
        tls_issuer: h['tls_issuer'],
        tls_subject: h['tls_subject'],
        tls_psk: h['tls_psk'],
        tls_psk_identity: h['tls_psk_identity']
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def create
    template_ids = get_templateids(@resource[:templates])
    templates = transform_to_array_hash('templateid', template_ids)

    gids = get_groupids(@resource[:groups], @resource[:group_create])
    groups = transform_to_array_hash('groupid', gids)

    proxy_hostid = @resource[:proxy].nil? || @resource[:proxy].empty? ? nil : zbx.proxies.get_id(host: @resource[:proxy])
    interfacetype = @resource[:interfacetype].nil? ? 1 : @resource[:interfacetype]
    ipaddress = @resource[:ipaddress].nil? ? "" : @resource[:ipaddress]

    tls_accept = @resource[:tls_accept].nil? ? 1 : @resource[:tls_accept] 
    tls_connect = @resource[:tls_connect].nil? ? 1 : @resource[:tls_connect] 

    # Now we create the host
    zbx.hosts.create(
      host: @resource[:hostname],
      proxy_hostid: proxy_hostid,
      interfaces: [
        {
          type: interfacetype,
          main: 1,
          ip: ipaddress,
          dns: @resource[:hostname],
          port: @resource[:port],
          useip: @resource[:use_ip] ? 1 : 0
        }
      ],
      templates: templates,
      groups: groups,
      tls_connect: tls_connect,
      tls_accept: tls_accept,
      tls_issuer: @resource[:tls_issuer],
      tls_subject: @resource[:tls_subject],
      tls_psk_identity: @resource[:tls_psk_identity],
      tls_psk: @resource[:tls_psk]
    )
    @property_flush[:created] = true
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    zbx.hosts.delete(zbx.hosts.get_id(host: @resource[:hostname]))
    @property_flush[:destroyed] = true
  end

  #
  # Helper methods
  #
  def get_groupids(group_array, create)
    groupids = []
    group_array.each do |g|
      id = zbx.hostgroups.get_id(name: g)
      if id.nil?
        raise Puppet::Error, 'The hostgroup (' + g + ') does not exist in zabbix. Please use the correct one or set group_create => true.' unless create
        groupids << zbx.hostgroups.create(name: g)
      else
        groupids << id
      end
    end
    groupids
  end

  def get_templateids(template_array)
    templateids = []
    template_array.each do |t|
      template_id = zbx.templates.get_id(host: t)
      raise Puppet::Error, "The template #{t} does not exist in Zabbix. Please use a correct one." if template_id.nil?
      templateids << template_id
    end
    templateids
  end

  #
  # zabbix_host properties
  #
  mk_resource_methods

  def interfacetype=(int)
    zbx.query(
      method: 'hostinterface.update',
      params: {
        interfaceid: @property_hash[:interfaceid],
        type: int
      }
    )
  end

  def ipaddress=(string)
    zbx.query(
      method: 'hostinterface.update',
      params: {
        interfaceid: @property_hash[:interfaceid],
        ip: string
      }
    )
  end

  def use_ip=(boolean)
    zbx.query(
      method: 'hostinterface.update',
      params: {
        interfaceid: @property_hash[:interfaceid],
        useip: boolean ? 1 : 0,
        dns: @resource[:hostname]
      }
    )
  end

  def port=(int)
    zbx.query(
      method: 'hostinterface.update',
      params: {
        interfaceid: @property_hash[:interfaceid],
        port: int
      }
    )
  end

  def groups=(hostgroups)
    gids = get_groupids(hostgroups, @resource[:group_create])
    groups = transform_to_array_hash('groupid', gids)

    zbx.hosts.create_or_update(
      host: @resource[:hostname],
      groups: groups
    )
  end

  def templates()
    if @resource[:purge_templates] == true
      @property_hash[:templates]
    else
      @property_hash[:templates] & @resource[:templates]
    end
  end

  def templates=(array)
    should_template_ids = get_templateids(array)

    # Get templates we have to clear. Unlinking only isn't really helpful.
    is_template_ids = zbx.query(
      method: 'host.get',
      params: {
        hostids: @property_hash[:id],
        selectParentTemplates: ['templateid'],
        output: ['host']
      }
    ).first['parentTemplates'].map { |t| t['templateid'].to_i }
    if @resource[:purge_templates] == true
      templates_clear = is_template_ids - should_template_ids
      new_template_ids = should_template_ids
    else 
      templates_clear = Array.new
      new_template_ids = (is_template_ids + should_template_ids).uniq
    end

    zbx.query(
      method: 'host.update',
      params: {
        hostid: @property_hash[:id],
        templates: transform_to_array_hash('templateid', new_template_ids),
        templates_clear: transform_to_array_hash('templateid', templates_clear)
      }
    )
  end

  def macros=(array)
    macroarray = array.map { |macro| { 'macro' => macro.first[0], 'value' => macro.first[1] } }
    zbx.query(
      method: 'host.update',
      params: {
        hostid: @property_hash[:id],
        macros: macroarray
      }
    )
  end

  def proxy=(string)
    zbx.hosts.create_or_update(
      host: @resource[:hostname],
      proxy_hostid: zbx.proxies.get_id(host: string)
    )
  end

  def tls_connect=(int)
    @property_hash[:tls_connect]=int
  end

  def tls_accept=(int)
    @property_hash[:tls_accept]=int
  end

  def tls_issuer=(string)
    @property_hash[:tls_issuer]=string
  end

  def tls_subject=(string)
    @property_hash[:tls_subject]=string
  end

  def tls_psk_identity=(string)
    @property_hash[:tls_psk_identity]=string
  end

  def tls_psk=(string)
    @property_hash[:tls_psk]=string
  end

  def purge_templates()
    @resource[:purge_templates]
  end

  def flush
    update unless @property_flush[:created] || @property_flush[:destroyed]

    # Update @property_hash so that the output of puppet resource is correct
    if @property_flush[:destroyed]
      @property_hash.clear
      @property_hash[:ensure] = :absent
    end
  end

  def update
    tls_accept = @property_hash[:tls_accept].nil? ? 1 : @property_hash[:tls_accept] 
    tls_connect = @property_hash[:tls_connect].nil? ? 1 : @property_hash[:tls_connect] 

    zbx.hosts.update(
      host: @resource[:hostname],
      tls_accept: tls_accept,
      tls_connect: tls_connect,
      tls_psk: @property_hash[:tls_psk],
      tls_psk_identity: @property_hash[:tls_psk_identity],
      tls_subject: @property_hash[:tls_subject],
      tls_issuer: @property_hash[:tls_issuer],
     )
  end

end
