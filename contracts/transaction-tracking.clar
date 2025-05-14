;; Transaction Tracking Contract
;; Records purchasing patterns

;; Map to store transaction records
(define-map transactions uint
  {
    consumer: principal,
    retailer: principal,
    amount: uint,
    timestamp: uint,
    category: (string-ascii 50)
  }
)

;; Counter for transaction IDs
(define-data-var transaction-counter uint u0)

;; Public function to record a transaction
(define-public (record-transaction
  (retailer principal)
  (amount uint)
  (category (string-ascii 50)))
  (let
    (
      (tx-id (var-get transaction-counter))
      (consumer tx-sender)
    )
    ;; Record the transaction
    (var-set transaction-counter (+ tx-id u1))

    (ok (map-set transactions tx-id
      {
        consumer: consumer,
        retailer: retailer,
        amount: amount,
        timestamp: block-height,
        category: category
      }
    ))
  )
)

;; Read-only function to get transaction details
(define-read-only (get-transaction (tx-id uint))
  (map-get? transactions tx-id)
)

;; Read-only function to get transaction count
(define-read-only (get-transaction-count)
  (var-get transaction-counter)
)
