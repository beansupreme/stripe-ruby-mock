module StripeMock
  module RequestHandlers
    module Prices

      def Prices.included(klass)
        klass.add_handler 'post /v1/prices',        :new_price
        klass.add_handler 'post /v1/prices/(.*)',   :update_price
        klass.add_handler 'get /v1/prices/(.*)',    :get_price
        klass.add_handler 'get /v1/prices',         :list_prices
      end

      def new_price(route, method_url, params, headers)
        params[:id] ||= new_id('price')
        validate_create_price_params(params)
        prices[ params[:id] ] = Data.mock_price(params)
      end

      def update_price(route, method_url, params, headers)
        route =~ method_url
        assert_existence :price, $1, prices[$1]
        prices[$1].merge!(params)
      end

      def get_price(route, method_url, params, headers)
        route =~ method_url
        assert_existence :price, $1, prices[$1]
      end

      def list_prices(route, method_url, params, headers)
        limit = params[:limit] ? params[:limit] : 10
        clone = prices.clone

        if params[:lookup_key]
          clone.delete_if { |k,v| v[:lookup_key] != params[:lookup_key] }
        end

        Data.mock_list_object(clone.values, params.merge!(limit: limit))
      end

    end
  end
end
