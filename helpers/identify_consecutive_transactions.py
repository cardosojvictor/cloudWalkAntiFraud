import csv
from datetime import datetime, timedelta

# Load the CSV data
data = []
with open('payment_transactions.csv', 'r') as csv_file:
    csv_reader = csv.reader(csv_file)
    header = next(csv_reader)
    for row in csv_reader:
        data.append(row)

# Sort the data by user_id and transaction_date
data.sort(key=lambda x: (x[2], x[4]))

# Initialize variables to keep track of the previous transaction
previous_user_id = None
previous_datetime = None
consecutive_transactions = []
found_transactions = []

# Define the time window (2 minutes)
time_window = timedelta(minutes=2)

# Iterate through the sorted data
for row in data:
    user_id = row[2]
    transaction_datetime = datetime.strptime(row[4], "%Y-%m-%dT%H:%M:%S.%f")

    if previous_user_id == user_id:
        if transaction_datetime - previous_datetime <= time_window:
            consecutive_transactions.append(row[0])
        else:
            consecutive_transactions = [row[0]]
    else:
        consecutive_transactions = [row[0]]
    
    if len(consecutive_transactions) > 1:
        found_transactions.append(row)
        print("Consecutive transactions:", consecutive_transactions)

    previous_user_id = user_id
    previous_datetime = transaction_datetime

output_file = 'consecutive_transactions.csv'
found_transactions.sort(key=lambda x: (x[2]))
with open(output_file, "w") as file:
    print(found_transactions)
    for line in found_transactions:
        file.write(line.__str__() + '\n')
