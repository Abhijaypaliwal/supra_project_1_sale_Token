// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title tokenSale
 * @notice sale contract of tokens at pre-define price at 2 stages- pre sale and public sale
 * @author Abhijay Paliwal
 */

contract tokenSale is ERC20, Ownable {
    receive() external payable {}
    
    /**
     * @notice boolean function to check if public sale id open or not
     */
    bool public isPublicSale;

    /**
     * @notice fixed token price during pre sale
     */
    uint256 public tokenPricePreSale;

    /**
     * @notice fixed token price during public sale
     */
    uint256 public tokenPricePublicSale;

    /**
     * @notice start time for pre sale event
     */
    uint256 public startTimestampPreSale;

    /**
     * @notice end time for pre sale event
     */
    uint256 public endTimestampPreSale;

    /**
     * @notice end time for public sale event
     */
    uint256 public endTimestampPublicSale;

    /**
     * @notice maximum cap for ether collection at pre sale event
     */
    uint256 public maxEtherCapPreSale;

    /**
     * @notice maximum cap for ether collection at public sale event
     */
    uint256 public maxEtherCapPublicSale;

    /**
     * @notice min user contribution by user at pre sale event
     */
    uint256 public minUserContributionPreSale;

    /**
     * @notice max user contribution by user at pre sale event
     */
    uint256 public maxUserContributionPreSale;

    /**
     * @notice min user contribution by user at public sale event
     */
    uint256 public minUserContributionPublicSale;

    /**
     * @notice max user contribution by user at public sale event
     */
    uint256 public maxUserContributionPublicSale;

    /**
     * @notice remaining ether to be collected at pre sale event
     */
    uint256 public remainingEthPreSale;

    /**
     * @notice remaining ether to be collected at public sale event
     */
    uint256 public remainingEthPublicSale;

    /**
     * @notice min ether to be collected at pre sale event
     */
    uint256 public minEtherCapPreSale;

    /**
     * @notice min ether to be collected at public sale event
     */
    uint256 public minEtherCapPublicSale;

    /**
     * @notice Emitted when ether is deposited at pre sale event
     * @dev This event is emitted when a user deposit ether at pre sale event
     * @param _to address indexed Address that triggered the deposit.
     * @param _etherAmt uint256 amount of ether deposited.
     * @param _tokenAmt uint256 amount of token released to caller.
     */
    event depositPreSale(address indexed _to, uint256 _etherAmt, uint256 _tokenAmt);

    /**
     * @notice Emitted when ether is deposited at public sale event.
     * @dev This event is emitted when a user deposit ether at public sale event.
     * @param _to address indexed Address that triggered the deposit.
     * @param _etherAmt uint256 amount of ether deposited.
     * @param _tokenAmt uint256 amount of token released to caller.
     */
    event depositPublicSale(address indexed _to, uint256 _etherAmt, uint256 _tokenAmt);

    /**
     * @notice Emitted when admin calls the function with amount of token to transfer
     * @dev This event is emitted when admin calls function to transfer tokens.
     * @param _to address indexed Address to transfer token.
     * @param _tokenAmt uint256 amount of token released to address.
     */
    event adminTokenDist(address indexed _to, uint256 _tokenAmt);

    /**
     * @notice Emitted when user calls function to claim ether.
     * @dev This event is emitted when ether collected is less than min threshold at specified time.
     * @param _to address indexed Address to transfer token.
     * @param _etherAmt uint256 amount of ether released to address.
     */
    event preSaleRefundClaim(address indexed _to, uint256 _etherAmt);

    /**
     * @notice Emitted when user calls function to claim ether.
     * @dev This event is emitted when ether collected is less than min threshold at specified time.
     * @param _to address indexed Address to transfer token.
     * @param _etherAmt uint256 amount of ether released to address.
     */
    event publicSaleRefundClaim(address indexed _to, uint256 _etherAmt);

    /**
     * @dev Contract constructor
     * @param _startTimestampPreSale uint256 time to start presale
     * @param _endTimestampPreSale uint256 time to end presale
     * @param _maxEtherCapPreSale uint256 max ether to collect at presale
     * @param _minUserContributionPreSale uint256 min amount which user can buy token
     * @param _maxUserContributionPreSale uint256 max amount which user can buy token
     * @param _tokenPricePreSale uint256 token price in terms of ether
     * @param _minEtherCapPreSale uint256 min acceptable ether collection to avoid refund
     */
    constructor(
        uint256 _startTimestampPreSale,
        uint256 _endTimestampPreSale,
        uint256 _maxEtherCapPreSale,
        uint256 _minUserContributionPreSale,
        uint256 _maxUserContributionPreSale,
        uint256 _tokenPricePreSale,
        uint256 _minEtherCapPreSale
    ) ERC20("SupraDemoToken", "SUPRADEMO") Ownable(msg.sender) {
        startTimestampPreSale = _startTimestampPreSale;
        endTimestampPreSale = _endTimestampPreSale;
        maxEtherCapPreSale = _maxEtherCapPreSale;
        minUserContributionPreSale = _minUserContributionPreSale;
        maxUserContributionPreSale = _maxUserContributionPreSale;
        tokenPricePreSale = _tokenPricePreSale;
        remainingEthPreSale = maxEtherCapPreSale;
        minEtherCapPreSale = _minEtherCapPreSale;
    }

    /**
     * @dev function is internal
     * @notice mint token when called
     * @param _to address to release token
     * @param _amount uint256 amount of token to mint
     */
    function mintToken(address _to, uint256 _amount) internal returns (bool) {
        _mint(_to, _amount);
        return true;
    }

    /**
     * @dev function is payable
     * @notice pre sale function to sell tokens at predefined price
     * @notice for sake of simplicity, 1 wei = 1 supra demo token
     */
    function presale() external payable {
        require(
            startTimestampPreSale < block.timestamp && endTimestampPreSale > block.timestamp,
            "the auction is either not started or auction is finished"
        );
        require(msg.value <= remainingEthPreSale, "maximum cap on ethereum raising is reached");
        require(msg.value >= minUserContributionPreSale, "amount is less than minimum contribution");
        require(msg.value <= maxUserContributionPreSale, "amount is more than maximum contribution");
        uint256 _tokenToMint = msg.value / tokenPricePreSale;
        remainingEthPreSale -= msg.value;
        mintToken(msg.sender, _tokenToMint);
        emit depositPreSale(msg.sender, msg.value, _tokenToMint);
    }
    // public sale would be started after pre-sale gets over. Here admin gives details about sale

    /**
     * @dev function can only be called by owner
     * @notice mint token when called
     * @param _endTimestampPublicSale uint256 time to end public
     * @param _maxEtherCapPublicSale uint256 max ether to collect at public sale
     * @param _minUserContributionPublicSale uint256 min amount which user can buy token
     * @param _maxUserContributionPublicSale uint256 max amount which user can buy token
     * @param _tokenPricePublicSale uint256 token price in terms of ether
     * @param _minEtherCapPublicSale uint256 min acceptable ether collection to avoid refund
     */
    function startPublicSale(
        uint256 _endTimestampPublicSale,
        uint256 _maxEtherCapPublicSale,
        uint256 _minUserContributionPublicSale,
        uint256 _maxUserContributionPublicSale,
        uint256 _tokenPricePublicSale,
        uint256 _minEtherCapPublicSale
    ) external onlyOwner returns (bool) {
        require(endTimestampPreSale < block.timestamp, "presale is not over yet");
        isPublicSale = true;
        endTimestampPublicSale = _endTimestampPublicSale;
        maxEtherCapPublicSale = _maxEtherCapPublicSale;
        minUserContributionPublicSale = _minUserContributionPublicSale;
        maxUserContributionPublicSale = _maxUserContributionPublicSale;
        tokenPricePublicSale = _tokenPricePublicSale;
        minEtherCapPublicSale = _minEtherCapPublicSale;
        remainingEthPublicSale = maxEtherCapPublicSale;
        return true;
    }

    /**
     * @dev function is payable
     * @notice can only be called when presale gets over
     * @notice public sale function to sell tokens at predefined price
     */
    function publicSale() external payable {
        require(isPublicSale == true && endTimestampPublicSale > block.timestamp, "public sale is not started yet");
        require(msg.value <= remainingEthPublicSale, "maximum cap on ethereum raising is reached");
        require(msg.value >= minUserContributionPublicSale, "amount is less than minimum contribution");
        require(msg.value <= maxUserContributionPublicSale, "amount is more than maximum contribution");
        uint256 _tokenToMint = msg.value / tokenPricePublicSale;
        remainingEthPublicSale -= msg.value;
        mintToken(msg.sender, _tokenToMint);
        emit depositPublicSale(msg.sender, msg.value, _tokenToMint);
    }

    /**
     * @dev function can only be called by owner
     * @notice admin can call function to release token to specified address
     */
    function distributeTokenAdmin(uint256 _amount, address _transferAddr) external onlyOwner {
        mintToken(_transferAddr, _amount);
        emit adminTokenDist(_transferAddr, _amount);
    }

    /**
     * @dev function can only be called when min number of ether is NOT collected at specified time
     * at pre sale
     * @notice balance of token is refunded to contract and ether is released to user
     */
    function claimRefundPreSale() external {
        require(
            endTimestampPreSale < block.timestamp && (maxEtherCapPreSale - remainingEthPreSale) < minEtherCapPreSale,
            "refund can only be claimed if minimum cap is already reached"
        );

        require(balanceOf(msg.sender) > 0, "no supra demo token balance detected");
        uint256 userBalance = balanceOf(msg.sender);
        transfer(address(this), userBalance);
        (bool success,) = msg.sender.call{value: userBalance * tokenPricePreSale}("");
        require(success, "Failed to send Ether");
        emit preSaleRefundClaim(msg.sender, userBalance * tokenPricePreSale);
    }

    /**
     * @dev function can only be called when min number of ether is NOT collected at specified time
     * at public sale
     * @notice balance of token is refunded to contract and ether is released to user
     */
    function claimRefundPublicSale() external {
        require(
            endTimestampPublicSale < block.timestamp
                && (maxEtherCapPublicSale - remainingEthPublicSale) < minEtherCapPublicSale,
            "refund can only be claimed if minimum cap is already reached"
        );

        require(balanceOf(msg.sender) > 0, "no supra demo token balance detected");
        uint256 userBalance = balanceOf(msg.sender);
        transfer(address(this), userBalance);
        (bool success,) = msg.sender.call{value: userBalance * tokenPricePublicSale}("");
        require(success, "Failed to send Ether");
        emit preSaleRefundClaim(msg.sender, userBalance * tokenPricePreSale);
    }
}
