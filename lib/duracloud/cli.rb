require 'optparse'
require 'hashie'

module Duracloud
  class CLI < Hashie::Dash
    include Commands

    COMMANDS = Commands.public_instance_methods.map(&:to_s)

    USAGE = <<-EOS
Usage: duracloud [COMMAND] [options]

Commands:
    #{COMMANDS.sort.join("\n    ")}

Options:
EOS
    HELP = "Type 'duracloud -h/--help' for usage."

    property :all_spaces
    property :command, required: true
    property :content_dir
    property :content_id
    property :content_type
    property :fast
    property :format
    property :host
    property :infile
    property :logging
    property :md5
    property :missing
    property :password
    property :port
    property :prefix
    property :space_id, required: -> { command != "get_storage_report" }, message: "-s/--space-id option is required."
    property :store_id
    property :user
    property :work_dir

    def self.error!(exception)
      $stderr.puts exception.message
      if [ ArgumentError, CommandError, OptionParser::ParseError ].include?(exception.class)
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
      super CommandOptions.parse(*args)
    end

    def execute
      unless COMMANDS.include?(command)
        raise CommandError, "Invalid command: #{command.inspect}."
      end
      configure_client
      send(command, self)
    end

    private

    def configure_client
      Duracloud.user     = user     if user
      Duracloud.password = password if password
      Duracloud.host     = host     if host
      Duracloud.port     = port     if port

      Duracloud.silence_logging! unless logging
    end

  end
end
