# SentinelShield

## Advanced AI-Driven Fraud Detection and Anomalous Pattern Recognition for Stacks DEXs

I have developed SentinelShield as a high-performance, autonomous fraud detection system built on the Stacks blockchain using Clarity. This contract is designed to safeguard decentralized exchange (DEX) ecosystems by monitoring real-time trading data, calculating multi-factor risk scores, and generating actionable fraud alerts via an integrated machine learning-inspired logic engine.

---

### Table of Contents

1. Overview
2. Key Features
3. Architecture
4. Technical Specification
5. Detailed Function Analysis (Public & Private)
6. Security & Risk Levels
7. Installation & Deployment
8. Contribution Guidelines
9. Roadmap
10. MIT License

---

## 1. Overview

In the rapidly evolving landscape of Decentralized Finance (DeFi), malicious actors often employ sophisticated strategies such as **wash trading**, **pump-and-dump schemes**, and **sybil attacks** to manipulate markets. SentinelShield acts as a decentralized "immune system."

By leveraging on-chain behavioral analysis, I have created a framework where trading patterns are not just recorded, but analyzed against historical data and weighted features. The contract provides DEX operators and DAO governors with the tools to identify, flag, and mitigate fraudulent activity before it impacts the broader liquidity pool.

## 2. Key Features

* **Multi-Factor Risk Scoring:** I implemented a weighted calculation engine that balances historical reputation, volume anomalies, and frequency spikes.
* **Dynamic Feature Weighting:** The contract owner can adjust the "AI model weights" on-the-fly to adapt to new market manipulation techniques without redeploying the contract.
* **Automated Alert Generation:** If a trade's risk score exceeds the critical threshold, the system autonomously triggers a fraud alert.
* **Reputation Management:** Traders maintain a `reputation-score`. Confirmed fraudulent activity results in automatic reputation slashing and potential blacklisting.
* **Anomaly Windowing:** Tracks trading behavior within specific time windows to detect rapid-fire manipulation attempts.

## 3. Architecture

SentinelShield operates through three primary layers:

* **Data Layer:** I utilize specialized data maps (`trader-profiles`, `fraud-alerts`, `ai-model-weights`) to store the persistent state of the system.
* **Analytical Layer:** This layer consists of internal logic that processes raw inputs (volume, frequency, volatility) and applies the current model weights to produce a normalized score.
* **Execution Layer:** Public-facing functions that allow for trader registration, pattern analysis, and alert resolution.

## 4. Technical Specification

### Constants & Error Codes

| Constant | Value | Description |
| --- | --- | --- |
| `contract-owner` | `tx-sender` | The deployer/admin of the system. |
| `risk-critical` | `u90` | Threshold for immediate automated alerts. |
| `alert-confirmed` | `u3` | Status indicating verified fraudulent activity. |
| `err-owner-only` | `u100` | Authorization failure for admin-only actions. |
| `err-not-found` | `u101` | Data retrieval failure for missing profiles. |

---

## 5. Detailed Function Analysis

I have structured the logic of SentinelShield to separate internal calculations from external state changes, ensuring a secure and modular execution environment.

### Private Functions (Internal Logic)

These functions are the "brain" of the AI system. They are not callable by external users, which prevents manipulation of the risk-scoring logic.

* **`calculate-weighted-risk`**: This is the core mathematical engine. It applies a weighted average to three inputs: base score, volume, and frequency. I have hard-coded weights (50/30/20) to ensure a balanced assessment where historical behavior (Base) is weighted most heavily.
* **`get-risk-level`**: A helper function that maps numeric 0-100 scores to human-readable strings ("low", "medium", "high", "critical"). This facilitates easier integration for frontend dashboards.
* **`update-trader-reputation`**: Handles the logic for "slashing" a trader's reputation score. It ensures that reputation cannot drop below zero and is only triggered when a fraud alert is officially confirmed.
* **`exceeds-threshold`**: A simple boolean check that compares a current risk score against the globally defined `fraud-threshold`.

### Public Functions (Interface)

These functions allow authorized users and the AI engine to interact with the blockchain state.

* **`register-trader`**: Initializes a new profile. I included this to prevent "ghost trading" and to ensure every participant has a baseline reputation of 100.
* **`set-ai-model-weight`**: This gives the system its "AI-driven" flexibility. The administrator can enable or disable specific features (like volatility tracking) and assign them weights, allowing the system to evolve as new fraud tactics emerge.
* **`analyze-trading-pattern-with-ai`**: The most complex function in the contract. I designed it to perform real-time calculation of volume and frequency anomalies. If it detects a critical risk pattern, it autonomously triggers the `generate-fraud-alert` function within the same transaction.
* **`update-alert-status`**: Used by the contract owner to move an alert from "pending" to "confirmed" or "dismissed." This human-in-the-loop oversight ensures that the AI's "confirmed" flags are verified before permanent penalties (like blacklisting) are applied.
* **`blacklist-trader`**: The ultimate administrative action. Once a trader is blacklisted, their `is-blacklisted` flag is set to true, which DEXs can use to gate-keep their liquidity pools.

---

## 6. Security & Risk Levels

I have categorized risk into four distinct tiers to allow for nuanced responses:

1. **Low (0-24):** Standard trading activity.
2. **Medium (25-49):** Slight deviations from historical norms; monitored.
3. **High (50-74):** Significant anomalies; flagged for review.
4. **Critical (75-100):** Likely manipulation; triggers `generate-fraud-alert`.

## 7. Installation & Deployment

1. **Clone the Repository:**
```bash
git clone https://github.com/your-repo/SentinelShield.git
cd SentinelShield

```


2. **Check Contract Validity:**
```bash
clarinet check

```


3. **Deploy to Testnet:**
```bash
clarinet deploy --testnet

```



## 8. Contribution Guidelines

I welcome contributions from the community to improve the AI detection logic. Please follow the standard fork-and-pull-request workflow. Ensure all new logic includes corresponding unit tests in Clarinet.

## 9. Roadmap

* **Phase 1:** Integration with Stacks Oracle for real-time price volatility feeds.
* **Phase 2:** Implementation of DAO-based governance for weight adjustments.
* **Phase 3:** Off-chain ML model training to export weights back to the Clarity contract.

---

## 10. MIT License

Copyright (c) 2026 SentinelShield Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

