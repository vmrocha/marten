module Marten
  module Views
    module Rendering
      macro included
        # Returns the configured template name.
        class_getter template : String?

        extend Marten::Views::Rendering::ClassMethods
      end

      module ClassMethods
        # Allows to configure the template that should be rendered by the view.
        def template(template : String?)
          @@template = template
        end
      end

      # Renders the configured template for a specific `context` object.
      def render_to_response(context : Hash | NamedTuple | Nil | Marten::Template::Context)
        HTTP::Response.new(Marten.templates.get_template(self.class.template.not_nil!).render(context))
      end
    end
  end
end
