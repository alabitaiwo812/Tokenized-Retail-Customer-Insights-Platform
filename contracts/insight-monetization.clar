;; Insight Monetization Contract
;; Manages data sharing compensation

;; Define the token
(define-fungible-token insight-token)

;; Map to store data access purchases
(define-map data-access-purchases uint
  {
    retailer: principal,
    consumer: principal,
    token-amount: uint,
    access-type: (string-ascii 16),
    expiration: uint,
    active: bool
  }
)

;; Counter for data access purchase IDs
(define-data-var purchase-counter uint u0)

;; Public function for retailers to purchase data access
(define-public (purchase-data-access
  (consumer principal)
  (token-amount uint)
  (access-type (string-ascii 16))
  (duration uint))
  (let
    (
      (retailer tx-sender)
      (purchase-id (var-get purchase-counter))
    )
    ;; Transfer tokens from retailer to consumer
    (try! (ft-transfer? insight-token token-amount retailer consumer))

    ;; Record the purchase
    (var-set purchase-counter (+ purchase-id u1))

    (ok (map-set data-access-purchases purchase-id
      {
        retailer: retailer,
        consumer: consumer,
        token-amount: token-amount,
        access-type: access-type,
        expiration: (+ block-height duration),
        active: true
      }
    ))
  )
)

;; Public function to mint tokens (for demo purposes)
(define-public (mint-tokens (amount uint) (recipient principal))
  (ok (ft-mint? insight-token amount recipient))
)

;; Public function to revoke data access
(define-public (revoke-data-access (purchase-id uint))
  (let ((purchase (unwrap! (map-get? data-access-purchases purchase-id) (err u503))))
    (asserts! (is-eq (get consumer purchase) tx-sender) (err u504))
    (asserts! (get active purchase) (err u505))

    (ok (map-set data-access-purchases purchase-id
      (merge purchase { active: false })
    ))
  )
)

;; Read-only function to get data access purchase details
(define-read-only (get-data-access-purchase (purchase-id uint))
  (map-get? data-access-purchases purchase-id)
)
