// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/cHERMES.sol";
import "../src/ConfidentialVault.sol";
import "../src/EncryptedAMM.sol";

contract DeployAll is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address bridge = 0x0980cF9a9fB86761E33717a2e5A1c0678363d029;
        
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying HERMES Protocol...");

        cHERMES token = new cHERMES();
        console.log("cHERMES:", address(token));

        ConfidentialVault vault = new ConfidentialVault(address(token), bridge);
        console.log("Vault:", address(vault));

        token.setVault(address(vault));

        EncryptedAMM amm = new EncryptedAMM();
        console.log("AMM:", address(amm));

        vm.stopBroadcast();
        
        console.log("=== DONE ===");
    }
}
