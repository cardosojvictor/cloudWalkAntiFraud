# CloudWalkAntiFraud

Welcome to the CloudWalkAntiFraud Anti Fraud System! Directory structure:

- root directory of the project: cloudWalkAntiFraud
- answers for the section '3. Tasks' from the challenge: answers/answers_payment_industry.md
- config: ruby config files and database.yml
- helpers: some scripts built in the beginning of the project to understand the data and patterns, and to insert them into the DB
- lib: the project classes files - where the solution is implemented
- lib/data: classes to connect to the database (Amazon RDS) and to provide functions to retrieve data
- lib/payment_processor_api: api to process the incoming payments and approve or not, based on rules

cloud_walk_anti_fraud.rb -> main file, run this one to get the system up and running

ruby cloud_walk_anti_fraud.rb

## Installation

- Clone the project and install the needed dependencies (gems) - bundle install

## Usage

- In the folder lib run the following:
ruby cloud_walk_anti_fraud.rb

endpoint to validate a transaction [approve/deny] - POST /process_payment: http://localhost:4567/process_payment 

- test_payment_processor_api.rb can also be run to validate scenarios

## Development structure and architecture

It was created a database at Amazon RDS, in order to load all the payment transactions to a new table:
- payment_transactions

development:
  adapter: postgresql
  url: postgresql://postgres:BYkKUDwbpH5AsADarTzV@cw-payment-transactions.chmvvzhykcoy.us-east-2.rds.amazonaws.com:5432

  ![Alt text](architecture.png)