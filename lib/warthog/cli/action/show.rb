module Warthog; module CLI; module Action

  class Show

    COMPONENTS = %w(service-group)

    def initialize(arguments,options)

      @options = options
      @arguments = arguments

      @component = nil
      @subcomponent = nil

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] show <component> [arguments]"
      opts.separator ""
      opts.separator "      <component> is service-group"
      opts.order!(@arguments)

      options_valid?
      arguments_valid?
      process_arguments

      @show = { :service_group => self.method(:show_service_group)
      }
    end

    def exec
      @a10slb = Warthog::A10::AXDevice.new(@options[:hostname],@options[:username],get_password)
      @show[@component].call(@subcomponent)
    end

    def show_service_group(name=nil)
      if name.nil?
        printf "%s" % [@a10slb.slb_service_group_all]
      else
        printf "%s" % [@a10slb.slb_service_group_search(name)]
      end
    end

    protected

    def options_valid?
      true
    end

    def arguments_valid?
      raise ArgumentError, "missing component" if @arguments.size == 0
      raise ArgumentError, "invalid component #{@arguments[0]}" unless COMPONENTS.include? @arguments[0]
      true
    end

    def process_arguments
      @component = case @arguments[0].gsub(/-/,'_').to_sym
                     when :dummy then a10 = nil
                     else @arguments[0].gsub(/-/,'_').to_sym
                   end
      @subcomponent = @arguments[1]
    end

    def get_password
      password = nil
      begin
        printf "Password: "
        STDOUT.flush
        system "stty -echo"
        password = $stdin.gets.chomp
      ensure
        system "stty echo"
        printf "\n"
      end
      password
    end
  end

end end end

