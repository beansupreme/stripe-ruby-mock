require 'spec_helper'
require 'securerandom'

shared_examples 'Subscription Schedule API' do
  let(:gen_card_tk) { stripe_helper.generate_card_token }

  let(:product) { stripe_helper.create_product }
  let(:plan_attrs) { {id: 'silver', product: product.id, amount: 4999, currency: 'usd'} }
  let(:plan) { stripe_helper.create_plan(plan_attrs) }

  context "creating a new subscription schedule" do
    it "adds a new subscription to customer with none", :live => true do
      plan
      customer = Stripe::Customer.create(source: gen_card_tk)
      subscriptions = Stripe::Subscription.list(customer: customer.id)

      expect(subscriptions.data).to be_empty
      expect(subscriptions.count).to eq(0)

      sub = Stripe::SubscriptionSchedule.create({
        customer: customer.id,
        start_date: Time.now.to_i,
        end_behavior: 'cancel',
        phases: [
          {
            plans: [
              price: 'silver',
              quantity: 1,
            ],
            iterations: 10,
          },
        ],
      })

      expect(sub.object).to eq('subscription_schedule')
      expect(sub.customer).to eq(customer.id)
      expect(sub.end_behavior).to eq('cancel')
    end
  end
end
