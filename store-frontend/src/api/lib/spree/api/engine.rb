require 'rails/engine'

module Spree
  module Api
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_api'

      Rabl.configure do |config|
        config.include_json_root = false
        config.include_child_root = false

        # Motivation here it make it call as_json when rendering timestamps
        # and therefore display miliseconds. Otherwise it would fall to
        # JSON.dump which doesn't display the miliseconds
        config.json_engine = ActiveSupport::JSON
      end

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer 'spree.assets.precompile', group: :all do |app|
        app.config.assets.precompile += %w[
          spree/api/all*
        ]
      end

      initializer 'spree.api.environment', before: :load_config_initializers do |_app|
        Spree::Api::Config = Spree::ApiConfiguration.new
        Spree::Api::Dependencies = Spree::ApiDependencies.new
      end

      initializer 'spree.api.checking_migrations' do
        Migrations.new(config, engine_name).check
      end

      def self.root
        @root ||= Pathname.new(File.expand_path('../../..', __dir__))
      end
    end
  end
end
