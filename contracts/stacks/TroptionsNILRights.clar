;; SPDX-License-Identifier: MIT
;; Troptions-NIL-Rights.clar
;; Senior-grade Clarity contract for Stacks sBTC / NIL rights settlement.
;; Integrates with BridgePayload concept via lps1-hash and asset-id for cross-rail with EVM cores.

(define-data-var contract-owner principal tx-sender)

(define-map nil-claims 
  { asset-id: (buff 32) }
  { athlete: principal, amount: uint, lps1-hash: (buff 32), claimed: bool, payload-data: (optional (buff 32)) }
)

(define-public (mint-nil (asset-id (buff 32)) (athlete principal) (amount uint) (lps1-hash (buff 32)) (payload-data (optional (buff 32))))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (is-none (map-get? nil-claims { asset-id: asset-id })) (err u409))
    
    (map-set nil-claims 
      { asset-id: asset-id }
      { athlete: athlete, amount: amount, lps1-hash: lps1-hash, claimed: false, payload-data: payload-data })
    
    (ok true)
  )
)

(define-public (claim-payout (asset-id (buff 32)))
  (let ((claim (unwrap! (map-get? nil-claims { asset-id: asset-id }) (err u404))))
    (asserts! (is-eq (get athlete claim) tx-sender) (err u403))
    (asserts! (not (get claimed claim)) (err u409))
    
    (map-set nil-claims 
      { asset-id: asset-id }
      (merge claim { claimed: true }))
    
    (ok (get amount claim))
  )
)

(define-read-only (get-claim (asset-id (buff 32)))
  (map-get? nil-claims { asset-id: asset-id })
)
