## Software Engineer - Risk Test - Jose Victor Cardoso

### 3.1 - Understand the Industry
#### Explain the money flow and the information flow in the acquirer market and the role of the main players.

The money flow starts with a customer buying a product or contracting a new service, online or in person, when interating 
with a point of sale. The acquirer plays the role of connecting the business with the bank, in order to process the payment
transaction. The following diagram illustrates the interaction among the different players in a payment transaction:

   ```plaintext
   +------------------------+
   | Customer (Cardholder) |
   +-----------+------------+
               |
               v
   +------------------------+
   | Business (Merchant)   |
   +-----------+------------+
               | 1. Payment Details
               |
               v
   +------------------------+
   | Acquirer (Payment     |
   | Processor)            |
   +-----------+------------+
               | 2. Transaction Data
               |
               v
   +------------------------+
   | Card Networks         |
   | (e.g., Visa/MasterCard)|
   +-----------+------------+
               | 3. Authorization
               | 4. Clearing
               | 5. Settlement
               |
               v
   +------------------------+
   | Bank (Issuer)         |
   +-----------+------------+
               | 6. Settlement
               |
               v
   +------------------------+
   | Bank (Acquirer)       |
   +------------------------+
```

The main role of the players involved in a payment transaction, the money flow:
- Customer: the process begins with the customer who makes a purchase using a payment card (e.g., credit or debit card) at a business); 
- Business: accept card payments from customers and process these payments through various channels, including point-of-sale (POS) terminals, e-commerce websites, or mobile apps. The business, as the seller, is entitled to receive the payment for the products or services sold;
- Acquirer: payment processor - responsible for authorizing and connecting to the bank;
- Bank: ensures the settlement of funds between the acquirer and the business, as well as the issuance of card statements to customers;
- Card networks (Visa/MasterCard for instance): facilitates the authorization of the payment, clearing (moving funds between banks and acquirers), and settlement (final exchange of funds).
-> Money flows through the card networks: They deduct interchange fees and other fees and then transfer the remaining amount to the acquirer.

Information Flow:
- Customer: Information flow starts with the customer providing card details, such as the card number, expiration date, and CVV, to the business.
- Business (Merchant): The business sends transaction data to the acquirer, including the card details, transaction amount, and other relevant information. The acquirer forwards this data to the card network for authorization.
- Acquirer (Payment Processor): The acquirer facilitates the transaction by sending authorization requests to the card network. They receive the response, which indicates whether the transaction is approved or declined. The acquirer also collects transaction data for settlement.
- Card Networks (Visa/MasterCard): The card networks receive authorization requests from the acquirer, perform fraud checks, and transmit the response back to the acquirer and the business. They also handle the clearing and settlement process.
- Bank: involved in the transaction receive information about the transaction, including settlement details, which allow them to adjust the balances of the acquirer and the business.

#### Explain the difference between acquirer, sub-acquirer and payment gateway and how the flow explained in question 1 changes for these players.

On the one hand, an acquirer is a payment service provider that acts as an intermediary between the marchants and customers, responsible for authorizing and processing the payments transactions, managing chargebacks and ensuring funds are transferred between these two players, a sub-acquirer, on the other hand, is
a specialized financial instituion, offering tailored solutions for businesses with unique needs - or niches. The payment gateway is a technology platform that facilitates the communication between e-commerce websites, mobile apps, or other sales channles, to the acquirer or sub-acquirer. 

These three players can work together to tackle specific needs of a customer, providing a more specialized solution. The flow explained in question 1 changes for these players for the following points:
- acquirer and sub-acquirer can work together, exchanging data and offering payment services to niches;
- sub-acquires extends the reach of acquirers to more merchants;
- payment gateways facilitates transactions between merchantes and acquirers - through API calls, plugins or hosted payment pages;
- the payment gateways can be understood as an interface between merchants and acquires, once it provides this integration by collecting the payment information (credit card details). Payment gateways guarantees a securely transmission of sensitive infomation;

#### Explain what chargebacks are, how they differ from cancellations and what is their connection with fraud in the acquiring world.

Chargebacks are a mechanism in the payment processing industry that allows customers to dispute a credit card transaction 
and request a refund from their bank or credit card issuer. Chargebacks serve as a form of consumer protection and are 
designed to safeguard customers from unauthorized or fraudulent transactions, as well as to resolve disputes with merchants.

On the other hand a cancellation is initiated by the merchant or the customer to stop a transaction before it is completed. 
They are typically agreed upon by both parties, and the funds are usually returned to the customer's account.

While the chargeback is triggered due to a possible fraud, an unauthorized transaction or to resolve disputes, cancellations 
can be triggered by both the customer or the merchant. Those are the reasons why the two types of interventions on
a payment transaction occurs - to refund it (fraud, unauthorized), or to cancel it - customer changed their mind, merchant charged a wrong price tag, etc.

The connection between cancellations and chargebacks with fraud resolves to the attempt of malicious behaviour to complete a transaction
that was not authorized / legal. They can occur when the customer does not recognize a purchase or a service order in his behalf. Fraudsters may try to misuse the chargeback process by falsely claiming that they did not authorize a transaction or that goods or services were not delivered, even when they were. 

```plaintext
   +------------------------+        +------------------------+
   |   Chargeback         |          |   Cancellation        |
   |   Scenario           |          |   Scenario            |
   +-----------+------------+        +-----------+------------+
               |                              |
               v                              v
   +------------------------+         +------------------------+
   | Cardholder (Customer) |          | Customer              |
   +-----------+------------+         +-----------+------------+
               |                              |
               v                              v
   +------------------------+         +------------------------+
   | Cardholder Contacts   |          | Customer Contacts     |
   | Bank                  |          | Merchant              |
   +-----------+------------+         +-----------+------------+
               |                              |
               v                              v
   +------------------------+        +------------------------+
   | Bank Initiates       |          | Merchant Agrees to     |
   | Chargeback           |          | Cancellation           |
   +-----------+------------+        +-----------+------------+
               |                              |
               v                              v
   +------------------------+        +------------------------+
   | Merchant Receives     |         | Refund or Credit      |
   | Chargeback            |         |                       |
   | Notification          |         +-----------+------------+
   +-----------+------------+
               |
               v
   +------------------------+
   | Acquirer (Payment     |
   | Processor)            |
   +------------------------+
               |
               v
   +------------------------+
   | Acquirer Investigates |
   +------------------------+
               |
               v
   +------------------------+
   | Resolution            |
   +------------------------+
```


### 3.2 - Get your hands dirty
#### Using this csv with hypothetical transactional data, imagine that you are trying to understand if there is any kind of suspicious behavior.
####  Analyze the data provided and present your conclusions (consider that all transactions are made using a mobile device).

- In a short period of time a suspicious user_id 76819 tried multiple times to perform a transaction in a row for the same merchant. This seems to be a fraud:

| transaction_id | merchant_id | user_id | card_number     | transaction_date         | transaction_amount | device_id | has_cbk |
|---------------|------------|--------|-----------------|-----------------------------|--------------------|------------|---------|
| 21323537      | 8942       | 76819  | 552289******8870 | 2019-11-03T16:11:02.048688 | 1545.40            | null       | TRUE    |
| 21323538      | 8942       | 76819  | 552289******8870 | 2019-11-03T16:10:00.739538 | 1038.47            | null       | TRUE    |
| 21323539      | 8942       | 76819  | 552289******8870 | 2019-11-03T16:09:21.333406 | 2040.02            | null       | TRUE    |
| 21323540      | 8942       | 76819  | 552289******8870 | 2019-11-03T16:08:01.904202 | 1551.77            | null       | TRUE    |

- In a short period of time a suspicious device_id 27250 tried 3 times to perform a transaction in a row for the same merchant. This seems to be a fraud:

| transaction_id | merchant_id | user_id | card_number     | transaction_date         | transaction_amount | device_id | has_cbk |
|---------------|------------|--------|-----------------|-----------------------------|--------------------|-----------|---------|
| 21321026      | 80155      | 88553  | 410863******7755 | 2019-11-29T15:36:16.283879 | 151.64             | 27250     | FALSE   |
| 21321027      | 80155      | 88553  | 410863******7755 | 2019-11-29T15:35:24.506721 | 280.52             | 27250     | FALSE   |
| 21321028      | 80155      | 88553  | 410863******7755 | 2019-11-29T15:33:58.565067 | 254.95             | 27250     | FALSE   |


- Another scenario in which the same card_number were used from different devices, users and in different merchants. It is already flagged 
as a fraud chargeback.

| transaction_id | merchant_id | user_id | card_number     | transaction_date         | transaction_amount | device_id | has_cbk |
|---------------|------------|--------|-----------------|-----------------------------|--------------------|-----------|---------|
| 21322198      | 53041      | 900    | 412177******1138 | 2019-11-22T19:15:41.109970 | 1346.26            | 691601    | TRUE    |
| 21321610      | 90035      | 85612  | 412177******1138 | 2019-11-26T14:11:59.129077 | 556.91             | 653105    | TRUE    |


#### In addition to the spreadsheet data, what other data would you look at to try to find patterns of possible frauds?

I would also take into consideration the region from which the transaction originated. For example, if it was 
initiated in a different city or state than the user typically frequents - but not deny the transaction directly based on this information,
but combine with other data source for a more robust decision. In addition, I would construct a user 
profile to discern specific transaction patterns when purchasing goods or subscriptions. 

If a particular transaction falls outside of the user's established patterns, it would be advisable to deny it - or at least consider this deviation as a new
criteria to deny transactions, as outiliers.