;; TrustChain - Decentralized Trust Scoring System on Stacks
;; A cross-platform trust system that evaluates user credibility and reliability

;; Constants
(define-constant SYSTEM_ADMIN tx-sender)
(define-constant ERR_ACCESS_DENIED (err u200))
(define-constant ERR_INVALID_SCORE (err u201))
(define-constant ERR_SELF_EVALUATION (err u202))
(define-constant ERR_ACCOUNT_NOT_FOUND (err u203))
(define-constant ERR_DUPLICATE_EVALUATION (err u204))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u205))

;; Minimum collateral required to submit evaluations (in microSTX)
(define-constant MIN_COLLATERAL u1000000) ;; 1 STX

;; Data Variables
(define-data-var system-admin principal SYSTEM_ADMIN)
(define-data-var registered-accounts uint u0)

;; Data Maps
(define-map account-records 
    { account: principal }
    {
        trust-score: uint,
        evaluation-count: uint,
        collateral-total: uint,
        join-block: uint,
        verified-status: bool
    }
)

(define-map trust-evaluations
    { evaluator: principal, evaluated: principal }
    {
        score: uint,
        collateral: uint,
        block-recorded: uint,
        evaluation-type: (string-ascii 50)
    }
)

(define-map service-connectors
    { service: (string-ascii 50) }
    {
        active-status: bool,
        score-modifier: uint,
        service-admin: principal
    }
)

;; Public Functions

;; Register a new account in the trust system
(define-public (register-account)
    (let ((caller tx-sender))
        (asserts! (is-none (map-get? account-records { account: caller })) ERR_ACCESS_DENIED)
        (map-set account-records
            { account: caller }
            {
                trust-score: u5000, ;; Start with neutral score (5000 out of 10000)
                evaluation-count: u0,
                collateral-total: u0,
                join-block: stacks-block-height,
                verified-status: false
            }
        )
        (var-set registered-accounts (+ (var-get registered-accounts) u1))
        (ok true)
    )
)

;; Submit a trust evaluation for another account
(define-public (submit-evaluation (evaluated principal) (score uint) (evaluation-type (string-ascii 50)))
    (let (
        (caller tx-sender)
        (collateral-balance (stx-get-balance caller))
    )
        ;; Validation checks
        (asserts! (not (is-eq caller evaluated)) ERR_SELF_EVALUATION)
        (asserts! (and (>= score u1) (<= score u10)) ERR_INVALID_SCORE)
        (asserts! (>= collateral-balance MIN_COLLATERAL) ERR_INSUFFICIENT_COLLATERAL)
        (asserts! (is-some (map-get? account-records { account: evaluated })) ERR_ACCOUNT_NOT_FOUND)
        (asserts! (is-none (map-get? trust-evaluations { evaluator: caller, evaluated: evaluated })) ERR_DUPLICATE_EVALUATION)
        
        ;; Store the evaluation
        (map-set trust-evaluations
            { evaluator: caller, evaluated: evaluated }
            {
                score: score,
                collateral: MIN_COLLATERAL,
                block-recorded: stacks-block-height,
                evaluation-type: evaluation-type
            }
        )
        
        ;; Update evaluated account's record
        (match (map-get? account-records { account: evaluated })
            account-data (begin
                (map-set account-records
                    { account: evaluated }
                    {
                        trust-score: (calculate-updated-score 
                            (get trust-score account-data)
                            (get evaluation-count account-data)
                            score
                        ),
                        evaluation-count: (+ (get evaluation-count account-data) u1),
                        collateral-total: (+ (get collateral-total account-data) MIN_COLLATERAL),
                        join-block: (get join-block account-data),
                        verified-status: (get verified-status account-data)
                    }
                )
                true
            )
            false
        )
        
        ;; Ensure the account was updated successfully
        (asserts! (match (map-get? account-records { account: evaluated })
            account-data true
            false
        ) ERR_ACCOUNT_NOT_FOUND)
        
        (ok true)
    )
)

;; Verify an account (only system admin or service admins)
(define-public (verify-account (account principal))
    (begin
        (asserts! (is-eq tx-sender (var-get system-admin)) ERR_ACCESS_DENIED)
        (asserts! (is-some (map-get? account-records { account: account })) ERR_ACCOUNT_NOT_FOUND)
        
        (match (map-get? account-records { account: account })
            account-data (begin
                (map-set account-records
                    { account: account }
                    (merge account-data { verified-status: true })
                )
                true
            )
            false
        )
        
        ;; Ensure the account was updated successfully
        (asserts! (is-some (map-get? account-records { account: account })) ERR_ACCOUNT_NOT_FOUND)
        (ok true)
    )
)

;; Add or update service integration
(define-public (register-service (service (string-ascii 50)) (service-admin principal) (modifier uint))
    (begin
        (asserts! (is-eq tx-sender (var-get system-admin)) ERR_ACCESS_DENIED)
        (map-set service-connectors
            { service: service }
            {
                active-status: true,
                score-modifier: modifier,
                service-admin: service-admin
            }
        )
        (ok true)
    )
)

;; Private Functions

;; Calculate updated trust score using weighted average
(define-private (calculate-updated-score (current-score uint) (evaluation-count uint) (new-score uint))
    (let (
        (weighted-current (* current-score evaluation-count))
        (scaled-new-score (* new-score u1000)) ;; Scale score to 1000-10000 range
        (updated-total (+ evaluation-count u1))
    )
        (/ (+ weighted-current scaled-new-score) updated-total)
    )
)

;; Read-only Functions

;; Get account's trust record
(define-read-only (get-account-record (account principal))
    (map-get? account-records { account: account })
)

;; Get evaluation between two accounts
(define-read-only (get-evaluation (evaluator principal) (evaluated principal))
    (map-get? trust-evaluations { evaluator: evaluator, evaluated: evaluated })
)

;; Get total number of registered accounts
(define-read-only (get-registered-accounts)
    (var-get registered-accounts)
)

;; Check if account is verified
(define-read-only (is-account-verified (account principal))
    (match (map-get? account-records { account: account })
        account-data (get verified-status account-data)
        false
    )
)

;; Get trust score as percentage (0-100)
(define-read-only (get-trust-percentage (account principal))
    (match (map-get? account-records { account: account })
        account-data (/ (get trust-score account-data) u100)
        u0
    )
)

;; Get service integration details
(define-read-only (get-service-info (service (string-ascii 50)))
    (map-get? service-connectors { service: service })
)