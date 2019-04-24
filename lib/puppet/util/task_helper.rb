require 'puppet'
require 'json'

# Sets up the transport for a remote task
class Puppet::Util::TaskHelper
  def initialize(transport_name)
    @transport_name = transport_name
    @transport = {}

    return unless params.key? '_installdir'
    add_plugin_paths(params['_installdir'])
  end

  def transport
    require 'puppet/resource_api/transport'

    @transport[@transport_name] ||= Puppet::ResourceApi::Transport.connect(@transport_name, credentials)
  end

  def params
    @params ||= JSON.parse(ENV['PARAMS'] || STDIN.read)
  end

  def target
    @target ||= params['_target']
  end

  def credentials
    @credentials ||= target.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
  end

  private

  # Syncs across anything from the module lib
  def add_plugin_paths(install_dir)
    Dir.glob(File.join([install_dir, '*'])).each do |mod|
      $LOAD_PATH << File.join([mod, 'lib'])
    end
  end
end
