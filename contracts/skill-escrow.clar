;; skill-escrow.clar
;; Manages escrow-based payments for skill-sharing courses
;; Holds student payments until verified completion, then releases to instructors minus platform fee

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-already-completed (err u104))
(define-constant err-already-refunded (err u105))
(define-constant err-not-student (err u106))
(define-constant err-not-instructor (err u107))
(define-constant err-insufficient-balance (err u108))

;; Platform fee percentage (5% = 500 basis points)
(define-constant platform-fee-bps u500)
(define-constant bps-denominator u10000)

;; Data variables
(define-data-var escrow-nonce uint u0)
(define-data-var platform-treasury principal contract-owner)

;; Data maps
(define-map escrows
  { escrow-id: uint }
  {
    student: principal,
    instructor: principal,
    amount: uint,
    completed: bool,
    refunded: bool,
    course-name: (string-ascii 100)
  }
)

(define-map instructor-balances principal uint)
(define-map platform-fees-collected principal uint)

;; Read-only functions
(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows { escrow-id: escrow-id })
)

(define-read-only (get-instructor-balance (instructor principal))
  (default-to u0 (map-get? instructor-balances instructor))
)

(define-read-only (get-platform-fees)
  (default-to u0 (map-get? platform-fees-collected (var-get platform-treasury)))
)

(define-read-only (calculate-platform-fee (amount uint))
  (/ (* amount platform-fee-bps) bps-denominator)
)

(define-read-only (calculate-instructor-payout (amount uint))
  (- amount (calculate-platform-fee amount))
)

(define-read-only (get-platform-treasury)
  (ok (var-get platform-treasury))
)

;; Public functions
(define-public (create-escrow (instructor principal) (amount uint) (course-name (string-ascii 100)))
  (let
    (
      (escrow-id (var-get escrow-nonce))
      (student tx-sender)
    )
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount student (as-contract tx-sender)))
    (map-set escrows
      { escrow-id: escrow-id }
      {
        student: student,
        instructor: instructor,
        amount: amount,
        completed: false,
        refunded: false,
        course-name: course-name
      }
    )
    (var-set escrow-nonce (+ escrow-id u1))
    (ok escrow-id)
  )
)

(define-public (complete-course (escrow-id uint))
  (let
    (
      (escrow-data (unwrap! (map-get? escrows { escrow-id: escrow-id }) err-not-found))
      (amount (get amount escrow-data))
      (instructor (get instructor escrow-data))
      (student (get student escrow-data))
      (fee (calculate-platform-fee amount))
      (payout (calculate-instructor-payout amount))
      (treasury (var-get platform-treasury))
      (current-instructor-balance (default-to u0 (map-get? instructor-balances instructor)))
      (current-platform-fees (default-to u0 (map-get? platform-fees-collected treasury)))
    )
    (asserts! (is-eq tx-sender student) err-not-student)
    (asserts! (not (get completed escrow-data)) err-already-completed)
    (asserts! (not (get refunded escrow-data)) err-already-refunded)
    
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow-data { completed: true })
    )
    
    (map-set instructor-balances instructor (+ current-instructor-balance payout))
    (map-set platform-fees-collected treasury (+ current-platform-fees fee))
    
    (ok true)
  )
)

(define-public (withdraw-instructor-balance)
  (let
    (
      (instructor tx-sender)
      (balance (default-to u0 (map-get? instructor-balances instructor)))
    )
    (asserts! (> balance u0) err-insufficient-balance)
    (try! (as-contract (stx-transfer? balance tx-sender instructor)))
    (map-set instructor-balances instructor u0)
    (ok balance)
  )
)

(define-public (refund-escrow (escrow-id uint))
  (let
    (
      (escrow-data (unwrap! (map-get? escrows { escrow-id: escrow-id }) err-not-found))
      (amount (get amount escrow-data))
      (instructor (get instructor escrow-data))
      (student (get student escrow-data))
    )
    (asserts! (or (is-eq tx-sender instructor) (is-eq tx-sender contract-owner)) err-unauthorized)
    (asserts! (not (get completed escrow-data)) err-already-completed)
    (asserts! (not (get refunded escrow-data)) err-already-refunded)
    
    (try! (as-contract (stx-transfer? amount tx-sender student)))
    
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow-data { refunded: true })
    )
    
    (ok true)
  )
)

(define-public (withdraw-platform-fees)
  (let
    (
      (treasury (var-get platform-treasury))
      (fees (default-to u0 (map-get? platform-fees-collected treasury)))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> fees u0) err-insufficient-balance)
    (try! (as-contract (stx-transfer? fees tx-sender treasury)))
    (map-set platform-fees-collected treasury u0)
    (ok fees)
  )
)

(define-public (set-platform-treasury (new-treasury principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set platform-treasury new-treasury)
    (ok true)
  )
)

;; title: skill-escrow
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

