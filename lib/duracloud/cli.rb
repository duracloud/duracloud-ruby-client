require 'optparse'
require 'active_model'

module Duracloud
  class CLI
    include ActiveModel::Model

    COMMANDS = %w( sync validate manifest properties storage )

    USAGE = <<-EOS
Usage: duracloud [COMMAND] [options]

Commands:
    #{COMMANDS.sort.join("\n    ")}

Options:
EOS
    HELP = "Type 'duracloud -h/--help' for usage."

    attr_accessor :command, :user, :password, :host, :port,
                  :space_id, :store_id, :content_id,
                  :content_type, :md5,
                  :content_dir, :format, :infile, :work_dir, :fast,
                  :logging

    validates_presence_of :space_id, message: "-s/--space-id option is required.", unless: "command == 'storage'"
    validates_inclusion_of :command, in: COMMANDS

    def self.print_version
      puts "duracloud-client #{Duracloud::VERSION}"
    end

    def self.error!(exception)
      $stderr.puts exception.message
      if [ CommandError, OptionParser::ParseError ].include?(exception.class)
        $stderr.puts HELP
      end
      exit(false)
    end

    def self.call(*args)
      options = {}

      parser = OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on("-h", "--help",
                "Prints help") do
          print_version
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

        opts.on("-d", "--content-dir DIR",
                "Local content directory") do |v|
          options[:content_dir] = v
        end

        opts.on("-f", "--infile FILE",
                "Input file") do |v|
          options[:infile] = v
        end

        opts.on("-v", "--version",
                "Print version and exit") do |v|
          print_version
          exit
        end

        opts.on("-w", "--work-dir DIR",
                "Working directory") do |v|
          options[:work_dir] = v
        end

        opts.on("-F", "--[no-]fast",
                "Use fast audit for sync validation") do |v|
          options[:fast] = v
        end
      end

      command = args.shift if COMMANDS.include?(args.first)
      parser.parse!(args)

      cli = new(options.merge(command: command))
      if cli.invalid?
        message = cli.errors.map { |k, v| "ERROR: #{v}" }.join("\n")
        raise CommandError, message
      end
      cli.execute
    rescue => e
      error!(e)
    end

    def execute
      configure_client
      send(command).call(self)
    end

    protected

    def storage
      Commands::GetStorageReport
    end

    def sync
      Commands::Sync
    end

    def validate
      Commands::Validate
    end

    def manifest
      Commands::DownloadManifest
    end

    def properties
      Commands::GetProperties
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

Dir[File.expand_path("../commands/*.rb", __FILE__)].each { |m| require m }
