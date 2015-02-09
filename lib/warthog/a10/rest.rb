require 'httparty'

module Warthog; module A10

  class AXDevice

    class AuthenticationError < StandardError; end
    class HTTPError < StandardError; end
    class AXapiError < StandardError; end

    include HTTParty

    API_VERSIONS = %w(V2)

    def initialize(hostname,username,password,options={})
      @hostname = hostname
      @session_id = nil
      @api_version = nil
      @username = username
      @password = password
    end

    def slb_service_group_all
      output = ''
      service_group_list = axapi 'slb.service_group.getAll', 'get'
      service_group_list['response']['service_group_list']['service_group'].each do |service_group|
        name = service_group['name']
        service_group['member_list']['member'].each do |member|
          output << "%-16s %12s:%-5s %s %s %s\n" % [name,member['server'],member['port'],member['template'],member['priority'],member['status']] if Hash === member
        end
      end
      output
    end

    def slb_service_group_search(name)
      output = ''
      service_group = axapi 'slb.service_group.search', 'get', :name => name
      service_group['response']['service_group']['member_list']['member'].each do |member|
        output << "%-16s %12s:%-5s %s %s %s\n" % [name,member['server'],member['port'],member['template'],member['priority'],member['status']]
      end
      output
    end

    protected

    def axapi(method,verb,paramvalues={})
      always_uri_params = ["format","session_id","method"]
      if @session_id and @api_version
        r = nil
        if verb == 'get'
          params_to_encode = {session_id: @session_id, method: method}.merge(paramvalues)
          params = URI.encode_www_form(params_to_encode)
          uri = "https://#@hostname/services/rest/#@api_version/?#{params}"
          r = self.class.get(uri)
        else
          # TODO: Implement everything else, supplying paramvalues as a json payload.
          puts "Verb was #{verb.upcase}"
        end

        if r.code == 200
          response = r
          code = 0
          message = ""
          error_message = ""
          # JSON responses don't always have a "response" element, and their
          # "error" element is actually named "err"
          if r.headers['content-type'] == 'application/json'
            response = JSON.parse(r.body)
            if response.has_key?('response') && response['response']['status'] == 'fail'
              code = response['response']['err']['code']
              message = response['response']['err']['msg']
            end
          else
            if response['response']['status'] == 'fail'
              code = response['response']['error']['code']
              message = response['response']['error']['msg']
            end
          end

          error_message = "Code: #{code} Message: #{message}"
          raise AXapiError, error_message if code
          return r
        else
          raise HTTPError, "HTTP code: #{r.code}"
        end
      else
        API_VERSIONS.each do |api_version|
         r = self.class.get("https://#@hostname/services/rest/#{api_version}/?method=authenticate&username=#{@username}&password=#{@password}")
         if r.code == 200
           if r['response']['status'] == 'ok'
             @session_id = r['response']['session_id']
             @api_version = api_version
           elsif r['response']['status'] == 'fail'
             next if r['response']['error']['code'] == '1004'
             raise AuthenticationError, r['response']['error']['msg'] if r['response']['error']['code'] == '520486968'
           end
         else
           raise HTTPError, "HTTP code: #{r.code}"
         end
         raise StandardError, "unable to obtain session id" unless @session_id
        end
        return axapi(method,verb,paramvalues)
      end
    end

  end

end end
