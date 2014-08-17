module HTTPI
  module QueryBuilder

    class Flat

      # Returns a +query+ string given a +Hash+.
      # Example:
      #
      #   build({names => ['Bruno', 'Samantha', 'Alexandre']})
      #   # => "names=Bruno&names=Samantha&names=Alexandre"
      def self.build(query)
        Rack::Utils.build_query(query)
      end

    end

    class Nested

      # Returns a +query+ string given a +Hash+.
      # Example:
      #
      #   build({names => ['Bruno', 'Samantha', 'Alexandre']})
      #   # => "names[]=Bruno&names[]=Samantha&names[]=Alexandre"
      def self.build(query)
        stringfied_query = stringify_hash_values(query)
        Rack::Utils.build_nested_query(stringfied_query)
      end

      private

      # Changes Hash values into Strings
      def self.stringify_hash_values(query)
        query.each do |param, value|
          if value.kind_of?(Hash)
            query[param] = stringify_hash_values(value)
          elsif value.kind_of?(Array)
            query[param] = value.map(&:to_s)
          else
            query[param] = value.to_s
          end
        end
      end

    end

  end
end
