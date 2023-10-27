# PaymentProcessorService class is responsible for processing payment transactions and approving 
# or rejecting them based on certain criteria / rules.
class PaymentProcessorService

    # DAILY_TRANSACTIONS_THRESHOLD_LIMIT is a constant that defines the maximum amount of daily transactions allowed.
    DAILY_TRANSACTIONS_THRESHOLD_LIMIT = 7500.0

    # Initializes a new instance of PaymentProcessorService with the given payment_transactions.
    # Loaded all payment transactions to memory, so subsequent requests will be faster at post /process_payment
    #
    # @param payment_transactions [Array<PaymentTransaction>] an array of PaymentTransaction objects loaded into memory.
    def initialize(payment_transactions)
        @payment_transactions = payment_transactions
        puts "Loaded #{@payment_transactions.size} payment transactions to memory"
    end
  
    # Determines whether a payment should be approved or not based on the given payload.
    #
    # @param payload [Hash] a hash containing the payment information.
    # @return [Boolean] true if the payment should be approved, false otherwise.
    def approve_payment?(payload)
        previous_transactions = retrieve_three_previous_transactions(payload)
      
        return false if reject_transaction_chargeback(previous_transactions, payload)
        return false if reject_transaction_threshold_limit(previous_transactions, payload)
      
        historic_check = check_last_three_transactions_in_a_row(previous_transactions, payload, "user_id")
        user_data_check = check_card_number_different_device_and_user(@payment_transactions, payload)
      
        return false if historic_check || user_data_check
      
        puts "All checks passed - transaction approved"
        true
      end
      

    # Rejects the payment transaction if the previous transaction has a chargeback identified.
    #
    # @param previous_transactions [Array<PaymentTransaction>] an array of PaymentTransaction objects representing the previous transactions
    # @param payload [Hash] a hash containing the payment information.
    # @return [Boolean] true if the payment transaction has a chargeback identified, false otherwise.
    def reject_transaction_chargeback(previous_transactions, payload)
        if !previous_transactions.empty?
           if previous_transactions.select { |t| t.has_cbk == true }.any?
                puts "Transaction denied due to previous chargeback identified"
                return true
            else
                return false
            end
        end
    end 

    # Checks if the given payment transaction has a different device ID and user ID than the previous transaction.
    #
    # @param payment_transactions [Array<PaymentTransaction>] an array of PaymentTransaction objects to search for previous transactions.
    # @param payload [Hash] a hash containing the payment information.
    # @return [Boolean] true if the payment transaction has a different device ID and user ID than 
    # the previous transaction, false otherwise - this validation may indicate a legal transaction.
    def check_card_number_different_device_and_user(payment_transactions, payload)
        matching_transactions = payment_transactions.select { |t| t.card_number == payload["card_number"] }
        previous_transaction = matching_transactions.last(1)

        if !previous_transaction.empty? and 
            previous_transaction[0][:device_id] != payload["device_id"] and 
            previous_transaction[0][:user_id] != payload["user_id"]
            return true
        else
            return false
        end
    end 

    # Checks if the given payment transaction exceeds the daily transactions threshold limit.
    #
    # @param previous_transactions [Array<PaymentTransaction>] an array of PaymentTransaction objects representing the previous transactions
    # @param payload [Hash] a hash containing the payment information.
    # @return [Boolean] true if the payment transaction exceeds the daily transactions threshold limit, false otherwise.
    def reject_transaction_threshold_limit(previous_transactions, payload)
      if !previous_transactions.empty?
            same_day_transactions = previous_transactions.select do |t|
                transaction_date = (t[:transaction_date]).to_time
                payload_date = payload["transaction_date"].to_time
                transaction_date.year == payload_date.year &&
                transaction_date.month == payload_date.month &&
                transaction_date.day == payload_date.day
            end
    
            # Calculate the total sum of transaction amounts for the same day
            total_sum = same_day_transactions.map { |t| t[:transaction_amount] }.sum
        
            if total_sum + payload["transaction_amount"] > DAILY_TRANSACTIONS_THRESHOLD_LIMIT
                puts "Transaction denied due to daily transactions threshold limit"
                return true
            else
                return false
            end
        elsif payload["transaction_amount"] > DAILY_TRANSACTIONS_THRESHOLD_LIMIT
            puts "Transaction denied due to daily transactions threshold limit"
            return true
        end
    end

    # Retrieves the last three transactions made by the user.
    #
    # @param payload [Json] containing the payment information.
    # @param search_key [String] the key to search for in the payment_transactions array.
    # @return [Array<PaymentTransaction>] an array of PaymentTransaction objects containing previous transactions.
    def retrieve_three_previous_transactions(payload, search_key = "user_id")
        @payment_transactions.select { |t| t[search_key] == payload[search_key] }.first(3)
    end
    
    # Checks if the last three transactions made by the user were made within a 90 seconds interval - and the current
    # transaction will be classified as a fraud if it is executed in a row, in this short period of time.
    #
    # @param previous_transactions [Array<PaymentTransaction>] an array of PaymentTransaction objects containing previous transactions.
    # @param payload [Json] containing the payment information.
    # @param search_key [String] the key to search for in the payment_transactions array.
    # @return [Boolean] true if the last three transactions made by the user were made within a 90sec interval, false otherwise.
    def check_last_three_transactions_in_a_row(previous_transactions, payload, search_key)
        if previous_transactions.empty? or previous_transactions.length < 2
            return false
        end

        if previous_transactions.length >= 2
            last_transaction_time = previous_transactions[0][:transaction_date] + 3.hours
            penultimate_transaction_time = previous_transactions[1][:transaction_date] + 3.hours
            current_transaction_time = payload["transaction_date"].to_time
            
            last_diff = (current_transaction_time - last_transaction_time).to_f
            inner_diff = (last_transaction_time - penultimate_transaction_time).to_f

            if last_diff <= 90.0 and inner_diff <= 90.0
                puts "Transaction denied due to last three transactions time interval - multiple transaction in a row"
                return true
            else
                return false
            end
        end
    end

end
  