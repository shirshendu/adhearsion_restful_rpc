module AdhearsionRestfulRpc
  class Plugin < Adhearsion::Plugin
    # Actions to perform when the plugin is loaded
    #
    init :adhearsion_restful_rpc do
      logger.warn "AdhearsionRestfulRpc has been loaded"
    end

    # Basic configuration for the plugin
    #
    config :adhearsion_restful_rpc do
      greeting "Hello", :desc => "What to use to greet users"
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
