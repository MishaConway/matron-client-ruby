require 'diplomat'
require_relative 'consul/recursable'

module Matron
  class Client
    VERSION = "0.1.0"

    include Matron::Consul::Recursable

    class NameRequired < StandardError; end;


    def initialize( name )
      @name = name
      @name = @name.to_s if @name.kind_of? Symbol
      raise NameRequired unless @name.kind_of?(String) && @name.size > 0
    end

    def register!
      ::Diplomat::Kv.put "matron/apps/#{@name}/hosts/#{ip_address}", ip_address
      ::Diplomat::Kv.put "matron/hosts/#{ip_address}", @name
    end

    def unregister! host=nil
      ::Diplomat::Kv.delete "matron/apps/#{@name}/hosts/#{host || ip_address}"
      ::Diplomat::Kv.delete "matron/hosts/#{host || ip_address}"
    end

    def configure! options
      options = {:max_query_time => 600, :refresh_rate => 1}.merge options
      (options || {}).each do |k, v|
        ::Diplomat::Kv.put "matron/apps/#{@name}/properties/#{k}", v.to_s
      end
    end

    def configuration
      fetch_recursively("matron/apps/#{@name}/properties/", false).map do |property|
        [property[:key].split('/').last.to_sym, property[:value]]
      end.to_h
    end

    def hosts
      fetch_recursively "matron/apps/#{@name}/hosts/"
    end

    protected

    def ip_address
      ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
      ip.ip_address
    end
  end
end
