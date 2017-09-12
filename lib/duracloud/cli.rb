require 'optparse'
require 'active_model'

module Duracloud
  class CLI
    include ActiveModel::Model
    include Commands

    COMMANDS = Commands.public_instance_methods.map(&:to_s)

    USAGE = <<-EOS
Usage: duracloud [COMMAND] [options]

Commands:
    #{COMMANDS.sort.join("\n    ")}

Options:
EOS
    HELP = "Type 'duracloud -h/--help' for usage."

    attr_accessor :all_spaces,
                  :command,
                  :content_dir,
                  :content_id,
                  :content_type,
                  :fast,
                  :format,
                  :host,
                  :infile,
                  :logging,
                  :md5,
                  :missing,
                  :password,
                  :port,
                  :prefix,
                  :space_id,
                  :store_id,
                  :user,
                  :work_dir

    validates_presence_of :space_id, message: "-s/--space-id option is required.", unless: "command == 'get_storage_report'"
    validates_inclusion_of :command, in: COMMANDS, message: "Invalid command"

    def self.error!(exception)
      $stderr.puts exception.message
      if [ CommandError, OptionParser::ParseError ].include?(exception.class)
        $stderr.puts HELP
      end
      exit(false)
    end

    def self.call(*args)
      new(*args).execute
    rescue => e
      error!(e)
    end

    def initialize(*args)
      super CommandOptions.new(*args)
    end

    def execute
      if invalid?
        message = errors.map { |k, v| "ERROR: #{v}" }.join("\n")
        raise CommandError, message
      end
      configure_client
      send(command, self)
    end

    private

    def configure_client
      Client.configure do |config|
        config.user     = user     if user
        config.password = password if password
        config.host     = host     if host
        config.port     = port     if port

        config.silence_logging! unless logging
      end
    end

  end
end
