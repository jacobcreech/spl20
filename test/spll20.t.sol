// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Spl20, Mint, TokenAccount} from "../src/spl20.sol";

contract Spl20Test is Test {
    Spl20 public spl20;

    function setUp() public {
        spl20 = new Spl20();
    }

    function test_InitializeMint() public {
        address mintAuthority = address(1);
        address freezeAuthority = address(2);
        address mintAddress = address(3);

        spl20.initializeMint(9, mintAuthority, freezeAuthority, mintAddress);

        Mint memory mint = spl20.getMint(mintAddress);

        assertEq(mint.decimals, 9);
        assertEq(mint.supply, 0);
        assertEq(mint.mintAuthority, mintAuthority);
        assertEq(mint.freezeAuthority, freezeAuthority);
        assertEq(mint.mintAddress, mintAddress);
    }

    function test_MintTokens() public {
        address mintAuthority = address(1);
        address freezeAuthority = address(2);
        address mintAddress = address(3);

        vm.startPrank(mintAuthority);

        spl20.initializeMint(9, mintAuthority, freezeAuthority, mintAddress);

        spl20.mintTokens(mintAuthority, mintAddress, 100000);

        vm.stopPrank();

        assertEq(spl20.getMint(mintAddress).supply, 100000);

        TokenAccount memory account = spl20.getTokenAccount(mintAuthority, mintAddress);
        assertEq(account.mintAddress, mintAddress);
        assertEq(account.owner, mintAuthority);
        assertEq(account.balance, 100000);
        assertEq(account.isFrozen, false);
    }

    function test_Transfer() public {
        address mintAuthority = address(1);
        address freezeAuthority = address(2);
        address mintAddress = address(3);

        vm.startPrank(mintAuthority);

        spl20.initializeMint(9, mintAuthority, freezeAuthority, mintAddress);

        spl20.mintTokens(mintAuthority, mintAddress, 100000);

        spl20.transfer(address(5), mintAddress, 10000);

        vm.stopPrank();

        assertEq(spl20.getMint(mintAddress).supply, 100000);
        assertEq(spl20.getTokenAccount(mintAuthority, mintAddress).balance, 90000);
        assertEq(spl20.getTokenAccount(address(5), mintAddress).balance, 10000);
    }
}
