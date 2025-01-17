module Marten
  module Routing
    module Parameter
      class UUID < Base
        regex /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

        def loads(value : ::String) : ::UUID
          ::UUID.new(value)
        end

        def dumps(value) : Nil | ::String
          case value
          when ::UUID
            value.to_s
          when ::String
            ::UUID.parse?(value).try(&.to_s)
          else
            nil
          end
        end
      end
    end
  end
end
