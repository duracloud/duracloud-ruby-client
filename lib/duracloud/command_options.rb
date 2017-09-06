require 'optparse'
require 'hashie'

module Duracloud
  class CommandOptions < Hashie::Mash

    def initialize(*args)
      super()
      self.command = args.shift if CLI::COMMANDS.include?(args.first)
      parser.parse!(args)
    end

    def print_version
      puts "duracloud-client #{Duracloud::VERSION}"
    end

    def parser
      OptionParser.new do |opts|
        opts.banner = CLI::USAGE

        opts.on("-h", "--help",
                "Prints help") do
          print_version
          puts opts
          exit
        end

        opts.on("-H", "--host HOST",
                "DuraCloud host") do |v|
          self.host = v
        end

        opts.on("-P", "--port PORT",
                "DuraCloud port") do |v|
          self.port = v
        end

        opts.on("-u", "--user USER",
                "DuraCloud user") do |v|
          self.user = v
        end

        opts.on("-p", "--password PASSWORD",
                "DuraCloud password") do |v|
          self.password = v
        end

        opts.on("-l", "--[no-]logging",
                "Enable/disable logging to STDERR") do |v|
          self.logging = v
        end

        opts.on("-s", "--space-id SPACE_ID",
                "DuraCloud space ID") do |v|
          self.space_id = v
        end

        opts.on("-i", "--store-id STORE_ID",
                "DuraCloud store ID") do |v|
          self.store_id = v
        end

        opts.on("-c", "--content-id CONTENT_ID",
                "DuraCloud content ID") do |v|
          self.content_id = v
        end

        opts.on("-m", "--md5 MD5",
                "MD5 digest of content to store or retrieve") do |v|
          self.md5 = v
        end

        opts.on("-b", "--bagit",
                "Get manifest in BAGIT format (default is TSV)") do
          self.format = Manifest::BAGIT_FORMAT
        end

        opts.on("-d", "--content-dir DIR",
                "Local content directory") do |v|
          self.content_dir = v
        end

        opts.on("-f", "--infile FILE",
                "Input file") do |v|
          self.infile = v
        end

        opts.on("-v", "--version",
                "Print version and exit") do |v|
          print_version
          exit
        end

        opts.on("-w", "--work-dir DIR",
                "Working directory") do |v|
          self.work_dir = v
        end

        opts.on("-F", "--[no-]fast-audit",
                "Use fast audit for sync validation") do |v|
          self.fast = v
        end

        opts.on("-a", "--prefix PREFIX",
                "Content prefix") do |v|
          self.prefix = v
        end

        opts.on("-M", "--[no-]missing", "Find missing items") do |v|
          self.missing = v
        end
      end
    end

  end
end
