# CDP Collateral Watchdog

A Drosera monitoring trap that simulates the surveillance of an undercollateralized vault in a MakerDAO-like CDP system on the Hoodi testnet.

## 📋 Overview

This project implements a security monitoring trap for the Drosera Network that watches for dangerous collateralization levels in simulated vaults. When a vault's collateral ratio falls below the liquidation threshold, the trap triggers an emergency response.

## 🎯 Creative Concept vs. Technical Reality

### Creative Concept
- **Ideal Scenario:** Monitoring real MakerDAO vaults on Ethereum Mainnet for undercollateralization risks.
- **Threat Model:** Sudden market crashes or oracle manipulation causing vaults to fall below 150% collateralization.
- **Impact:** Protocol insolvency and bad debt accumulation.

### Technical Reality (Hoodi Simulation)
- **Current Implementation:** Monitors a `MockVault` contract with adjustable collateral/debt ratios.
- **Simulation:** Uses hardcoded data in the `collect()` function for deterministic testing.
- **Purpose:** Validates the Drosera trap/response architecture without mainnet dependencies.

## 🏗️ Architecture

### Contracts
1. **`CDPCollateralTrap.sol`** - The monitoring logic
   - `collect()`: Returns simulated collateralization ratio (20000 = 200%)
   - `shouldRespond()`: Triggers if ratio < 15000 (150% threshold)

2. **`CDPCollateralResponse.sol`** - The emergency response
   - `emergencyResponse()`: Emits `CollateralEmergency` event with details
   - *(Production extension:* Could pause withdrawals, notify governance, etc.)

3. **`MockVault.sol`** - Test contract (not deployed)
   - Simulates vault state changes for local testing

### Deployment
- **Response Contract:** `0x3FfEaB2D024BfF04D3e9AD97F954E87Dc8667Ef1` (Hoodi)
- **Trap Contract:** Deployed automatically by Drosera via `drosera apply`
- **Network:** Hoodi Testnet (Chain ID: 560048)

## 🔧 Configuration

### drosera.toml Key Settings
```toml
cooldown_period_blocks = 50      # Prevents rapid retriggering
block_sample_size = 1           # Checks every block (gas-efficient)
private_trap = true             # Only owner can trigger
```

## 🧪 Testing & Validation

###Dry Run Results (✅ PASSED)
- Gas Usage: ~45k total (well within limits)

- Execution: Successfully ran collect() and shouldRespond()

- Threshold Logic: Correctly returns false for safe ratios (200% > 150%)

### To Test Trigger Condition
Modify the trap's `collect()` function to return a ratio < 15000:


```// In CDPCollateralTrap.sol, line ~30:
uint256 simulatedRatio = 14000; // 140% - BELOW THRESHOLD
```

## 🚀 Production Roadmap
To move from simulation to mainnet monitoring:

1. Replace `collect()` Simulation with real vault queries

2. Integrate Price Oracles for accurate collateral valuation

3. Enhance Response Logic with actual mitigation actions

4. Target Real Protocol: MakerDAO, Spark, or other lending protocols

5. Add Redundancy: Multiple data sources for critical metrics

## 📁 Project Structure
```CDPCollateralWatchdog/
├── src/
│   ├── CDPCollateralTrap.sol      # Main trap logic
│   ├── CDPCollateralResponse.sol  # Emergency response
│   └── MockVault.sol              # Simulation contract
├── script/
│   └── Deploy.sol                 # Response deployment
├── lib/interfaces/
│   └── ITrap.sol                  # Drosera interface
├── drosera.toml                   # Network configuration
└── foundry.toml                   # Build configuration
```

## 🔍 Verification
1. Dashboard Status: Check Drosera Dashboard for "Green" active status

2. Event Monitoring: Watch for CollateralEmergency events from response contract

3. Gas Optimization: Current implementation uses minimal gas via single-vector logic

## ⚠️ Important Notes
- This is a **testnet simulation** - not production-ready

- Real vault monitoring requires oracle integration and careful parameter tuning

- Always test extensively on testnet before mainnet deployment

- Consider the "Gas-Safe Rule": Start simple, then add complexity

## 📞 Support
For issues or questions:

1. Check Drosera documentation

2. Review Foundry compilation errors

3. Verify .env configuration and private key format

4. Ensure sufficient testnet ETH for deployments
