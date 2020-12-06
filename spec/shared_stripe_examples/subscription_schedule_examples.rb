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

      subscription_schedule = Stripe::SubscriptionSchedule.create({
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

      expect(subscription_schedule.object).to eq('subscription_schedule')
      expect(subscription_schedule.customer).to eq(customer.id)
      expect(subscription_schedule.end_behavior).to eq('cancel')

      subscriptions = Stripe::Subscription.list(customer: customer.id)
      expect(subscriptions.data).to_not be_empty
      expect(subscriptions.count).to eq(1)
      expect(subscriptions.data.length).to eq(1)

      expect(subscriptions.data.first.id).to eq(subscription_schedule.subscription)
      expect(subscriptions.data.first.customer).to eq(customer.id)
      expect(subscriptions.data.first.billing).to eq('charge_automatically')
    end
  end
end
