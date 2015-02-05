#
# Project
#

require 'metasploit/framework/command'
require 'metasploit/framework/command/base'

# Based on pattern used for lib/rails/commands in the railties gem.
class Metasploit::Framework::Command::Console < Metasploit::Framework::Command::Base
  extend ActiveSupport::Autoload

  autoload :Driver
  autoload :Spinner
  autoload :SupervisionGroup

  def start
    case parsed_options.options.subcommand
    when :version
      $stderr.puts "Framework Version: #{Metasploit::Framework::VERSION}"
    else
      # start Celluloid::SupervisionGroup
      supervision_group

      unless parsed_options.options.console.quiet
        supervision_group[:metasploit_framework_command_console_spinner].async.spin
      end

      supervision_group[:metasploit_framework_command_console_driver].run(driver_options)
    end
  end

  def supervision_group
    @supervision_group ||= Metasploit::Framework::Command::Console::SupervisionGroup.run!
  end

  private

  def driver_options
    unless @driver_options
      options = parsed_options.options

      driver_options = {}
      driver_options['Config'] = options.framework.config
      driver_options['ConfirmExit'] = options.console.confirm_exit
      driver_options['DatabaseEnv'] = options.environment
      driver_options['DatabaseMigrationPaths'] = options.database.migrations_paths
      driver_options['DatabaseYAML'] = options.database.config
      driver_options['DeferModuleLoads'] = options.modules.defer_loads
      driver_options['Defanged'] = options.console.defanged
      driver_options['DisableBanner'] = options.console.quiet
      driver_options['DisableDatabase'] = options.database.disable
      driver_options['LocalOutput'] = options.console.local_output
      driver_options['ModulePath'] = options.modules.path
      driver_options['Plugins'] = options.console.plugins
      driver_options['RealReadline'] = options.console.real_readline
      driver_options['Resource'] = options.console.resources
      driver_options['XCommands'] = options.console.commands

      @driver_options = driver_options
    end

    @driver_options
  end
end
