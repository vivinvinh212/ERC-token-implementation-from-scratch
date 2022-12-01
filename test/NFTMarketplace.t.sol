// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";

contract NFTMarketplaceTest is Test {
    NFTMarketplace nftMarketplace;
    address owner = address(0x1223);
    address account1 = address(0x1889);
    address account2 = address(0x1778);

    function setUp() public {
        vm.startPrank(owner);
        nftMarketplace = new NFTMarketplace();
        vm.stopPrank();
    }

    function testCreateList() public {
        vm.startPrank(account1);
        vm.deal(account1, 1.5 ether);
        nftMarketplace.createToken{value: 0.01 ether}("", 1 ether);
        nftMarketplace.createToken{value: 0.01 ether}("", 2 ether);
        vm.stopPrank();

        assertEq(nftMarketplace.getListedTokenForId(1).seller, account1);
        assertEq(nftMarketplace.getListedTokenForId(1).price, 1 ether);
        assertEq(nftMarketplace.getLatestIdToListedToken().seller, account1);
        assertEq(
            nftMarketplace.getLatestIdToListedToken().owner,
            address(nftMarketplace)
        );
    }

    function testListPrice() public {
        assertEq(nftMarketplace.getListPrice(), 0.01 ether);
    }

    function testFailInsufficientFund() public {
        vm.startPrank(account1);
        vm.deal(account1, 1.5 ether);
        nftMarketplace.createToken{value: 0.005 ether}("", 1);
        vm.stopPrank();
    }

    function testFailZeroPrice() public {
        vm.startPrank(account1);
        vm.deal(account1, 1.5 ether);
        nftMarketplace.createToken{value: 0.05 ether}("", 0);
        vm.stopPrank();
    }

    function testSaleExecute() public {
        vm.startPrank(account1);
        vm.deal(account1, 1.5 ether);
        nftMarketplace.createToken{value: 0.01 ether}("", 1 ether);
        vm.stopPrank();

        vm.startPrank(account2);
        vm.deal(account2, 2 ether);
        nftMarketplace.executeSale{value: 1 ether}(1);
        assertEq(nftMarketplace.getLatestIdToListedToken().seller, account2);
        vm.stopPrank();
    }

    function testFailIncorrectPrice() public {
        vm.startPrank(account1);
        vm.deal(account1, 1.5 ether);
        nftMarketplace.createToken{value: 0.01 ether}("", 1 ether);
        vm.stopPrank();

        vm.startPrank(account2);
        vm.deal(account2, 2 ether);
        nftMarketplace.executeSale{value: 2 ether}(1);
        vm.stopPrank();
    }
}
