// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "../src/sale.sol";

contract saleTest is Test {
    tokenSale saleContract;

    /**
     * The test for setting up pre sale of tokens
     * First setting up the contract
     * The parameters of initialisation of sale contract is as following:
     * start timestamp: 1704892329
     * end timestamp: 1804892329 (at very high date)
     * max ether cap for sale: 5 ether
     * minimum user contribution: 10 wei
     * maximum user contribution: 10 Gwei
     * token price (price of 1 supra demo token): 10 wei
     * minimum ether cap(minimum amount of ether to be collected else refund): 2 ether
     */

    function setUp() external {
        vm.prank(address(1)); // making address 1 as admin of the contract
        vm.deal(address(2), 100 ether);
        saleContract = new tokenSale(
            1704892329, 1804892329, 5 ether, 10 wei, 10 gwei, 10 wei, 2 ether
        );
    }

    /**
     * function to test pre sale of tokens
     * here user (address 2) has purchased 1000000000 supra tokens for 10 gwei
     * at price of 10 wei per token
     */

    function testPreSale() external {
        vm.startPrank(address(2));
        vm.warp(1704892929);
        saleContract.presale{value: 10 gwei}();
        console.log("balance of buyer at pre sale is", saleContract.balanceOf(address(2)));
        assertEq(saleContract.balanceOf(address(2)), 1 gwei);
    }

    /**
     * function to test public sale of tokens
     * first address 1 (owner) has initialised public sale after pre sale has completed
     * address 2 bought 500000000 supra tokens for 10 gwei
     * at rate of 20 wei per token
     */

    function testPublicSale() external {
        vm.startPrank(address(1));
        vm.warp(1805892329); // setting timestamp greater than expiry of pre sale
        saleContract.startPublicSale(1806892329, 5 ether, 20 wei, 10 gwei, 20 wei, 2 ether);
        vm.stopPrank();
        vm.startPrank(address(2));
        saleContract.publicSale{value: 10 gwei}();
        console.log("balance of buyer at public sale is", saleContract.balanceOf(address(2)));
        assertEq(saleContract.balanceOf(address(2)), 500000000);
    }

    /**
     * function to test distribution of token by admin. here both the admin and
     * without admin case is being tested
     */

    function testDistributeTokenAdmin() external {
        console.log("<----- when caller is admin ----->");
        vm.startPrank(address(1));
        saleContract.distributeTokenAdmin(100, address(3));
        console.log("balance of address 3 is", saleContract.balanceOf(address(3)));
        vm.stopPrank();
        console.log("<----- when caller is not admin ----->");
        vm.startPrank(address(2));
        vm.expectRevert();
        saleContract.distributeTokenAdmin(100, address(4));
        console.log("balance of address 4 is", saleContract.balanceOf(address(3)));
    }

    /**
     * function to claim pre sale tokens if ether collection is less than min required
     * amount
     */

    function testClaimRefundPreSale() external {
        vm.startPrank(address(2));
        vm.warp(1704892929);
        saleContract.presale{value: 10 gwei}();
        console.log("<----- previous ether balance of address 2 (caller) at pre sale ----->", address(2).balance);
        console.log(
            "<----- previous supra demo token balance of address 2 (caller) at pre sale ----->",
            saleContract.balanceOf(address(2))
        );
        vm.warp(1804892330);
        saleContract.approve(address(saleContract), 12 gwei);
        saleContract.claimRefundPreSale();
        console.log(
            "<----- ether balance of address 2 (caller) after claiming refund at pre sale ----->", address(2).balance
        );
        console.log(
            "<----- ether balance of contract (sale.sol) after claiming refund at pre sale ----->",
            address(saleContract).balance
        );
        console.log(
            "<----- supra demo token balance of address 2 (caller) after claiming refund at pre sale ----->",
            saleContract.balanceOf(address(2))
        );
    }
    /**
     * function to claim public sale tokens if ether collection is less than min required
     * amount
     */

    function testClaimRefundPublicSale() external {
        vm.startPrank(address(1));
        vm.warp(1805892329); // setting timestamp greater than expiry of pre sale
        saleContract.startPublicSale(1806892329, 5 ether, 20 wei, 10 gwei, 20 wei, 2 ether);
        vm.stopPrank();
        vm.startPrank(address(2));
        saleContract.publicSale{value: 10 gwei}();
        console.log("<----- previous ether balance of address 2 (caller) at public sale ----->", address(2).balance);
        console.log(
            "<----- previous supra demo token balance of address 2 (caller) at public sale ----->",
            saleContract.balanceOf(address(2))
        );
        vm.warp(1806892330);
        saleContract.approve(address(saleContract), 20 gwei);
        saleContract.claimRefundPublicSale();
        console.log(
            "<----- ether balance of address 2 (caller) after claiming refund at public sale ----->", address(2).balance
        );
        console.log(
            "<----- ether balance of contract (sale.sol) after claiming refund at public sale ----->",
            address(saleContract).balance
        );
        console.log(
            "<----- supra demo token balance of address 2 (caller) after claiming refund at public sale ----->",
            saleContract.balanceOf(address(2))
        );
    }
}
