// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "../src/Cutie.sol";

// contract CutieTest is Test {
//     Cutie cutie;
//     address owner = address(0x1223);
//     address alice = address(0x1889);
//     address bob = address(0x1778);

//     function setUp() public {
//         vm.startPrank(owner);
//         cutie = new Cutie();
//         vm.stopPrank();
//     }

//     // 1. The contract is deployed successfully. 5 points
//     function testDeployed() public {
//         assertEq(cutie.deployed(), true);
//     }

//     // 2. The deployed address is set to the owner. 5 points
//     function testOwner() public {
//         assertEq(cutie.owner(), owner);
//     }

//     // 3. No more than 100 tokens can be minted. 10 points
//     function testFailExceedMaxSupply() public {
//         vm.startPrank(bob);
//         vm.deal(bob, 1.5 ether);
//         cutie.safeMint{value: 1.01 ether}(101);
//         vm.stopPrank();
//         assertEq(cutie.balanceOf(bob), 101);
//     }

//     // 4. A token can not be minted if less value than cost (0.01) is provided. 10 points
//     function testFailInsufficientFund() public {
//         vm.startPrank(bob);
//         vm.deal(bob, 0.005 ether);
//         cutie.safeMint{value: 0.01 ether}(1);
//         vm.stopPrank();
//         assertEq(cutie.balanceOf(bob), 1);
//     }

//     // 5. No more than five tokens can be minted in a single transaction. 10 points
//     function testFailExceedMaxPerTrans() public {
//         vm.startPrank(bob);
//         vm.deal(bob, 1 ether);
//         cutie.safeMint{value: 0.06 ether}(6);
//         vm.stopPrank();
//         assertEq(cutie.balanceOf(bob), 6);
//     }

//     // 6. The owner can withdraw the funds collected from the sale. 10 points
//     function testWithdrawFromOwner() public {
//         // switch to a diffent acount and mint a nft to have funds in contrat//
//         vm.startPrank(bob);
//         vm.deal(bob, 1 ether);
//         cutie.safeMint{value: 0.01 ether}(1);
//         assertEq(cutie.balanceOf(bob), 1);
//         vm.stopPrank();
//         //call withdraw with owner address//
//         vm.startPrank(owner);
//         cutie.withdraw();
//         assertEq(owner.balance, 0.01 ether);
//     }

//     // 7. You can mint one token provided the correct amount of ETH. 10 points
//     function testMintSingle() public {
//         vm.startPrank(alice);
//         vm.deal(alice, 1 ether);
//         cutie.safeMint{value: 0.01 ether}(1);
//         vm.stopPrank();
//         assertEq(cutie.balanceOf(alice), 1);
//     }

//     // 8. You can mint three tokens in a single transaction provided the correct amount of ETH. 10 points
//     function testMintMultiple() public {
//         vm.startPrank(alice);
//         vm.deal(alice, 1 ether);
//         cutie.safeMint{value: 0.03 ether}(3);
//         vm.stopPrank();
//         assertEq(cutie.balanceOf(alice), 3);
//     }

//     // 9. Check the balance of an account that minted three tokens (use multiple accounts to make it easy to understand and readable). 10 points
//     function testCheckPostMintBalance() public {
//         vm.startPrank(alice);
//         vm.deal(alice, 1 ether);
//         cutie.safeMint{value: 0.03 ether}(3);
//         vm.stopPrank();
//         assertEq(cutie.balanceOf(alice), 3);
//         assertLt(address(alice).balance, 1 ether);
//     }
// }
