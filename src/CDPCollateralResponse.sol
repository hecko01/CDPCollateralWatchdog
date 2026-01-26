// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CDPCollateralResponse - PRODUCTION READY VERSION
 * @dev Response contract for CDP collateralization alarm with comprehensive data handling
 */
contract CDPCollateralResponse {
    // The Drosera relay address on Hoodi
    address public constant DROSERA_RELAY = 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D;
    
    // Owner/admin address for emergency overrides
    address public owner;
    
    event CollateralEmergency(
        uint256 currentRatio,
        uint256 threshold,
        uint256 collateral,
        uint256 debt,
        uint256 timestamp,
        address triggeredBy
    );
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    modifier onlyDrosera() {
        require(msg.sender == DROSERA_RELAY, "Caller is not Drosera relay");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Emergency response function called by Drosera when trap triggers
     * @param responseData Data passed from the trap (ratio, threshold, collateral, debt)
     */
    function emergencyResponse(bytes calldata responseData) external onlyDrosera {
        // Decode the comprehensive data from the trap
        (uint256 currentRatio, uint256 threshold, uint256 collateral, uint256 debt) = 
            abi.decode(responseData, (uint256, uint256, uint256, uint256));
        
        // Add timestamp here (in the response contract, not the trap)
        uint256 timestamp = block.timestamp;
        
        // Log the emergency event with all relevant data
        emit CollateralEmergency(
            currentRatio,
            threshold,
            collateral,
            debt,
            timestamp,
            msg.sender
        );
        
        // In production, you could:
        // 1. Call a circuit breaker in the actual protocol
        // 2. Send notifications via Gelato/OpenZeppelin Defender
        // 3. Initiate emergency shutdown procedures
        // 4. Notify governance via Snapshot/Tally
    }
    
    /**
     * @dev Admin function to manually trigger for testing
     */
    function manualTrigger(
        uint256 ratio, 
        uint256 threshold, 
        uint256 collateral, 
        uint256 debt
    ) external onlyOwner {
        emit CollateralEmergency(
            ratio,
            threshold,
            collateral,
            debt,
            block.timestamp,
            msg.sender
        );
    }
    
    /**
     * @dev Transfer ownership (for admin management)
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
