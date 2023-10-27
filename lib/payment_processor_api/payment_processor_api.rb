# api/api.rb
require 'sinatra/base'
require 'json'
require_relative  '../data/data_retrieve_service'
require_relative '../data/payment_transaction_model'
require_relative '../data/database_connector'
require_relative 'payment_processor_service'

module CloudWalkAntiFraud
  class PaymentProcessorApi < Sinatra::Base

    data_retrieve_service = DataRetrieveService.instance
    payment_transactions = data_retrieve_service.load_payment_transactions
    payment_processor_service = PaymentProcessorService.new(payment_transactions)
    
    get '/payments/:device_id' do
      device_id = params[:device_id]
      payments = data_retrieve_service.retrieve_payments_by_device(device_id)
      content_type :json
      payments.to_json
    end

    post '/process_payment' do
      content_type :json
      begin
        payload = JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 400, { error: 'invalidPayload' }.to_json
      end

      unless payload && payload['transaction_id']
        halt 400, { error: 'missingPayload - no transaction_id found' }.to_json
      end

      puts "Processing payment #{payload['transaction_id']}"
      recommendation = payment_processor_service.approve_payment?(payload) ? 'approve' : 'deny'

      # Return the recommendation in the response
      { transaction_id: payload['transaction_id'], recommendation: recommendation }.to_json
    end

  end
end
