;; AI-Driven Fraud Alert System for DEXs

;; This contract implements an AI-driven fraud detection system for decentralized exchanges.
;; It monitors trading patterns, detects anomalies, and generates fraud alerts based on
;; machine learning risk scores. The system tracks suspicious behaviors such as wash trading,
;; price manipulation, and abnormal trading volumes to protect DEX users.

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-threshold-exceeded (err u105))

;; Risk level thresholds for fraud detection
(define-constant risk-low u25)
(define-constant risk-medium u50)
(define-constant risk-high u75)
(define-constant risk-critical u90)

;; Alert status codes
(define-constant alert-pending u1)
(define-constant alert-investigating u2)
(define-constant alert-confirmed u3)
(define-constant alert-dismissed u4)

;; data maps and vars

;; Stores fraud alerts with detailed information
(define-map fraud-alerts
    { alert-id: uint }
    {
        trader: principal,
        risk-score: uint,
        alert-type: (string-ascii 50),
        timestamp: uint,
        status: uint,
        trade-volume: uint,
        flagged-by-ai: bool
    }
)

;; Tracks trader risk profiles and historical behavior
(define-map trader-profiles
    { trader: principal }
    {
        total-trades: uint,
        flagged-count: uint,
        risk-score: uint,
        last-trade-time: uint,
        is-blacklisted: bool,
        reputation-score: uint
    }
)

;; Stores AI model parameters for fraud detection
(define-map ai-model-weights
    { feature-id: uint }
    {
        weight: uint,
        feature-name: (string-ascii 50),
        enabled: bool
    }
)

;; Trading pattern anomalies detected by AI
(define-map trading-anomalies
    { trader: principal, window-id: uint }
    {
        avg-trade-size: uint,
        trade-frequency: uint,
        volatility-score: uint,
        anomaly-detected: bool
    }
)

;; Counter for alert IDs
(define-data-var alert-counter uint u0)

;; System configuration
(define-data-var fraud-threshold uint u75)
(define-data-var system-active bool true)
(define-data-var total-alerts-generated uint u0)

;; private functions

;; Calculate weighted risk score based on multiple factors
;; @param base-score: Initial risk score from trade analysis
;; @param volume-factor: Trading volume impact on risk
;; @param frequency-factor: Trading frequency impact on risk
;; @returns: Calculated weighted risk score (0-100)
(define-private (calculate-weighted-risk (base-score uint) (volume-factor uint) (frequency-factor uint))
    (let
        (
            (volume-weight u30)
            (frequency-weight u20)
            (base-weight u50)
            (weighted-sum (+ 
                (* base-score base-weight)
                (* volume-factor volume-weight)
                (* frequency-factor frequency-weight)
            ))
        )
        (/ weighted-sum u100)
    )
)

;; Determine risk level category from numeric score
;; @param score: Risk score to categorize (0-100)
;; @returns: String representation of risk level
(define-private (get-risk-level (score uint))
    (if (>= score risk-critical)
        "critical"
        (if (>= score risk-high)
            "high"
            (if (>= score risk-medium)
                "medium"
                "low"
            )
        )
    )
)

;; Update trader reputation based on alert resolution
;; @param trader: Principal of the trader
;; @param penalty: Reputation points to deduct (if confirmed fraud)
;; @returns: Boolean indicating successful update
(define-private (update-trader-reputation (trader principal) (penalty uint))
    (match (map-get? trader-profiles { trader: trader })
        profile
        (begin
            (map-set trader-profiles
                { trader: trader }
                (merge profile {
                    reputation-score: (if (> (get reputation-score profile) penalty)
                        (- (get reputation-score profile) penalty)
                        u0
                    )
                })
            )
            true
        )
        false
    )
)

;; Check if trader's behavior exceeds fraud threshold
;; @param risk-score: Current risk score of the trader
;; @returns: Boolean indicating if threshold is exceeded
(define-private (exceeds-threshold (risk-score uint))
    (>= risk-score (var-get fraud-threshold))
)

;; public functions

;; Initialize a new trader profile in the system
;; @param trader: Principal of the trader to register
;; @returns: Response indicating success or error
(define-public (register-trader (trader principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (map-get? trader-profiles { trader: trader })) err-already-exists)
        (ok (map-set trader-profiles
            { trader: trader }
            {
                total-trades: u0,
                flagged-count: u0,
                risk-score: u0,
                last-trade-time: u0,
                is-blacklisted: false,
                reputation-score: u100
            }
        ))
    )
)

;; Configure AI model feature weights for fraud detection
;; @param feature-id: Unique identifier for the feature
;; @param weight: Weight value for the feature (0-100)
;; @param feature-name: Descriptive name of the feature
;; @returns: Response indicating success or error
(define-public (set-ai-model-weight (feature-id uint) (weight uint) (feature-name (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= weight u100) err-invalid-input)
        (ok (map-set ai-model-weights
            { feature-id: feature-id }
            {
                weight: weight,
                feature-name: feature-name,
                enabled: true
            }
        ))
    )
)

;; Generate a fraud alert based on AI analysis
;; @param trader: Principal of the trader being flagged
;; @param risk-score: Calculated risk score (0-100)
;; @param alert-type: Type of fraud detected
;; @param trade-volume: Volume of suspicious trade
;; @returns: Response with alert ID or error
(define-public (generate-fraud-alert 
    (trader principal) 
    (risk-score uint) 
    (alert-type (string-ascii 50)) 
    (trade-volume uint))
    (let
        (
            (new-alert-id (+ (var-get alert-counter) u1))
        )
        (asserts! (var-get system-active) err-unauthorized)
        (asserts! (<= risk-score u100) err-invalid-input)
        (asserts! (exceeds-threshold risk-score) err-threshold-exceeded)
        
        ;; Create the fraud alert
        (map-set fraud-alerts
            { alert-id: new-alert-id }
            {
                trader: trader,
                risk-score: risk-score,
                alert-type: alert-type,
                timestamp: block-height,
                status: alert-pending,
                trade-volume: trade-volume,
                flagged-by-ai: true
            }
        )
        
        ;; Update trader profile
        (match (map-get? trader-profiles { trader: trader })
            profile
            (map-set trader-profiles
                { trader: trader }
                (merge profile {
                    flagged-count: (+ (get flagged-count profile) u1),
                    risk-score: risk-score
                })
            )
            false
        )
        
        ;; Update counters
        (var-set alert-counter new-alert-id)
        (var-set total-alerts-generated (+ (var-get total-alerts-generated) u1))
        
        (ok new-alert-id)
    )
)

;; Update the status of an existing fraud alert
;; @param alert-id: ID of the alert to update
;; @param new-status: New status code for the alert
;; @returns: Response indicating success or error
(define-public (update-alert-status (alert-id uint) (new-status uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (match (map-get? fraud-alerts { alert-id: alert-id })
            alert
            (begin
                (map-set fraud-alerts
                    { alert-id: alert-id }
                    (merge alert { status: new-status })
                )
                
                ;; If confirmed fraud, apply reputation penalty
                (if (is-eq new-status alert-confirmed)
                    (update-trader-reputation (get trader alert) u20)
                    true
                )
                
                (ok true)
            )
            err-not-found
        )
    )
)

;; Blacklist a trader based on confirmed fraud
;; @param trader: Principal of the trader to blacklist
;; @returns: Response indicating success or error
(define-public (blacklist-trader (trader principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (match (map-get? trader-profiles { trader: trader })
            profile
            (ok (map-set trader-profiles
                { trader: trader }
                (merge profile { is-blacklisted: true })
            ))
            err-not-found
        )
    )
)


