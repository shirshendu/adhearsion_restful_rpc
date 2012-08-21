module AdhearsionRestfulRpc
  class Plugin < Adhearsion::Plugin

    # Regex for IP address
    VALID_IP_ADDRESS = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|\*)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|\*)$/
    
    # Basic configuration for the plugin
    #
    config :adhearsion_restful_rpc do
      path_nesting "/", :desc => "Specify an arbitrarily nested path. Could be used for additional security or in HTTP reverse proxy server."
      port "5001", :desc => "Port to run the webserver on"
      handler "WEBrick", :desc => "Can be any valid Rack::Handler constant name. Other options: WEBrick, EventedMongrel. If you don't know the differences between these, 'Mongrel' is definitely a good choice."
      show_exceptions true, :desc => "In a production system, you should make this 'false' since it could expose code structure and vulnerabilities."
      authentication false, :desc => "Authentication to the API. Add config.authentication[:<username>] = 'password' to add each user"
      desc "Type of access"
      access {
        everyone false, :desc => "True value will ignore whitelist and blacklist data, and allow access to everyone"
        whitelist ["127.0.0.1","61.16.182.2","192.168.173.186"], :desc => "Array of whitelisted IPs - Takes precedence if both white and black lists are supplied."
        blacklist ["21.21.12.12"], :desc => "Array of blacklisted IPs"
      }
    end

    class << self
      def ip_allowed?(ip)
        raise ArgumentError, "#{ip.inspect} is not a valid IP address!" unless ip.kind_of?(String) && ip =~ VALID_IP_ADDRESS

        octets = ip.split "."

        access = Adhearsion.config.adhearsion_restful_rpc.access
        if access.everyone
          true
        elsif access.whitelist
          whitelist = access.whitelist
          !! whitelist.find do |pattern|
            pattern_octets = pattern.split "."
            # Traverse both arrays in parallel
            octets.zip(pattern_octets).map do |octet, octet_pattern|
              octet_pattern == "*" ? true : (octet == octet_pattern)
            end == [true, true, true, true]
          end
        elsif access.blacklist
          blacklist = access.blacklist
          ! blacklist.find do |pattern|
            pattern_octets = pattern.split "."
            # Traverse both arrays in parallel
            octets.zip(pattern_octets).map do |octet, octet_pattern|
              octet_pattern == "*" ? true : (octet == octet_pattern)
            end == [true, true, true, true]
          end
        else
          raise Adhearsion::Components::ConfigurationError, 'Unrecognized "access" configuration value!'
        end
      end
    end

    RESTFUL_API_HANDLER = lambda do |env|
      unless ip_allowed? env["REMOTE_ADDR"]
        return [403, {"Content-Type" => "application/json"}, [{:error => "Forbidden by access control configuration"}.to_json]]
      end
      json = env["rack.input"].read

      # Return "Bad Request" HTTP error if the client forgot
      return [400, {"Content-Type" => "application/json"}, [{:error => "You must POST a valid JSON object!"}.to_json]] if json.blank?

      #      json = JSON.parse json

      nesting = Adhearsion.config.adhearsion_restful_rpc.path_nesting 
      path = env["PATH_INFO"]

      return [404, {"Content-Type" => "application/json"}, [{:error => "This resource does not respond to #{path.inspect}"}.to_json]] unless path[0...nesting.size] == nesting

      path = path[nesting.size..-1]

      resources = path.split("/")
      #      fr = Adhearsion
      namespaces = ["Adhearsion"]
      methods = []
      final_resource = ""
      resources.each do |resource|
        # First narrow down on namespace. Once narrower namespaces cannot be found,
        # all that remains would be a method call chain.
        begin
          (eval namespaces.join("::")).const_get resource
          namespaces.push resource
        rescue NameError
          # Try finding a method of this resource in the namespace build uptil now:
          namespace = eval namespaces.join("::")
          if (eval [namespaces.join("::"),*methods].join(".")).respond_to? resource
            methods.push resource
          else
            return [404, {"Content-Type"=>"application/json"}, [{:error => "Resource #{resource} not found"}.to_json]]
          end
        end
      end

      # TODO: set the content-type and other HTTP headers
      response = eval [namespaces.join("::"),*methods].join(".") + json
      [200, {"Content-Type" => "application/json"}, [response.inspect.to_json]]
    end

    init do
      begin
        require 'rack'
        require 'json'
      rescue LoadError
        abort "ERROR: restful_rpc requires the 'rack' and 'json' gems"
      end
      logger.warn "AdhearsionRestfulRpc has been loaded"
      config = Adhearsion.config.adhearsion_restful_rpc
      api = RESTFUL_API_HANDLER
      port            = config["port"] || 5000
      authentication  = config["authentication"]
      show_exceptions = config["show_exceptions"]
      handler         = Rack::Handler.const_get(config["handler"] || "Mongrel")

      if authentication
        api = Rack::Auth::Basic.new(api) do |username, password|
          authentication[username] == password
        end
        api.realm = "Adhearsion API"
      end

      if show_exceptions
        api = Rack::ShowStatus.new(Rack::ShowExceptions.new(api))
      end

      Thread.new do
        handler.run api, :Port => port
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
