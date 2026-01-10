// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockVault
 * @dev A simple mock vault for testing CDP collateralization monitoring
 */
contract MockVault {
    // Public state variables for our trap to monitor
    uint256 public collateralAmount; // in wei (simulated ETH)
    uint256 public debtAmount; // in wei (simulated DAI)
    
    // Liquidation threshold (150% = 15000 for basis points)
    uint256 public constant LIQUIDATION_THRESHOLD = 15000;
    
    constructor(uint256 _collateral, uint256 _debt) {
        collateralAmount = _collateral;
        debtAmount = _debt;
    }
    
    /**
     * @dev Get the collateralization ratio in basis points
     * @return ratio Collateralization ratio (collateral/debt * 10000)
     * Note: In reality, you'd have price oracles. Here we use simple values.
     */
    function getCollateralizationRatio() public view returns (uint256) {
        if (debtAmount == 0) return type(uint256).max;
        // Simple ratio: (collateral * 10000) / debt
        return (collateralAmount * 10000) / debtAmount;
    }
    
    /**
     * @dev Simulate a change in collateral (e.g., price drop)
     */
    function setCollateral(uint256 _newCollateral) public {
        collateralAmount = _newCollateral;
    }
    
    /**
     * @dev Simulate a change in debt
     */
    function setDebt(uint256 _newDebt) public {
        debtAmount = _newDebt;
    }
    
    /**
     * @dev Check if vault is undercollateralized
     */
    function isUndercollateralized() public view returns (bool) {
        return getCollateralizationRatio() < LIQUIDATION_THRESHOLD;
    }
}
