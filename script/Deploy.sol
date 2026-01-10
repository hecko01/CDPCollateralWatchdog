// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {CDPCollateralResponse} from "../src/CDPCollateralResponse.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ONLY the Response contract
        // Drosera will deploy the Trap itself
        CDPCollateralResponse response = new CDPCollateralResponse();
        
        vm.stopBroadcast();
        
        // Log the deployed address
        console.log("Response contract deployed at:", address(response));
    }
}
