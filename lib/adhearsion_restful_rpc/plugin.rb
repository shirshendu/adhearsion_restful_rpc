module AdhearsionRestfulRpc
  class Plugin < Adhearsion::Plugin
    # Actions to perform when the plugin is loaded
    #
    init :adhearsion_restful_rpc do
      begin
        require 'rack'
        require 'json'
      rescue LoadError
        abort "ERROR: restful_rpc requires the 'rack' and 'json' gems"
      end
      logger.warn "AdhearsionRestfulRpc has been loaded"
    end

    # Basic configuration for the plugin
    #
    config :adhearsion_restful_rpc do
      path_nesting "/", :desc => "Specify an arbitrarily nested path. Could be used for additional security or in HTTP reverse proxy server."
      port "5000", :desc => "Port to run the webserver on"
      handler "WEBrick", :desc => "Can be any valid Rack::Handler constant name. Other options: WEBrick, EventedMongrel. If you don't know the differences between these, 'Mongrel' is definitely a good choice."
      show_exceptions true, :desc => "In a production system, you should make this 'false' since it could expose code structure and vulnerabilities."
      authentication false, :desc => "Authentication to the API. Add config.authentication[<username>] = 'password' to add each user"
      if authentication 
        authentication.each do |user, password|
          user "#{password}", :desc => "Auth"
        end
      end
      access "everyone", :desc => "Type of access: everyone: No IPs are blocked, whitelist: whitelist data will be used, blacklist: blacklist data will be used."
      if access == "whitelist"
        whitelist.each do |ip|
          STDOUT.puts "Allowing from IP #{ip}"
        end
      elsif access == "blacklist"
        blacklist.each do |ip|
          STDOUT.puts "Disallowing from IP #{ip}"
        end
      else
        STDOUT.puts "Allowing from all IPs"
      end
    end

    # Defining a Rake task is easy
    # The following can be invoked with:
    #   rake plugin_demo:info
    #
    tasks do
      namespace :adhearsion_restful_rpc do
        desc "Prints the PluginTemplate information"
        task :info do
          STDOUT.puts "AdhearsionRestfulRpc plugin v. #{VERSION}"
        end
      end
    end

  end
end
