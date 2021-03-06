require 'katello_test_helper'

module Katello
  class SubscriptionTest < ActiveSupport::TestCase
    def setup
      @basic = katello_subscriptions(:basic_subscription)
      @other = katello_subscriptions(:other_subscription)
    end

    def test_subscription_returns_pools
      assert @other.pools.count > 0
    end

    def test_pool_states
      pools = [FactoryGirl.build(:katello_pool, :active), FactoryGirl.build(:katello_pool, :expiring_soon)]
      @basic.stubs(:pools).returns(pools)
      assert @basic.active?
      assert @basic.expiring_soon?
      refute @basic.recently_expired?
    end
  end
end
