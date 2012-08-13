module AdhearsionRestfulRpc
  module ControllerMethods
    # The methods are defined in a normal method the user will then mix in their CallControllers
    # The following also contains an example of configuration usage
    #
    def greet(name)
      play "#{Adhearsion.config[:adhearsion_restful_rpc].greeting}, #{name}"
    end
  end
end
