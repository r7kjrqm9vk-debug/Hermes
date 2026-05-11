// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/IncoCollateralBridge.sol";

contract DeployBridge is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IncoCollateralBridge bridge = new IncoCollateralBridge(
            0xE8e8272b7574F5248eDDF28aAf882dB89474af6c
        );

        console.log("IncoCollateralBridge deployed at:", address(bridge));

        vm.stopBroadcast();
    }
}
