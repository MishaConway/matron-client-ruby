module Matron
  module Consul
    module Recursable
      protected

      def fetch_recursively path, map=true
        result = ::Diplomat::Kv.get path, recurse: true
        if result.kind_of? String
          [result]
        elsif result.kind_of? Array
          if map
            result.map{ |h| h[:value] }
          else
            result
          end
        else
          []
        end
      rescue Diplomat::KeyNotFound
        []
      end


    end
  end
end