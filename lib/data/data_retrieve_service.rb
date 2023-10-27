require 'active_record'
require_relative 'database_connector'
require_relative 'payment_transaction_model'

class DataRetrieveService
  @instance = nil
  @is_loaded_to_memory = false
  @payment_transactions = nil

  private_class_method :new

  def self.instance
    @instance ||= new
  end

  def initialize(payment_transaction_model = PaymentTransaction)
    DatabaseConnector.connect(:development)
    @payment_transaction_model = payment_transaction_model
  end

  def retrieve_payments_by_device(device_id)
    @payment_transaction_model.where(device_id: device_id)
  end

  def retrieve_payments_by_user(user_id)
    @payment_transaction_model.where(user_id: user_id)
  end

  def load_payment_transactions
    retrieve_all_payment_transactions
    @payment_transactions
  end

  private
  def retrieve_all_payment_transactions
    unless @is_loaded_to_memory
      @payment_transactions = @payment_transaction_model.all
      @is_loaded_to_memory = true
    end
  end

end
