## Test Cases:

### 1. Setting Up Pre-Sale

   - **Description:** This test sets up the `tokenSale` contract with specific parameters for the pre-sale.
   - **Parameters:**
     - Start timestamp: 1704892329
     - End timestamp: 1804892329 (very high date)
     - Max ether cap for sale: 5 ether
     - Minimum user contribution: 10 wei
     - Maximum user contribution: 10 Gwei
     - Token price (price of 1 Supra Demo Token): 10 wei
     - Minimum ether cap (minimum amount of ether to be collected else refund): 2 ether

### 2. Testing Pre-Sale

   - **Description:** This test simulates a user (address 2) purchasing 1 Gwei worth of Supra Demo Tokens during the pre-sale at a price of 10 wei per token.
   - **Steps:**
     1. Admin sets up the pre-sale.
     2. User (address 2) participates in the pre-sale by sending 10 Gwei.
   - **Expected Result:** The balance of address 2 in the `tokenSale` contract is 1 Gwei.

### 3. Testing Public Sale

   - **Description:** This test simulates the public sale after the pre-sale has completed. Address 2 buys 500,000,000 Supra Tokens for 10 Gwei at a rate of 20 wei per token.
   - **Steps:**
     1. Admin initializes the public sale.
     2. User (address 2) participates in the public sale by sending 10 Gwei.
   - **Expected Result:** The balance of address 2 in the `tokenSale` contract is 500,000,000.

### 4. Testing Token Distribution by Admin

   - **Description:** This test covers the distribution of tokens by the admin to specified addresses.
   - **Steps:**
     1. Admin distributes 100 tokens to address 3.
     2. Attempting distribution by a non-admin (address 2).
   - **Expected Result:**
     - Token balance of address 3 is 100.
     - Distribution by a non-admin is expected to revert.

### 5. Testing Claiming Refund at Pre-Sale

   - **Description:** This test covers the scenario where a user claims a refund during the pre-sale if the minimum ether collection is not reached.
   - **Steps:**
     1. User (address 2) participates in the pre-sale.
     2. Time passes to exceed the pre-sale end timestamp.
     3. User (address 2) claims a refund.
   - **Expected Result:**
     - Ether balance of address 2 increases.
     - Ether balance of the `tokenSale` contract decreases.
     - Supra Demo Token balance of address 2 becomes zero.

### 6. Testing Claiming Refund at Public Sale

   - **Description:** This test covers the scenario where a user claims a refund during the public sale if the minimum ether collection is not reached.
   - **Steps:**
     1. Admin initializes the public sale.
     2. User (address 2) participates in the public sale.
     3. Time passes to exceed the public sale end timestamp.
     4. User (address 2) claims a refund.
   - **Expected Result:**
     - Ether balance of address 2 increases.
     - Ether balance of the `tokenSale` contract decreases.
     - Supra Demo Token balance of address 2 becomes zero.

These test cases aim to cover the key functionalities of the `tokenSale` contract in various scenarios. The results should be verified through testing tools or frameworks.