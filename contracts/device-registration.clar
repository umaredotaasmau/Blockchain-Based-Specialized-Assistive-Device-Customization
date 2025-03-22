;; Device Registration Contract
;; Records details of base assistive technologies

(define-data-var last-device-id uint u0)

(define-map devices
  { device-id: uint }
  {
    name: (string-utf8 100),
    manufacturer: (string-utf8 100),
    category: (string-utf8 50),
    base-features: (string-utf8 500),
    registration-date: uint,
    owner: principal
  }
)

(define-public (register-device
                (name (string-utf8 100))
                (manufacturer (string-utf8 100))
                (category (string-utf8 50))
                (base-features (string-utf8 500)))
  (let ((new-id (+ (var-get last-device-id) u1)))
    (begin
      (var-set last-device-id new-id)
      (map-set devices
        { device-id: new-id }
        {
          name: name,
          manufacturer: manufacturer,
          category: category,
          base-features: base-features,
          registration-date: block-height,
          owner: tx-sender
        }
      )
      (ok new-id)
    )
  )
)

(define-read-only (get-device (device-id uint))
  (map-get? devices { device-id: device-id })
)

(define-read-only (get-device-count)
  (var-get last-device-id)
)
