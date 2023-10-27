class PaymentTransaction < ActiveRecord::Base
    self.table_name = 'payment_transactions'
  
    def self.all_transactions
      all
    end
  
    def self.find_by_transaction_id(transaction_id)
      find_by(transaction_id: transaction_id)
    end
  
    def self.find_by_device(device_id)
      where(device_id: device_id)
    end

    def self.find_by_merchant_and_cbk(merchant_id, has_cbk)
      where(merchant_id: merchant_id, has_cbk: has_cbk)
    end
  end
  