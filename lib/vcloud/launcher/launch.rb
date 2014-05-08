module Vcloud
  module Launcher
    class Launch

      def initialize
        @config_loader = Vcloud::Core::ConfigLoader.new
      end

      def run(config_file = nil, cli_options = {})
        set_logging_level(cli_options)
        config = @config_loader.load_config(config_file, config_schema)
        config[:vapps].each do |vapp_config|
          Vcloud::Core.logger.info("\n")
          Vcloud::Core.logger.info("Provisioning vApp #{vapp_config[:name]}.")
          begin
            vapp = ::Vcloud::Launcher::VappOrchestrator.provision(vapp_config)
            #methadone sends option starting with 'no' as false.
            vapp.power_on unless cli_options["dont-power-on"]
            Vcloud::Core.logger.info("Done! Provisioned vApp #{vapp_config[:name]} successfully.")
            Vcloud::Core.logger.info("=" * 70)
          rescue RuntimeError => e
            Vcloud::Core.logger.error("Failure : Could not provision vApp: #{e.message}")
            Vcloud::Core.logger.info("=" * 70)
            break unless cli_options["continue-on-error"]
          end

        end
      end

      def config_schema
        {
          type: 'hash',
          allowed_empty: false,
          permit_unknown_parameters: true,
          internals: {
            vapps: {
            type: 'array',
            required: false,
            allowed_empty: true,
            each_element_is: ::Vcloud::Launcher::VappOrchestrator.provision_schema
          },
        }
      }
      end

      def set_logging_level(cli_options)
        if cli_options[:verbose]
          Vcloud::Core.logger.level = Logger::DEBUG
        elsif cli_options[:quiet]
          Vcloud::Core.logger.level = Logger::ERROR
        end
      end

    end
  end
end
