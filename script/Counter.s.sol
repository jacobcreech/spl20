// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Spl20} from "../src/spl20.sol";

contract Spl20Script is Script {
    Spl20 public spl20;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        spl20 = new Spl20();

        vm.stopBroadcast();
    }
}
