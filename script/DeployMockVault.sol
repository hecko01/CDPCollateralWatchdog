// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MockVault} from "../src/MockVault.sol";

contract DeployMockVaultScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy MockVault with initial collateral/debt
        // Example: 2 ETH collateral, 1 DAI debt = 200% ratio (safe)
        MockVault vault = new MockVault(2 ether, 1 ether);
        
        vm.stopBroadcast();
        
        console.log("MockVault deployed at:", address(vault));
        console.log("Initial collateral: 2 ETH, debt: 1 DAI");
        console.log("Initial ratio: 200% (safe)");
    }
}
