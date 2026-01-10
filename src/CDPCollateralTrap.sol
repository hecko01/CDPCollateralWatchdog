// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/interfaces/ITrap.sol";

/**
 * @title CDPCollateralTrap
 * @dev Monitors a MockVault for undercollateralization
 */
contract CDPCollateralTrap is ITrap {
    // Address of the vault we're monitoring (deploy separately on Hoodi)
    address public constant VAULT_ADDRESS = 0x0000000000000000000000000000000000000000;
    
    // Liquidation threshold in basis points (150% = 15000)
    uint256 public constant LIQUIDATION_THRESHOLD = 15000;
    
    /**
     * @dev Collect the current collateralization ratio from the vault
     * @return bytes-encoded ratio (uint256)
     */
    function collect() external view override returns (bytes memory) {
        // In a real scenario, we'd call VAULT_ADDRESS.getCollateralizationRatio()
        // Since this is Hoodi and we need deterministic data, we'll simulate
        // For now, return a placeholder that will be replaced with real data
        // when the trap is configured in drosera.toml
        
        // This is a simulation - in real use, we'd make an external call here
        // For Hoodi learning, we'll use a simple return
        uint256 simulatedRatio = 20000; // 200% collateralization
        return abi.encode(simulatedRatio);
    }
    
    /**
     * @dev Check if we should respond (trigger) based on the collected data
     * @param data Array of bytes-encoded collateralization ratios from collect()
     * @return shouldRespond Whether to trigger the response
     * @return responseData Additional data for the response contract
     */
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        // Safety check: ensure we have data
        if (data.length == 0) {
            return (false, bytes("No data"));
        }
        
        // Get the most recent data point (data[0] is newest)
        bytes memory latestData = data[0];
        
        // Decode the collateralization ratio
        uint256 ratio = abi.decode(latestData, (uint256));
        
        // Check if ratio is below liquidation threshold
        if (ratio < LIQUIDATION_THRESHOLD) {
            // Vault is undercollateralized! Trigger response.
            return (true, abi.encode(ratio, LIQUIDATION_THRESHOLD));
        }
        
        // Ratio is safe, no response needed
        return (false, bytes(""));
    }
}
