require 'optparse'
require 'etc'
require 'warthog'
require 'warthog/cli/action'
require 'warthog/a10/rest'
require 'warthog/version'
require 'warthog/about'

include Warthog::CLI::Action

module Warthog; module CLI

  class CLI

    COMMANDS = %w(show)

    def initialize(arguments)
      @arguments = arguments
      @whoami = File.basename($PROGRAM_NAME).to_sym

      @options = { :debug => false, :username => Etc.getlogin }
      @action = nil
      @elesai = nil
    end

    def run
      begin
        parsed_options?
        arguments_valid?
        options_valid?
        process_options
        process_arguments
        process_command

      rescue => e #ArgumentError, OptionParser::MissingArgument, Senedsa::SendNsca::ConfigurationError => e
        if @options[:debug]
          output_message "#{e.class}: #{e.message}\n  #{e.backtrace.join("\n  ")}",1
        else
          output_message e.message,1
        end
      end
    end

    protected

    def parsed_options?
      opts = OptionParser.new

      opts.banner = "Usage: #{ID} [options] <action> [options] [arguments]"
      opts.separator ""
      opts.separator "Actions: (<action> -h displays help for specific action)"
      opts.separator "    show                             Displays component information"
      opts.separator ""
      opts.separator "General options:"
      opts.on('-H', '--hostname HOSTNAME',              String,              "A10 Load Balancer hostname")                         { |o| @options[:hostname] = o }
      opts.on('-l', '--login USERNAME',                 String,              "Username")                                           { |o| @options[:username] = o }
      opts.on('-f', '--fake DIRECTORY',                 String,              "Path to directory with output")                      { |o| @options[:fake] = o }
      opts.on('-d', '--debug',                                               "Enable debug mode")                                  { @options[:debug] = true}
      opts.on('-a', '--about',                                               "Display #{ID} information")                          { output_message ABOUT, 0 }
      opts.on('-V', '--version',                                             "Display #{ID} version")                              { output_message VERSION, 0 }
      opts.on_tail('--help',                                                 "Show this message")                                  { @options[:HELP] = true }

      opts.order!(@arguments)
      output_message opts, 0 if (@arguments.size == 0 and @whoami != :check_a10) or @options[:HELP]

      @action = @whoami == :check_a10 ? :check : @arguments.shift.to_sym
      case @action
        when :show then  @a10 = Show.new(@arguments,@options)
        else raise OptionParser::InvalidArgument, "invalid action #@action"
      end
    end

    def arguments_valid?
      true
    end

    def options_valid?
      true
    end

    def process_options
      raise OptionParser::MissingArgument, "load balancer hostname (-H) must be specified" if @options[:hostname].nil?
      true
    end

    def process_arguments
      true
    end

    def process_command
      @a10.exec
    end

    def output_message(message, exitstatus=nil)
      m = (! exitstatus.nil? and exitstatus > 0) ? "%s: error: %s" % [ID, message] : message
#      Syslog.open("elesai", Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.err "error: #{message}" } unless @options[:debug]
      $stderr.write "#{m}\n" if STDIN.tty?
      exit exitstatus unless exitstatus.nil?
    end


  end
end end