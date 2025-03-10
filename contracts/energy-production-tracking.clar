;; Energy Production Tracking Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))

;; Data Maps
(define-map producers principal { name: (string-ascii 50), energy-type: (string-ascii 20) })
(define-map energy-production principal { total-energy: uint, last-updated: uint })

;; Public Functions
(define-public (register-producer (name (string-ascii 50)) (energy-type (string-ascii 20)))
  (if (is-producer tx-sender)
    err-already-registered
    (ok (map-set producers tx-sender { name: name, energy-type: energy-type }))))

(define-public (record-energy-production (amount uint))
  (let ((current-production (default-to { total-energy: u0, last-updated: u0 } (map-get? energy-production tx-sender))))
    (if (is-producer tx-sender)
      (ok (map-set energy-production tx-sender
        { total-energy: (+ (get total-energy current-production) amount),
          last-updated: block-height }))
      err-not-registered)))

;; Read-only Functions
(define-read-only (get-producer-info (producer principal))
  (map-get? producers producer))

(define-read-only (get-energy-production (producer principal))
  (map-get? energy-production producer))

(define-read-only (is-producer (address principal))
  (is-some (map-get? producers address)))

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner))

