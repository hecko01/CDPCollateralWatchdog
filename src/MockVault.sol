// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockVault
 * @dev A simple mock vault for testing CDP collateralization monitoring
 * Enhanced with additional view functions for the improved trap
 */
contract MockVault {
    // Public state variables for our trap to monitor
    uint256 public collateralAmount; // in wei (simulated ETH)
    uint256 public debtAmount; // in wei (simulated DAI)
    
    // Liquidation threshold (150% = 15000 for basis points)
    uint256 public constant LIQUIDATION_THRESHOLD = 15000;
    
    // Events for state changes
    event CollateralUpdated(uint256 oldAmount, uint256 newAmount);
    event DebtUpdated(uint256 oldAmount, uint256 newAmount);
    
    constructor(uint256 _collateral, uint256 _debt) {
        collateralAmount = _collateral;
        debtAmount = _debt;
    }
    
    /**
     * @dev Get the collateralization ratio in basis points
     * @return ratio Collateralization ratio (collateral/debt * 10000)
     */
    function getCollateralizationRatio() public view returns (uint256) {
        if (debtAmount == 0) return type(uint256).max;
        // Simple ratio: (collateral * 10000) / debt
        return (collateralAmount * 10000) / debtAmount;
    }
    
    /**
     * @dev Get raw collateral and debt amounts
     */
    function getRawAmounts() public view returns (uint256 collateral, uint256 debt) {
        return (collateralAmount, debtAmount);
    }
    
    /**
     * @dev Get current status
     */
    function getStatus() public view returns (
        uint256 ratio,
        uint256 collateral,
        uint256 debt,
        bool isSafe
    ) {
        ratio = getCollateralizationRatio();
        collateral = collateralAmount;
        debt = debtAmount;
        isSafe = ratio >= LIQUIDATION_THRESHOLD;
    }
    
    /**
     * @dev Simulate a change in collateral (e.g., price drop)
     */
    function setCollateral(uint256 _newCollateral) public {
        emit CollateralUpdated(collateralAmount, _newCollateral);
        collateralAmount = _newCollateral;
    }
    
    /**
     * @dev Simulate a change in debt
     */
    function setDebt(uint256 _newDebt) public {
        emit DebtUpdated(debtAmount, _newDebt);
        debtAmount = _newDebt;
    }
    
    /**
     * @dev Simulate a price crash - reduce collateral percentage
     * @param percentage Basis points to reduce (e.g., 2000 = 20% reduction)
     */
    function simulatePriceCrash(uint256 percentage) public {
        require(percentage <= 10000, "Percentage must be <= 10000");
        uint256 newCollateral = (collateralAmount * (10000 - percentage)) / 10000;
        setCollateral(newCollateral);
    }
    
    /**
     * @dev Check if vault is undercollateralized
     */
    function isUndercollateralized() public view returns (bool) {
        return getCollateralizationRatio() < LIQUIDATION_THRESHOLD;
    }
}
