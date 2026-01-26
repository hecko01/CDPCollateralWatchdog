// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface IMockVault {
    function getCollateralizationRatio() external view returns (uint256);
    function getRawAmounts() external view returns (uint256, uint256);
    function simulatePriceCrash(uint256 percentage) external;
    function setCollateral(uint256 _newCollateral) external;
    function isUndercollateralized() external view returns (bool);
}

contract SimulateAttackScript is Script {
    address constant VAULT = 0x8331Ccc62A9C5c9b28749A8601180255FC68B92B;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        console.log("=== Testing CDP Collateral Watchdog ===");
        
        // Check initial state
        IMockVault vault = IMockVault(VAULT);
        (uint256 initRatio, uint256 initCollateral, uint256 initDebt, bool initSafe) = getVaultStatus(vault);
        console.log("\nInitial State:");
        console.log("  Ratio: %s (%s%%)", initRatio, initRatio / 100);
        console.log("  Collateral: %s ETH", initCollateral / 1e18);
        console.log("  Debt: %s DAI", initDebt / 1e18);
        console.log("  Safe: %s", initSafe);
        
        // Simulate 30% price crash (enough to trigger: 200% → 140%)
        console.log("\nSimulating 30% price crash...");
        vm.startBroadcast(deployerPrivateKey);
        vault.simulatePriceCrash(3000); // 30% reduction
        vm.stopBroadcast();
        
        // Check post-crash state
        (uint256 crashRatio, uint256 crashCollateral, uint256 crashDebt, bool crashSafe) = getVaultStatus(vault);
        console.log("\nPost-Crash State:");
        console.log("  Ratio: %s (%s%%)", crashRatio, crashRatio / 100);
        console.log("  Collateral: %s ETH", crashCollateral / 1e18);
        console.log("  Debt: %s DAI", crashDebt / 1e18);
        console.log("  Safe: %s", crashSafe);
        console.log("  Should Trigger: %s", crashRatio < 15000);
        
        console.log("\n=== Test Complete ===");
        console.log("The trap should now trigger when Drosera runs collect()!");
        console.log("Run 'drosera dryrun' to verify the trigger condition.");
    }
    
    function getVaultStatus(IMockVault vault) internal view returns (
        uint256 ratio,
        uint256 collateral,
        uint256 debt,
        bool isSafe
    ) {
        ratio = vault.getCollateralizationRatio();
        (collateral, debt) = vault.getRawAmounts();
        isSafe = vault.isUndercollateralized() == false;
    }
}
