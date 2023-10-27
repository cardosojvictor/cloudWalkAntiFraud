import csv

payment_transactions = []

csv_file_path = "/home/jose/ruby_projects/cloudWalkAntiFraud/helpers/payment_transactions.csv"

# Read the CSV file and store the data in payment_transactions
with open(csv_file_path, "r", newline="") as file:
    csv_reader = csv.DictReader(file)
    for row in csv_reader:
        payment_transactions.append(row)

# Now, you can process the data as needed
formatted_data = []

for entry in payment_transactions:
    transaction_id = entry['transaction_id']
    merchant_id = entry['merchant_id']
    user_id = entry['user_id']
    card_number = entry['card_number']
    transaction_date = entry['transaction_date']
    transaction_amount = entry['transaction_amount']
    device_id = entry['device_id'] or 'NULL'
    has_cbk = entry['has_cbk']

    formatted_entry = (
        f"({transaction_id}, {merchant_id}, {user_id}, '{card_number}', "
        f"'{transaction_date}', {transaction_amount}, {device_id}, {has_cbk})"
    )

    formatted_data.append(formatted_entry)

formatted_sql = "\n".join(formatted_data)
output_file = "formatted_data.sql"

with open(output_file, "w") as file:
    for columns_values in formatted_sql.splitlines():
        print(columns_values)
        # Create a complete SQL INSERT statement
        insert_statement = f"INSERT INTO payment_transactions VALUES {columns_values};\n"
        file.write(insert_statement)

print(f"SQL insert statements have been written to '{output_file}'.")
