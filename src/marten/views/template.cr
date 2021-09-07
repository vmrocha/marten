require "./concerns/rendering"

module Marten
  module Views
    class Template < Base
      include Rendering

      # Returns a hash containing the template context or `nil`.
      #
      # The default implementation returns `nil`.
      def context
        nil
      end

      def get
        render_to_response(context)
      end
    end
  end
end
