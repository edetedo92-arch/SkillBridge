;; credential-validator.clar
;; Validates instructor qualifications and student achievements
;; Issues immutable certification records upon course completion

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-found (err u201))
(define-constant err-unauthorized (err u202))
(define-constant err-already-verified (err u203))
(define-constant err-not-verified (err u204))
(define-constant err-invalid-score (err u205))
(define-constant err-already-certified (err u206))
(define-constant err-milestone-exists (err u207))

;; Maximum reputation score
(define-constant max-reputation u10000)

;; Data variables
(define-data-var credential-nonce uint u0)
(define-data-var milestone-nonce uint u0)

;; Data maps
(define-map instructor-credentials
  { instructor: principal }
  {
    verified: bool,
    qualification: (string-ascii 200),
    reputation-score: uint,
    courses-completed: uint,
    verification-date: uint
  }
)

(define-map student-certifications
  { student: principal, course-id: uint }
  {
    instructor: principal,
    completed: bool,
    certification-date: uint,
    course-name: (string-ascii 100),
    final-score: uint
  }
)

(define-map course-milestones
  { milestone-id: uint }
  {
    student: principal,
    course-id: uint,
    milestone-name: (string-ascii 100),
    completed: bool,
    completion-date: uint
  }
)

(define-map instructor-verifiers principal bool)

;; Read-only functions
(define-read-only (get-instructor-credential (instructor principal))
  (map-get? instructor-credentials { instructor: instructor })
)

(define-read-only (is-instructor-verified (instructor principal))
  (match (map-get? instructor-credentials { instructor: instructor })
    credential (get verified credential)
    false
  )
)

(define-read-only (get-instructor-reputation (instructor principal))
  (match (map-get? instructor-credentials { instructor: instructor })
    credential (get reputation-score credential)
    u0
  )
)

(define-read-only (get-student-certification (student principal) (course-id uint))
  (map-get? student-certifications { student: student, course-id: course-id })
)

(define-read-only (is-student-certified (student principal) (course-id uint))
  (match (map-get? student-certifications { student: student, course-id: course-id })
    cert (get completed cert)
    false
  )
)

(define-read-only (get-milestone (milestone-id uint))
  (map-get? course-milestones { milestone-id: milestone-id })
)

(define-read-only (is-verifier (address principal))
  (default-to false (map-get? instructor-verifiers address))
)

;; Public functions
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set instructor-verifiers verifier true))
  )
)

(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete instructor-verifiers verifier))
  )
)

(define-public (verify-instructor (instructor principal) (qualification (string-ascii 200)))
  (let
    (
      (existing (map-get? instructor-credentials { instructor: instructor }))
    )
    (asserts! (or (is-eq tx-sender contract-owner) (is-verifier tx-sender)) err-unauthorized)
    (asserts! (is-none existing) err-already-verified)
    (ok (map-set instructor-credentials
      { instructor: instructor }
      {
        verified: true,
        qualification: qualification,
        reputation-score: u5000,
        courses-completed: u0,
        verification-date: stacks-block-height
      }
    ))
  )
)

(define-public (update-instructor-reputation (instructor principal) (new-score uint))
  (let
    (
      (credential (unwrap! (map-get? instructor-credentials { instructor: instructor }) err-not-found))
    )
    (asserts! (or (is-eq tx-sender contract-owner) (is-verifier tx-sender)) err-unauthorized)
    (asserts! (<= new-score max-reputation) err-invalid-score)
    (ok (map-set instructor-credentials
      { instructor: instructor }
      (merge credential { reputation-score: new-score })
    ))
  )
)

(define-public (record-milestone (student principal) (course-id uint) (milestone-name (string-ascii 100)))
  (let
    (
      (milestone-id (var-get milestone-nonce))
      (instructor tx-sender)
    )
    (asserts! (is-instructor-verified instructor) err-not-verified)
    (map-set course-milestones
      { milestone-id: milestone-id }
      {
        student: student,
        course-id: course-id,
        milestone-name: milestone-name,
        completed: true,
        completion-date: stacks-block-height
      }
    )
    (var-set milestone-nonce (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-public (issue-certification (student principal) (course-id uint) (course-name (string-ascii 100)) (final-score uint))
  (let
    (
      (instructor tx-sender)
      (credential (unwrap! (map-get? instructor-credentials { instructor: instructor }) err-not-verified))
      (existing-cert (map-get? student-certifications { student: student, course-id: course-id }))
    )
    (asserts! (get verified credential) err-not-verified)
    (asserts! (is-none existing-cert) err-already-certified)
    (asserts! (<= final-score u100) err-invalid-score)
    
    (map-set student-certifications
      { student: student, course-id: course-id }
      {
        instructor: instructor,
        completed: true,
        certification-date: stacks-block-height,
        course-name: course-name,
        final-score: final-score
      }
    )
    
    (map-set instructor-credentials
      { instructor: instructor }
      (merge credential { courses-completed: (+ (get courses-completed credential) u1) })
    )
    
    (ok true)
  )
)

(define-public (revoke-instructor-verification (instructor principal))
  (let
    (
      (credential (unwrap! (map-get? instructor-credentials { instructor: instructor }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set instructor-credentials
      { instructor: instructor }
      (merge credential { verified: false })
    ))
  )
)

;; title: credential-validator
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

