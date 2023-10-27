require_relative 'data/database_connector'
require_relative 'data/data_retrieve_service'
require_relative 'payment_processor_api/payment_processor_api'

# Start the Sinatra application
CloudWalkAntiFraud::PaymentProcessorApi.run!
