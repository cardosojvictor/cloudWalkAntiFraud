require 'minitest/autorun'
require 'active_record'
require 'mocha/minitest'
require_relative '../lib/data/data_retrieve_service'

class DataRetrieveServiceTest < Minitest::Test
  def setup
    DatabaseConnector.connect(:test)
    @payment_transaction_model = mock('PaymentTransaction')
    @data_retrieve_service = DataRetrieveService.new(@payment_transaction_model)
  end

  def test_retrieve_payments_by_device_calls_model_with_correct_device_id
    @payment_transaction_model.expects(:where).with(device_id: '123')
    @data_retrieve_service.retrieve_payments_by_device('123')
  end

  def test_retrieve_payments_by_user_calls_model_with_correct_user_id
    @payment_transaction_model.expects(:where).with(user_id: '456')
    @data_retrieve_service.retrieve_payments_by_user('456')
  end

  def test_load_payment_transactions_calls_retrieve_all_payment_transactions
    @data_retrieve_service.expects(:retrieve_all_payment_transactions)
    @data_retrieve_service.load_payment_transactions
  end

  def test_retrieve_all_payment_transactions_loads_transactions_from_model
    transactions = [mock('PaymentTransaction'), mock('PaymentTransaction')]
    @payment_transaction_model.expects(:all).returns(transactions)
    @data_retrieve_service.send(:retrieve_all_payment_transactions)
    assert_equal transactions, @data_retrieve_service.instance_variable_get(:@payment_transactions)
  end

  def test_retrieve_all_payment_transactions_only_loads_transactions_once
    @payment_transaction_model.expects(:all).once.returns([])
    2.times { @data_retrieve_service.send(:retrieve_all_payment_transactions) }
  end
end