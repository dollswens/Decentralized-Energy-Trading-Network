;; Peer-to-Peer Trading Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-offer (err u101))
(define-constant err-offer-not-found (err u102))
(define-constant err-insufficient-balance (err u103))

;; Data Maps
(define-map energy-offers uint { seller: principal, amount: uint, price: uint, status: (string-ascii 10) })
(define-map energy-balances principal uint)

;; Variables
(define-data-var offer-nonce uint u0)

;; Public Functions
(define-public (create-energy-offer (amount uint) (price uint))
  (let ((offer-id (+ (var-get offer-nonce) u1)))
    (map-set energy-offers offer-id { seller: tx-sender, amount: amount, price: price, status: "active" })
    (var-set offer-nonce offer-id)
    (ok offer-id)))

(define-public (accept-energy-offer (offer-id uint))
  (let ((offer (unwrap! (map-get? energy-offers offer-id) err-offer-not-found)))
    (if (and
          (is-eq (get status offer) "active")
          (>= (default-to u0 (map-get? energy-balances tx-sender)) (get price offer)))
      (begin
        (map-set energy-offers offer-id (merge offer { status: "completed" }))
        (map-set energy-balances tx-sender
          (- (default-to u0 (map-get? energy-balances tx-sender)) (get price offer)))
        (map-set energy-balances (get seller offer)
          (+ (default-to u0 (map-get? energy-balances (get seller offer))) (get price offer)))
        (ok true))
      err-invalid-offer)))

(define-public (cancel-energy-offer (offer-id uint))
  (let ((offer (unwrap! (map-get? energy-offers offer-id) err-offer-not-found)))
    (if (and
          (is-eq (get status offer) "active")
          (is-eq (get seller offer) tx-sender))
      (begin
        (map-set energy-offers offer-id (merge offer { status: "cancelled" }))
        (ok true))
      err-unauthorized)))

;; Read-only Functions
(define-read-only (get-energy-offer (offer-id uint))
  (map-get? energy-offers offer-id))

(define-read-only (get-energy-balance (address principal))
  (default-to u0 (map-get? energy-balances address)))

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner))

