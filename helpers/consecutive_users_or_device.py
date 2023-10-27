import csv
from datetime import datetime, timedelta

def find_consecutive(data, column_index, time_window_minutes):
    data.sort(key=lambda x: (x[column_index], x[4]))  # Sort the data by the specified column and transaction_date
    previous_value = None
    previous_datetime = None
    consecutive_values = []
    found_rows = []
    time_window = timedelta(minutes=time_window_minutes)

    for row in data:
        current_value = row[column_index]
        transaction_datetime = datetime.strptime(row[4], "%Y-%m-%dT%H:%M:%S.%f")

        if previous_value == current_value:
            if transaction_datetime - previous_datetime <= time_window:
                consecutive_values.append(current_value)
            else:
                consecutive_values = [current_value]
        else:
            consecutive_values = [current_value]

        if len(consecutive_values) > 1:
            found_rows.append(row)
            print(f"Consecutive {header[column_index]}:", consecutive_values)

        previous_value = current_value
        previous_datetime = transaction_datetime

    return found_rows

# Load the CSV data
data = []
header = []
with open('payment_transactions.csv', 'r') as csv_file:
    csv_reader = csv.reader(csv_file)
    header = next(csv_reader)
    for row in csv_reader:
        data.append(row)

# Search for consecutive user IDs
found_user_consecutive = find_consecutive(data, 2, 2)  # Column index 2 for user_id

# Search for consecutive device IDs
found_device_consecutive = find_consecutive(data, 6, 2)  # Column index 6 for device_id

# Write the results to CSV files
output_user_file = 'consecutive_user_transactions.csv'
output_device_file = 'consecutive_device_transactions.csv'

found_user_consecutive.sort(key=lambda x: (x[2]))
found_device_consecutive.sort(key=lambda x: (x[6]))

with open(output_user_file, "w", newline='') as user_file, open(output_device_file, "w", newline='') as device_file:
    user_writer = csv.writer(user_file)
    device_writer = csv.writer(device_file)
    
    user_writer.writerow(header)
    device_writer.writerow(header)
    
    user_writer.writerows(found_user_consecutive)
    device_writer.writerows(found_device_consecutive)
