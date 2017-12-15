require 'puppet/util/network_device'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

class Puppet::Util::NetworkDevice::Transport::Cisco_ios < Puppet::Util::NetworkDevice::Transport::Base
  attr_reader :connection

  def initialize(url, _options = {})
    require 'uri'
    require 'net/ssh'

    # Lifted this code from Bolt
    options = {
        non_interactive: true,
        keepalive: true,
        verbose: :error
      }

    @url = URI.parse(url)
    options[:port] = @url.port if @url.port
    options[:password] = @url.password if @url.password

    Puppet.debug "Trying to connect to #{@url.host} as #{@url.user}"
    @session = Net::SSH.start(@url.host, @url.user, options)
  end

  def execute(command, **options)
       Puppet.debug "Executing: #{command}"

       output = ''
       exit_code = 0
       session_channel = @session.open_channel do |channel|
         # Request a pseudo tty
         channel.request_pty if @tty

         channel.exec(command) do |_, success|
           unless success
             raise Exception,
               "Could not execute command: #{command.inspect}",
               'EXEC_ERROR'
           end

           channel.on_data do |_, data|
             Puppet.debug "stdout: #{data}"
             output = data
           end

           channel.on_extended_data do |_, _, data|
             Puppet.debug "stderr: #{data}"
           end

           channel.on_request("exit-status") do |_, data|
             exit_code = data.read_long
           end

           if options[:stdin]
             channel.send_data(options[:stdin])
             channel.eof!
           end
         end
       end
       session_channel.wait

       if exit_code == 0
         Puppet.debug "Command returned successfully"
       else
         Puppet.error "Command failed with exit code #{exit_code}"
       end
       output
     end
end
