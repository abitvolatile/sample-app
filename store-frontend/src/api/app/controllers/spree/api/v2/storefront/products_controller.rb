module Spree
  module Api
    module V2
      module Storefront
        class ProductsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def index
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          private

          def sorted_collection
            collection_sorter.new(collection, params, current_currency).call
          end

          def collection
            collection_finder.new(scope: scope, params: params, current_currency: current_currency).execute
          end

          def resource
            scope.find_by(slug: params[:id]) || scope.find(params[:id])
          end

          def collection_sorter
            Spree::Api::Dependencies.storefront_products_sorter.constantize
          end

          def collection_finder
            Spree::Api::Dependencies.storefront_products_finder.constantize
          end

          def collection_serializer
            Spree::Api::Dependencies.storefront_product_serializer.constantize
          end

          def resource_serializer
            Spree::Api::Dependencies.storefront_product_serializer.constantize
          end

          def scope
            Spree::Product.accessible_by(current_ability, :show).includes(scope_includes)
          end

          def scope_includes
            {
              master: :default_price,
              variants: [],
              variant_images: [],
              taxons: [],
              product_properties: :property,
              option_types: :option_values,
              variants_including_master: %i[default_price option_values]
            }
          end
        end
      end
    end
  end
end
