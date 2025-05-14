;; Retailer Verification Contract
;; Validates merchants on the platform

(define-data-var admin principal tx-sender)

;; Map to store verified retailers
(define-map verified-retailers principal
  {
    name: (string-ascii 100),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to verify a retailer (admin only)
(define-public (verify-retailer (retailer principal) (name (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-retailers retailer
      {
        name: name,
        verified: true,
        verification-date: block-height
      }
    ))
  )
)

;; Public function to revoke verification (admin only)
(define-public (revoke-verification (retailer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (let ((retailer-data (unwrap! (map-get? verified-retailers retailer) (err u101))))
      (ok (map-set verified-retailers retailer
        (merge retailer-data { verified: false })
      ))
    )
  )
)

;; Read-only function to check if a retailer is verified
(define-read-only (is-verified-retailer (retailer principal))
  (default-to false (get verified (map-get? verified-retailers retailer)))
)

;; Read-only function to get retailer details
(define-read-only (get-retailer-details (retailer principal))
  (map-get? verified-retailers retailer)
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
