module Spree
  module Api
    module V1
      class AddressesController < Spree::Api::BaseController
        before_action :find_order

        def show
          authorize! :show, @order, order_token
          @address = find_address
          respond_with(@address)
        end

        def update
          authorize! :update, @order, order_token
          @address = find_address

          if @address.update(address_params)
            respond_with(@address, default_template: :show)
          else
            invalid_resource!(@address)
          end
        end

        private

        def address_params
          params.require(:address).permit(permitted_address_attributes)
        end

        def find_order
          @order = Spree::Order.find_by!(number: order_id)
        end

        def find_address
          if @order.bill_address_id == params[:id].to_i
            @order.bill_address
          elsif @order.ship_address_id == params[:id].to_i
            @order.ship_address
          else
            raise CanCan::AccessDenied
          end
        end
      end
    end
  end
end
