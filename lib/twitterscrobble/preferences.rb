require 'yaml'
require 'optparse'
require 'logger'
require 'active_support'

module Twitterscrobble
  
  class SimpleLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_s(:db)} #{severity} #{msg}\n" 
    end 
  end 
  
  class Preferences
      PREFERENCES_FILE_NAME = "preferences.yaml"
      APP_NAME = "twitterscrobble"
      TO_BE_SAVED = [:history, :twitter_user, :scrobbler_user, :twitter_password]
  
      attr_reader :logger
  
      def initialize
          parsed_args = parse_args
  
          begin
              if !parsed_args[:stateless]
                  @cfg = YAML.load(File.open(full_prefs_file_path))
              else
                  @cfg = {}
              end
          rescue
              @cfg = {}
          end
  
          @cfg.merge!(parsed_args) # args override cfg
  
          if @cfg[:logfile]
              @logger = SimpleLogger.new(@cfg[:logfile])
          else
              @logger = SimpleLogger.new(STDOUT)
          end
  
          if @cfg[:loglevel]
              @logger.level = @cfg[:loglevel]
          else
              @logger.level = Logger::WARN
          end
  
          @logger.debug("Command line preferences: #{parsed_args.reject{|k,v| k == :twitter_password}.inspect}")
          @logger.debug("Effective preferences after merging in preferences file #{full_prefs_file_path}:")
          @logger.debug(@cfg.reject{|k,v| k == :twitter_password}.inspect)
  
          if 0 < check_required_args.size
              msg = ""
              msg << "Required argument#{'s' if 1 < check_required_args.size} #{check_required_args.join(', ')} "
              msg << "not found in preferences or command line parameters."
              raise msg
          end
      end
  
      def save
          unless @cfg[:no_save]
              Dir.mkdir(preferences_dir) if !File.exist?(preferences_dir)
              
              File.open(full_prefs_file_path, 'w') do |out|
                  save_cfg = @cfg.reject{|k, v| !TO_BE_SAVED.include?(k)}
                  @logger.debug("Writing preferences: #{save_cfg.reject{|k,v| k == :twitter_password}.inspect}")  
                  YAML.dump(save_cfg, out)
              end
              
              File.new(full_prefs_file_path).chmod(0600)
          end
      end
  
      # delegates reading of attributes to @cfg
      def method_missing(methodname, *args)
          @cfg[methodname]
      end
  
      def history=(history_stamp)
          @cfg[:history] = history_stamp
      end
  
  private
      def check_required_args
          missing = []
          
          if @cfg[:twitter_user].blank?
              missing << "twitter-user"
          end
  
          if @cfg[:twitter_password].blank?
              missing << "twitter-password"
          end
  
          if @cfg[:scrobbler_user].blank?
              missing << "scrobbler-user"
          end
          missing
      end
  
  
      # some code taken from http://redshift.sourceforge.net/preferences/doc/classes/Preferences.src/M000002.html
      # which is under the Ruby license (which is MIT compatible, I believe)
      def preferences_dir
      	dir = nil
        app_name = APP_NAME
        
        case RUBY_PLATFORM
        when /win32/
      		dir =
      			ENV['APPDATA'] ||	# C:\Documents and Settings\name\Application Data
      			ENV['USERPROFILE'] || # C:\Documents and Settings\name
      			ENV['HOME']
      	else
      		dir = ENV['HOME'] || File.expand_path('~')
          app_name = "." << APP_NAME
      	end
  
      	unless dir
      		raise EnvError, "Can't determine a preferences directory."
      	end
  
      	File.join(dir, app_name)
      end
  
      def parse_args
          options = {}
  
          op = OptionParser.new do |opts|
  
              #
              # general flags
              #
  
              opts.on("-h", "--help", "Prints this help text and exits") do |v|
                  puts op.to_s
                  exit
              end
  
              opts.on("-v", "--version", "Prints the version of this script and exits") do |v|
                  puts "#{Twitterscrobble.name}, v.#{VERSION::STRING}"
                  exit
              end
  
              opts.on("-q", "--quiet", "Don't write anything to stdout") do |v|
                  options[:quiet] = true
              end
  
              opts.on("-f <logfile>", "--logfile <logfile>", "Specify the name of the log file") do |v|
                  options[:logfile] = v
              end
  
              level_map = {:debug => Logger::DEBUG, :info => Logger::INFO, :warn => Logger::WARN, :error => Logger::ERROR, :fatal => Logger::FATAL}
              opts.on("-l LEVEL", "--loglevel LEVEL", level_map, "Specify the log level (#{level_map.keys.join(', ')})") do |t|
                  options[:loglevel] = t
              end
  
              #
              # user data
              #
  
              opts.on("--scrobbler-user MANDATORY", "Username for which recent tracks are pulled off last.fm") do |v|
                  options[:scrobbler_user] = v
              end
  
              opts.on("--twitter-user MANDATORY", "Twitter user the recent tracks are posted to") do |v|
                  options[:twitter_user] = v
              end
  
              opts.on("--twitter-password MANDATORY", "Twitter password") do |v|
                  options[:twitter_password] = v
              end
  
              #
              # behavioral flags
              #
  
              opts.on("-n", "--no-post", "Do not post status line to Twitter, instead write it to stdout.") do |v|
                  options[:no_post] = true
              end
  
              opts.on("-HMANDATORY", "--history MANDATORY", "assume the supplied history value") do |v|
                  options[:history] = v
              end
  
              opts.on("-mMANDATORY", "--max MANDATORY", "post only the <max> most recent songs") do |v|
                  options[:max] = v.to_i
              end
  
              opts.on("-s", "--stateless", "Do not read and write preferences file, implies --no-save") do |v|
                  options[:stateless] = true
                  options[:no_save] = true
              end
  
              opts.on("--no-save", "do not write preferences file") do |v|
                  options[:no_save] = true
              end
          end
          op.parse!
  
          options
      end
      
      def full_prefs_file_path
        File.join(preferences_dir, PREFERENCES_FILE_NAME)
      end
  end  
end