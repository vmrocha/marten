module Marten
  module Routing
    module Parameter
      class Path < Base
        private REGEX = /.+/

        def regex : Regex
          REGEX
        end

        def loads(value : ::String) : ::String
          value
        end

        def dumps(value) : Nil | ::String
          value.as?(::String) ? value.to_s : nil
        end
      end
    end
  end
end