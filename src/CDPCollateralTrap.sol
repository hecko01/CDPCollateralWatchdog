// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/interfaces/ITrap.sol";

// Interface declared outside the contract
interface IMockVault {
    function getCollateralizationRatio() external view returns (uint256);
    function collateralAmount() external view returns (uint256);
    function debtAmount() external view returns (uint256);
}

/**
 * @title CDPCollateralTrap - PRODUCTION READY VERSION
 * @dev Monitors a MockVault for undercollateralization with proper on-chain reads
 */
contract CDPCollateralTrap is ITrap {
    // Address of the deployed vault on Hoodi testnet
    address public constant VAULT_ADDRESS = 0x8331Ccc62A9C5c9b28749A8601180255FC68B92B;
    
    // Liquidation threshold in basis points (150% = 15000)
    uint256 public constant LIQUIDATION_THRESHOLD = 15000;
    
    /**
     * @dev Collect the current collateralization ratio from the vault
     * @return bytes-encoded ratio (uint256) or empty bytes if vault doesn't exist/call fails
     */
    function collect() external view override returns (bytes memory) {
        // Guard: Check if vault exists at the address
        uint256 size;
        assembly {
            size := extcodesize(VAULT_ADDRESS)
        }
        if (size == 0) {
            // Vault doesn't exist at this address
            return bytes("");
        }
        
        try IMockVault(VAULT_ADDRESS).getCollateralizationRatio() returns (uint256 ratio) {
            // Also collect raw collateral/debt amounts for debugging
            uint256 collateral = IMockVault(VAULT_ADDRESS).collateralAmount();
            uint256 debt = IMockVault(VAULT_ADDRESS).debtAmount();
            
            // Return ratio, collateral, and debt for comprehensive monitoring
            return abi.encode(ratio, collateral, debt);
        } catch {
            // Vault call failed (reverted or threw)
            return bytes("");
        }
    }
    
    /**
     * @dev Check if we should respond (trigger) based on the collected data
     * @param data Array of bytes-encoded data from collect()
     * @return shouldRespond Whether to trigger the response
     * @return responseData Additional data for the response contract
     */
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        // Safety checks: ensure we have data and it's not empty
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes("No valid data"));
        }
        
        // Get the most recent data point (data[0] is newest)
        bytes memory latestData = data[0];
        
        // Decode the data (ratio, collateral, debt)
        (uint256 ratio, uint256 collateral, uint256 debt) = abi.decode(latestData, (uint256, uint256, uint256));
        
        // Check if ratio is below liquidation threshold
        if (ratio < LIQUIDATION_THRESHOLD) {
            // Vault is undercollateralized! Trigger response.
            // Include all relevant data for the response contract
            // NOTE: Cannot use block.timestamp in pure function
            return (true, abi.encode(ratio, LIQUIDATION_THRESHOLD, collateral, debt));
        }
        
        // Ratio is safe, no response needed
        return (false, bytes(""));
    }
}
