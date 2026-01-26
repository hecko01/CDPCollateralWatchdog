// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CDPCollateralResponse} from "../src/CDPCollateralResponse.sol";
import {MockVault} from "../src/MockVault.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy MockVault first (for trap to monitor)
        MockVault vault = new MockVault(2 ether, 1 ether); // 200% ratio initially
        
        // Deploy Response contract
        CDPCollateralResponse response = new CDPCollateralResponse();
        
        vm.stopBroadcast();
        
        console.log("==================== DEPLOYMENT COMPLETE ====================");
        console.log("MockVault deployed at:", address(vault));
        console.log("Initial collateral: 2 ETH, debt: 1 DAI = 200% ratio (safe)");
        console.log("");
        console.log("Response contract deployed at:", address(response));
        console.log("");
        console.log("NEXT STEPS:");
        console.log("1. Update CDPCollateralTrap.sol VAULT_ADDRESS to:", address(vault));
        console.log("2. Recompile: forge build");
        console.log("3. Update drosera.toml with new trap JSON path");
        console.log("4. Test vault unsafe state: vault.setCollateral(1.4 ether)");
        console.log("   (This creates 140% ratio < 150% threshold)");
        console.log("=============================================================");
    }
}
