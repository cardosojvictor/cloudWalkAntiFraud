require 'minitest/autorun'
require 'rack/test'
require_relative '../lib/payment_processor_api/payment_processor_api'

class PaymentProcessorApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    CloudWalkAntiFraud::PaymentProcessorApi
  end

  def setup
    @data_retrieve_service = DataRetrieveService.instance
    @payment_transactions = @data_retrieve_service.load_payment_transactions
    @payment_processor_service = PaymentProcessorService.new(@payment_transactions)
  end

  def test_get_payments_by_device_returns_json
    get '/payments/123'
    assert last_response.ok?
    assert_equal 'application/json', last_response.content_type
  end

  def test_post_process_payment_returns_json
    post '/process_payment', { transaction_id: '123', transaction_amount: 100 }.to_json, 'CONTENT_TYPE' => 'application/json'
    assert last_response.ok?
    assert_equal 'application/json', last_response.content_type
  end

  def test_post_process_payment_returns_error_for_invalid_payload
    post '/process_payment', 'invalid_payload', 'CONTENT_TYPE' => 'application/json'
    assert_equal 400, last_response.status
    assert_equal 'application/json', last_response.content_type
    assert_equal({ 'error' => 'invalidPayload' }, JSON.parse(last_response.body))
  end

  def test_post_process_payment_returns_error_for_missing_payload
    post '/process_payment', { transaction_amount: 100 }.to_json, 'CONTENT_TYPE' => 'application/json'
    assert_equal 400, last_response.status
    assert_equal 'application/json', last_response.content_type
    assert_equal({ 'error' => 'missingPayload - no transaction_id found' }, JSON.parse(last_response.body))
  end

  def test_post_process_payment_returns_recommendation
    post '/process_payment', { transaction_id: '123', transaction_amount: 100 }.to_json, 'CONTENT_TYPE' => 'application/json'
    response = JSON.parse(last_response.body)
    assert_equal '123', response['transaction_id']
    assert ['approve', 'deny'].include?(response['recommendation'])
  end

  def test_post_payment_processor_service_exceeds_amount
    payload = {
      "transaction_id": 12663,
      "merchant_id": 74713,
      "user_id": 88888,
      "card_number": "552289******8929",
      "transaction_date": "2019-11-21T01:06:02.862952",
      "transaction_amount": 7800.96,
      "device_id": 10906
    }
    
    @payment_processor_service.stub(:approve_payment?, true) do
      post '/process_payment', payload.to_json, 'CONTENT_TYPE' => 'application/json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.content_type
      assert_equal({ 'transaction_id' => 12663, 'recommendation' => 'deny' }, JSON.parse(last_response.body))
    end
  end

  def test_post_payment_processor_service_has_chk_and_exceeds_amount
    payload = {
      "transaction_id": 21323537,
      "merchant_id": 8942,
      "user_id": 76819,
      "card_number": "552289******8870",
      "transaction_date": "2019-11-03T16:12:02.048688",
      "transaction_amount": 7500.40,
      "device_id": 78745
   }
   
    @payment_processor_service.stub(:approve_payment?, true) do
      post '/process_payment', payload.to_json, 'CONTENT_TYPE' => 'application/json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.content_type
      assert_equal({ 'transaction_id' => 21323537, 'recommendation' => 'deny' }, JSON.parse(last_response.body))
    end
  end

  def test_post_payment_processor_service_same_card_number_different_device_and_user
    payload = {
      "transaction_id": 21321026,
      "merchant_id": 80155,
      "user_id": 88553,
      "card_number": "410863******7755",
      "transaction_date": "2019-11-29T15:36:16.283879",
      "transaction_amount": 151.64,
      "device_id": 27250
    }
    
   
    @payment_processor_service.stub(:approve_payment?, true) do
      post '/process_payment', payload.to_json, 'CONTENT_TYPE' => 'application/json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.content_type
      assert_equal({ 'transaction_id' => 21321026, 'recommendation' => 'deny' }, JSON.parse(last_response.body))
    end
  end

  def test_post_payment_processor_approve_legitimate_transaction
    payload = {
      "transaction_id": 78454512,
      "merchant_id": 17712,
      "user_id": 88490,
      "card_number": "552289******2674",
      "transaction_date": "2019-11-11T19:09:50.419051",
      "transaction_amount": 350.84
    }
   
    @payment_processor_service.stub(:approve_payment?, true) do
      post '/process_payment', payload.to_json, 'CONTENT_TYPE' => 'application/json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.content_type
      assert_equal({ 'transaction_id' => 78454512, 'recommendation' => 'approve' }, JSON.parse(last_response.body))
    end
  end

  def test_post_payment_processor_deny_transaction_has_chargeback
    payload = {
      "transaction_id": 78452102,
      "merchant_id": 77130,
      "user_id": 75710,
      "card_number": "554482******7640",
      "transaction_date": "2019-11-08T23:15:00.465991",
      "transaction_amount": 4000.37,
    }
    
    
    @payment_processor_service.stub(:approve_payment?, true) do
      post '/process_payment', payload.to_json, 'CONTENT_TYPE' => 'application/json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.content_type
      assert_equal({ 'transaction_id' => 78452102, 'recommendation' => 'deny' }, JSON.parse(last_response.body))
    end
  end

  def test_post_payment_processor_deny_multiple_transactions_in_a_row
    payload = {
      "transaction_id": 78798798,
      "merchant_id": 80155,
      "user_id": 88553,
      "card_number": "410863******7755",
      "transaction_date": "2019-11-29T15:36:24.506721",
      "transaction_amount": 280.52,
      "device_id": 27250
    }
   
    @payment_processor_service.stub(:approve_payment?, true) do
      post '/process_payment', payload.to_json, 'CONTENT_TYPE' => 'application/json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.content_type
      assert_equal({ 'transaction_id' => 78798798, 'recommendation' => 'deny' }, JSON.parse(last_response.body))
    end
  end

end