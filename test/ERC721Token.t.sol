// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC721Token.sol";

contract ERC721TOkenTest is Test {
    ERC721Token erc721Token;
    address owner = address(0x1223);
    address account1 = address(0x1889);
    address account2 = address(0x1778);

    function setUp() public {
        vm.startPrank(owner);
        erc721Token = new ERC721Token("Gold", "GLD", 100);
        vm.stopPrank();
    }

    function testFailMaxSupply() public {
        erc721Token.mintToken(account1, 101);
    }

    function testName() public {
        assertEq(erc721Token.getName(), "Gold");
    }

    function testSymbol() public {
        assertEq(erc721Token.getSymbol(), "GLD");
    }

    function testTotalSupply() public {
        assertEq(erc721Token.totalSupply(), 100);
    }

    function testFailEmptyMint() public {
        vm.startPrank(owner);
        erc721Token.mintToken(account1, 0);
        vm.stopPrank();
    }

    function testOwner() public {
        assertEq(erc721Token.getOwner(), owner);
    }

    function testMintBurnBalance() public {
        vm.startPrank(owner);
        erc721Token.mintToken(account1, 2);
        vm.stopPrank();
        assertEq(erc721Token.balanceOf(account1), 2);
        assertEq(erc721Token.holderOf(1), account1);
        assertEq(erc721Token.holderOf(2), account1);
        assertEq(erc721Token.supply(), 2);

        vm.startPrank(account1);
        erc721Token.burnToken(1);
        vm.stopPrank();
        assertEq(erc721Token.balanceOf(account1), 1);
        assertEq(erc721Token.holderOf(1), address(0));
        assertEq(erc721Token.supply(), 1);
    }

    function testFailNotOwnerMint() public {
        erc721Token.mintToken(account1, 85);
    }

    function testTransfer() public {
        vm.startPrank(owner);
        erc721Token.mintToken(account1, 80);
        vm.stopPrank();

        vm.startPrank(account1);
        erc721Token.transfer(7, account2);
        vm.stopPrank();

        assertEq(erc721Token.balanceOf(account1), 79);
        assertEq(erc721Token.balanceOf(account2), 1);
    }

    function testTransferFrom() public {
        vm.startPrank(owner);
        erc721Token.mintToken(account1, 85);
        vm.stopPrank();

        vm.startPrank(account1);
        erc721Token.approve(74, account2);
        vm.stopPrank();

        vm.startPrank(account2);
        erc721Token.transferFrom(account1, account2, 74);
        vm.stopPrank();
    }

    function testFailUnauthorizedTransferFrom() public {
        vm.startPrank(owner);
        erc721Token.mintToken(account1, 85);
        vm.stopPrank();

        vm.startPrank(account2);
        erc721Token.transferFrom(account1, account2, 74);
        vm.stopPrank();
    }
}
