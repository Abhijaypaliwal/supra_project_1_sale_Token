# README for SupraDemoToken Sale Contract

# Solidity Code:

The provided Solidity code is for a token sale contract (tokenSale) that facilitates the sale of a token named "SupraDemoToken" (with the symbol "SUPRADEMO"). The contract is based on the ERC-20 standard and inherits from the OpenZeppelin contracts, specifically ERC20 for token functionality and Ownable for ownership control.

The contract supports two stages of the sale: pre-sale and public sale. The pre-sale has a fixed token price (tokenPricePreSale), a specific time window (startTimestampPreSale to endTimestampPreSale), and caps on the amount of ether that can be raised (maxEtherCapPreSale). Similarly, the public sale follows the pre-sale and has its own parameters.

Design Choices:

1. Token Minting: The contract uses an internal function mintToken to mint and distribute tokens. This function is invoked when users participate in the pre-sale or public sale.
2. Ether Collection Caps: The contract enforces maximum caps on ether collection during both pre-sale and public sale (maxEtherCapPreSale and maxEtherCapPublicSale). These caps aim to manage the total amount of funds collected.
3. User Contribution Limits: The contract sets minimum and maximum contribution limits for users during both sale stages. This helps regulate the amount each participant can contribute.
4. Refund Mechanism: Users can claim refunds if the minimum cap for ether collection is not reached during a specified time. Refunds are processed by transferring tokens back to the contract and releasing the corresponding ether to the user.
5. Events: The contract emits events (depositPreSale, depositPublicSale, adminTokenDist, preSaleRefundClaim, publicSaleRefundClaim) to provide transparency and allow external systems to track key contract activities.

# Important Security Considerations:

1. Reentrancy Protection: The contract uses the checks-effects-interactions pattern to mitigate reentrancy attacks. Ether transfers are the last operations in relevant functions.
2. Time Constraints: Time-related conditions (block.timestamp) are used to control the availability of functions. These conditions prevent users from participating outside the specified time frames.
3. Access Control: The contract uses the Ownable modifier to ensure that certain functions, such as starting the public sale and distributing tokens, can only be called by the contract owner.
4. Ether Transfer Safety: The contract employs checks to ensure that ether transfers are successful ((bool success,) = msg.sender.call{value: amount}("");). In case of failure, the transaction reverts.
5. Input Validation: The contract validates user inputs to ensure that contributions fall within acceptable limits and that the sale is in the correct state.

# Test Script

The testing of contract is made via "Foundry" framework
The test smart contract is located in the ./test folder 

To launch the test script, if foundry is not installed in the system, install foundry by typing the command-
`curl -L https://foundry.paradigm.xyz | bash`

then, install openzeppelin dependencies by typing command-
`forge install OpenZeppelin/openzeppelin-contracts`

if there is problem "Openzeppelin-contracts" not found, type- 
`forge remappings > remappings.txt`
which creates a remappings.txt file inside the root directory of the project

Now to launch the script, simply type-
`forge test -vvv`
The above script would show the outputs and pass conditions of the test, if you want to see the transaction traces, simply add an extra "v" in the script at last.

# Test cases

For testing of the smart contract, both the 