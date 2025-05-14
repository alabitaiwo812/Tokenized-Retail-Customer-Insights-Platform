;; Preference Analysis Contract
;; Identifies consumer interests

;; Map to store consumer preferences
(define-map consumer-preferences principal
  {
    category: (string-ascii 50),
    weight: uint,
    last-updated: uint
  }
)

;; Public function to update consumer preference
(define-public (update-preference (category (string-ascii 50)) (weight uint))
  (ok (map-set consumer-preferences tx-sender
    {
      category: category,
      weight: weight,
      last-updated: block-height
    }
  ))
)

;; Read-only function to get consumer preference
(define-read-only (get-consumer-preference (consumer principal))
  (map-get? consumer-preferences consumer)
)
