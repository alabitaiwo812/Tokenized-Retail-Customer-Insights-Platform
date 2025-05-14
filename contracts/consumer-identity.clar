;; Consumer Identity Contract
;; Manages shopper profiles

;; Map to store consumer profiles
(define-map consumer-profiles principal
  {
    registered: bool,
    registration-date: uint,
    share-purchase-history: bool,
    share-demographics: bool,
    share-preferences: bool
  }
)

;; Public function for consumers to register
(define-public (register-consumer)
  (ok (map-set consumer-profiles tx-sender
    {
      registered: true,
      registration-date: block-height,
      share-purchase-history: false,
      share-demographics: false,
      share-preferences: false
    }
  ))
)

;; Public function for consumers to update data sharing preferences
(define-public (update-data-sharing-preferences
  (share-purchase-history bool)
  (share-demographics bool)
  (share-preferences bool))
  (let ((profile (unwrap! (map-get? consumer-profiles tx-sender) (err u200))))
    (ok (map-set consumer-profiles tx-sender
      (merge profile {
        share-purchase-history: share-purchase-history,
        share-demographics: share-demographics,
        share-preferences: share-preferences
      })
    ))
  )
)

;; Public function for consumers to deregister
(define-public (deregister-consumer)
  (begin
    (asserts! (is-some (map-get? consumer-profiles tx-sender)) (err u201))
    (ok (map-delete consumer-profiles tx-sender))
  )
)

;; Read-only function to check if a consumer is registered
(define-read-only (is-registered-consumer (consumer principal))
  (default-to false (get registered (map-get? consumer-profiles consumer)))
)

;; Read-only function to get consumer profile
(define-read-only (get-consumer-profile (consumer principal))
  (map-get? consumer-profiles consumer)
)

;; Read-only function to check data sharing consent
(define-read-only (has-sharing-consent (consumer principal) (data-type (string-ascii 16)))
  (let ((profile (default-to
    {
      registered: false,
      registration-date: u0,
      share-purchase-history: false,
      share-demographics: false,
      share-preferences: false
    }
    (map-get? consumer-profiles consumer))))
    (if (is-eq data-type "purchase")
      (get share-purchase-history profile)
      (if (is-eq data-type "demographics")
        (get share-demographics profile)
        (if (is-eq data-type "preferences")
          (get share-preferences profile)
          false
        )
      )
    )
  )
)
