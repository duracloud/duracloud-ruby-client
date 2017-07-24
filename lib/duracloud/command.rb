require 'optparse'
require 'active_model'

module Duracloud
  class Command
    include ActiveModel::Model
    include Commands

    COMMANDS = Commands.public_instance_methods.map(&:to_s)
    USAGE = "Usage: duracloud [#{COMMANDS.join('|')}] [options]"
    HELP = "Type 'duracloud --help' for usage."

    attr_accessor :command, :user, :password, :host, :port,
                  :space_id, :store_id, :content_id,
                  :content_type, :md5,
                  :content_dir, :format, :infile
                  :logging

    def self.error!(reason)
      STDERR.puts reason
      STDERR.puts HELP
      exit(false)
    end

    def self.call(*args)
      options = {}

      parser = OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on("-h", "--help",
                "Prints help") do
          puts opts
          exit
        end

        opts.on("-H", "--host HOST",
                "DuraCloud host") do |v|
          options[:host] = v
        end

        opts.on("-P", "--port PORT",
                "DuraCloud port") do |v|
          options[:port] = v
        end

        opts.on("-u", "--user USER",
                "DuraCloud user") do |v|
          options[:user] = v
        end

        opts.on("-p", "--password PASSWORD",
                "DuraCloud password") do |v|
          options[:password] = v
        end

        opts.on("-l", "--[no-]logging",
                "Enable/disable logging to STDERR") do |v|
          options[:logging] = v
        end

        opts.on("-s", "--space-id SPACE_ID",
                "DuraCloud space ID") do |v|
          options[:space_id] = v
        end

        opts.on("-i", "--store-id STORE_ID",
                "DuraCloud store ID") do |v|
          options[:store_id] = v
        end

        opts.on("-c", "--content-id CONTENT_ID",
                "DuraCloud content ID") do |v|
          options[:content_id] = v
        end

        opts.on("-m", "--md5 MD5",
                "MD5 digest of content to store or retrieve") do |v|
          options[:md5] = v
        end

        opts.on("-b", "--bagit",
                "Get manifest in BAGIT format (default is TSV)") do
          options[:format] = Manifest::BAGIT_FORMAT
        end

        opts.on("-d", "--content-dir CONTENT_DIR",
                "Local content directory") do |v|
          options[:content_dir] = v
        end

        opts.on("-f", "--infile FILE",
                "Input file") do |v|
          options[:infile] = v
        end
      end

      command = args.shift if COMMANDS.include?(args.first)
      parser.parse!(args)

      new(options).execute(command)
    rescue CommandError, OptionParser::ParseError => e
      error!(e.message)
    end

    def execute(command)
      unless COMMANDS.include?(command)
        raise CommandError, "Invalid command: #{command}."
      end
      begin
        configure_client
        send(command)
      rescue Error => e
        STDERR.puts e.message
        exit(false)
      end
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
