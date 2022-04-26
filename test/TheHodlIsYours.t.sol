// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../src/TheHodlIsYours.sol";
import "forge-std/Test.sol";

contract TheHodlIsYoursTest is Test {
    TheHodlIsYours c;
    address user1 = address(0x0001);

    function setUp() public {
        c = new TheHodlIsYours();
    }

    function testHodlByUser() public {
        startHoax(user1, 100);
        assertEq(address(user1).balance, 100);
        c.hodl{value: 100}();
        (address acount, uint256 amount) = c.addressToHodlers(user1);
        assertEq(acount, user1);
        assertEq(amount, 100);
        assertEq(address(user1).balance, 0);
    }

    function testHodlManyTimesByUser() public {
        startHoax(user1, 1000);
        for (int256 i = 0; i < 10; i++) {
            c.hodl{value: 100}();
        }
        (address acount, uint256 amount) = c.addressToHodlers(user1);
        assertEq(acount, user1);
        assertEq(amount, 1000);
        assertEq(address(user1).balance, 0);
    }

    function testFailHodlZero() public {
        startHoax(user1);
        vm.expectRevert();
        c.hodl{value: 100}();
    }

    function testFailHodlOver() public {
        startHoax(user1);
        c.hodl{value: 99999 ether}();
        vm.expectRevert();
        c.hodl{value: 2 ether}();
    }

    function testWithdrawByUser() public {
        startHoax(user1, 100);
        c.hodl{value: 100}();
        vm.warp(c.THE_DAY());
        c.withdraw(50);
        (address acount, uint256 amount) = c.addressToHodlers(user1);
        assertEq(acount, user1);
        assertEq(amount, 50);
        assertEq(address(user1).balance, 50);
    }

    function testFailWithdrawZero() public {
        startHoax(user1);
        c.hodl{value: 100}();
        vm.warp(c.THE_DAY());
        c.withdraw(0);
    }

    function testFailWithdrawBeforeTheDay() public {
        startHoax(user1);
        c.hodl{value: 100}();
        c.withdraw(50);
    }

    function testFailWithdrawOverAmount() public {
        startHoax(user1);
        c.hodl{value: 100}();
        vm.warp(c.THE_DAY());
        c.withdraw(101);
    }

    function testGetHodlers() public {
        address[] memory accounts = new address[](10);
        accounts[0] = user1;
        accounts[1] = address(0x0002);
        accounts[2] = address(0x0003);
        accounts[3] = address(0x0004);
        accounts[4] = address(0x0005);
        accounts[5] = address(0x0006);
        accounts[6] = address(0x0007);
        accounts[7] = address(0x0008);
        accounts[8] = address(0x0009);
        accounts[9] = address(0x000a);

        for (uint256 i = 0; i < accounts.length; i++) {
            hoax(accounts[i], 100 * (i + 1));
            c.hodl{value: 100 * (i + 1)}();
        }
        (address[] memory gotAccounts, uint256[] memory gotBalances) = c
            .getHodlers();

        for (uint256 i = 0; i < accounts.length; i++) {
            assertEq(gotAccounts[i], accounts[i]);
            assertEq(gotBalances[i], 100 * (i + 1));
        }
    }
}
