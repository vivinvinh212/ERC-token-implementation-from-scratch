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

    // function testAllowance() public {
    //     vm.startPrank(account1);
    //     erc721Token.approve(account2, 0, 74);
    //     vm.stopPrank();
    //     assertEq(erc721Token.allowance(account1, account2), 74);
    // }

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
        assertEq(erc721Token.balanceOf(account1), 3);

        // vm.startPrank(account1);
        // erc721Token.burnToken(20);
        // vm.stopPrank();
        // assertEq(erc721Token.balanceOf(account1), 65);
    }

    function testFailNotOwnerMint() public {
        erc721Token.mintToken(account1, 85);
    }

    // function testTransfer() public {
    //     vm.startPrank(owner);
    //     erc721Token.mintToken(account1, 85);
    //     vm.stopPrank();

    //     vm.startPrank(account1);
    //     erc721Token.transfer(account2, 74);
    //     vm.stopPrank();

    //     assertEq(erc721Token.balanceOf(account1), 11);
    //     assertEq(erc721Token.balanceOf(account2), 74);
    // }

    // function testTransferFrom() public {
    //     vm.startPrank(owner);
    //     erc721Token.mintToken(account1, 85);
    //     vm.stopPrank();

    //     vm.startPrank(account1);
    //     erc721Token.approve(account2, 0, 74);
    //     vm.stopPrank();

    //     vm.startPrank(account2);
    //     erc721Token.transferFrom(account1, account2, 74);
    //     vm.stopPrank();
    // }

    // function testFailUnauthorizedTransferFrom() public {
    //     vm.startPrank(owner);
    //     erc721Token.mintToken(account1, 85);
    //     vm.stopPrank();

    //     vm.startPrank(account2);
    //     erc721Token.transferFrom(account1, account2, 74);
    //     vm.stopPrank();
    // }
}
