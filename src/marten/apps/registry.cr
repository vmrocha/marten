module Marten
  module Apps
    # The applications registry.
    #
    # The applications registry is responsible for managing all the application config classes of a given project.
    class Registry
      def initialize
        @app_configs_store = {} of String => Config
        @unassigned_models = [] of DB::Model.class
      end

      # Returns an array of the available app configs.
      def app_configs
        @app_configs_store.values
      end

      # Returns the app config instance for the passed app label.
      #
      # Raises `Marten::Apps::Errors::AppNotFound` if the app config cannot be found.
      def get(label : String)
        @app_configs_store.fetch(label) do
          raise Errors::AppNotFound.new("Label '#{label}' is not associated with any installed apps")
        end
      end

      # Returns the application config object contaning the passed class.
      def get_containing(klass)
        candidates = [] of Config

        @app_configs_store.values.each do |config|
          if klass._marten_app_location.starts_with?(config.class._marten_app_location)
            remaining = klass._marten_app_location[config.class._marten_app_location.size..]
            next unless remaining == "" || remaining[0] == '/'
            candidates << config
          end
        end

        result = unless candidates.empty?
          candidates.sort_by { |config| config.class._marten_app_location.size }.reverse!.first
        end

        if result.nil?
          raise Errors::AppNotFound.new(
            "Class '#{klass}' is not part of an application defined in Marten.settings.installed_apps"
          )
        end

        result.not_nil!
      end

      def insert_main_app
        populate([MainConfig])
      end

      # Populate the app config registry from the list of the project installed apps.
      def populate(installed_apps : Array(Config.class)) : Nil
        installed_apps.each do |app|
          if @app_configs_store.has_key?(app.label)
            raise Errors::InvalidAppConfig.new("App labels must be unique, duplicate found: '#{app.label}'")
          end

          @app_configs_store[app.label] = app.new
        end

        @unassigned_models.each do |model|
          config = model.app_config
          config.register_model(model)
        rescue Errors::AppNotFound
          # Skip models that are associated with non-installed apps.
        end
      end

      # Registers a specific model class to the registry of app configs.
      #
      # This model will be associated later on to the associated app config once all the app configs of the current
      # project are populated and initialized.
      def register_model(model : DB::Model.class)
        @unassigned_models << model
      end

      # Triggers app config setups.
      def setup
        app_configs.each(&.setup)
      end
    end
  end
end
