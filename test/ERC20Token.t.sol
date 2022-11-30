// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";

contract ERC20TOkenTest is Test {
    ERC20Token erc20Token;
    address owner = address(0x1223);
    address account1 = address(0x1889);
    address account2 = address(0x1778);

    function setUp() public {
        vm.startPrank(owner);
        erc20Token = new ERC20Token("Gold", "GLD", 100);
        vm.stopPrank();
    }

    function testFailMaxSupply() public {
        erc20Token.mintToken(account1, 101);
    }

    function testName() public {
        assertEq(erc20Token.getName(), "Gold");
    }

    function testSymbol() public {
        assertEq(erc20Token.getSymbol(), "GLD");
    }

    function testAllowance() public {
        vm.startPrank(account1);
        erc20Token.approve(account2, 0, 74);
        vm.stopPrank();
        assertEq(erc20Token.allowance(account1, account2), 74);
    }

    function testMintBalance() public {
        vm.startPrank(owner);
        erc20Token.mintToken(account1, 85);
        vm.stopPrank();
        assertEq(erc20Token.balanceOf(account1), 85);
    }

    function testOwner() public {
        assertEq(erc20Token.getOwner(), owner);
    }

    function testFailNotOwnerMint() public {
        erc20Token.mintToken(account1, 85);
    }

    function testTransfer() public {
        vm.startPrank(owner);
        erc20Token.mintToken(account1, 85);
        vm.stopPrank();

        vm.startPrank(account1);
        erc20Token.transfer(account2, 74);
        vm.stopPrank();

        assertEq(erc20Token.balanceOf(account1), 11);
        assertEq(erc20Token.balanceOf(account2), 74);
    }

    function testTransferFrom() public {
        vm.startPrank(owner);
        erc20Token.mintToken(account1, 85);
        vm.stopPrank();

        vm.startPrank(account1);
        erc20Token.approve(account2, 0, 74);
        vm.stopPrank();

        vm.startPrank(account2);
        erc20Token.transferFrom(account1, account2, 74);
        vm.stopPrank();
    }

    function testFailUnauthorizedTransferFrom() public {
        vm.startPrank(owner);
        erc20Token.mintToken(account1, 85);
        vm.stopPrank();

        vm.startPrank(account2);
        erc20Token.transferFrom(account1, account2, 74);
        vm.stopPrank();
    }
}
