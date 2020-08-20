module StripeMock
  module RequestHandlers
    module SubscriptionSchedules

      def SubscriptionSchedules.included(klass)
        klass.add_handler 'post /v1/subscription_schedules', :create_subscription_schedule
      end

      def create_subscription_schedule(route, method_url, params, headers)
        route =~ method_url

        customer = params[:customer]
        customer_id = customer.is_a?(Stripe::Customer) ? customer[:id] : customer.to_s
        customer = assert_existence :customer, customer_id, customers[customer_id]

        if params[:source]
          new_card = get_card_by_token(params.delete(:source))
          add_card_to_object(:customer, new_card, customer)
          customer[:default_source] = new_card[:id]
        end

        allowed_params = %w(customer metadata phases start_date default_settings end_behavior from_subscription)
        unknown_params = params.keys - allowed_params.map(&:to_sym)
        if unknown_params.length > 0
          raise Stripe::InvalidRequestError.new("Received unknown parameter: #{unknown_params.join}", unknown_params.first.to_s, http_status: 400)
        end

        subscription = Data.mock_subscription({id: "sub_id"})

        sub_sched = Data.mock_subscription_schedule({
          id: (params[:id] || new_id('sub_sched')),
          customer: customer_id,
          end_behavior: params[:end_behavior],
          phases: params[:phases],
          default_settings: params[:default_settings],
          subscription: subscription[:id],
        })
      end
    end
  end
end
