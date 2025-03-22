;; Design Sharing Contract
;; Facilitates exchange of successful adaptations

(define-data-var last-design-id uint u0)

(define-map shared-designs
  { design-id: uint }
  {
    customization-id: uint,
    title: (string-utf8 100),
    description: (string-utf8 500),
    design-files-hash: (string-utf8 64),
    license-type: (string-utf8 50),
    share-date: uint,
    designer: principal
  }
)

(define-map design-ratings
  { design-id: uint, rater: principal }
  { rating: uint }
)

(define-map design-average-rating
  { design-id: uint }
  {
    total-rating: uint,
    rating-count: uint,
    average-rating: uint
  }
)

(define-public (share-design
                (customization-id uint)
                (title (string-utf8 100))
                (description (string-utf8 500))
                (design-files-hash (string-utf8 64))
                (license-type (string-utf8 50)))
  (let ((new-id (+ (var-get last-design-id) u1)))
    (begin
      (var-set last-design-id new-id)
      (map-set shared-designs
        { design-id: new-id }
        {
          customization-id: customization-id,
          title: title,
          description: description,
          design-files-hash: design-files-hash,
          license-type: license-type,
          share-date: block-height,
          designer: tx-sender
        }
      )
      (map-set design-average-rating
        { design-id: new-id }
        {
          total-rating: u0,
          rating-count: u0,
          average-rating: u0
        }
      )
      (ok new-id)
    )
  )
)

(define-public (rate-design (design-id uint) (rating uint))
  (begin
    (asserts! (< rating u6) (err u1)) ;; Rating must be between 0 and 5

    (let ((current-rating (default-to { rating: u0 } (map-get? design-ratings { design-id: design-id, rater: tx-sender })))
          (avg-rating (default-to { total-rating: u0, rating-count: u0, average-rating: u0 }
                                  (map-get? design-average-rating { design-id: design-id }))))

      (map-set design-ratings
        { design-id: design-id, rater: tx-sender }
        { rating: rating }
      )

      (let ((new-total (+ (get total-rating avg-rating) rating))
            (new-count (+ (get rating-count avg-rating) u1))
            (new-avg (/ new-total new-count)))

        (map-set design-average-rating
          { design-id: design-id }
          {
            total-rating: new-total,
            rating-count: new-count,
            average-rating: new-avg
          }
        )
        (ok true)
      )
    )
  )
)

(define-read-only (get-design (design-id uint))
  (map-get? shared-designs { design-id: design-id })
)

(define-read-only (get-design-rating (design-id uint))
  (map-get? design-average-rating { design-id: design-id })
)
