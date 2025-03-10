;; Grid Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-status (err u101))

;; Data Maps
(define-map grid-status { status: (string-ascii 20), load: uint, last-updated: uint })
(define-map authorized-operators principal bool)

;; Public Functions
(define-public (update-grid-status (status (string-ascii 20)) (load uint))
  (if (is-authorized-operator tx-sender)
    (ok (map-set grid-status 'current
      { status: status, load: load, last-updated: block-height }))
    err-unauthorized))

(define-public (set-operator-authorization (operator principal) (authorized bool))
  (if (is-contract-owner)
    (ok (map-set authorized-operators operator authorized))
    err-unauthorized))

(define-public (implement-emergency-protocol)
  (if (is-authorized-operator tx-sender)
    (ok (map-set grid-status 'current
      { status: "emergency", load: u0, last-updated: block-height }))
    err-unauthorized))

;; Read-only Functions
(define-read-only (get-current-grid-status)
  (map-get? grid-status 'current))

(define-read-only (is-authorized-operator (operator principal))
  (default-to false (map-get? authorized-operators operator)))

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner))

