;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname exercise121-intermezzo01) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp")) #f)))
; exercise121-intermezzo01

; Q.:
; Evaluate the following expressions step-by-step
; Use DrRacket’s stepper to confirm your computations.



; 1.

; (+ (* (/ 12 8) 2/3)
;    (- 20 (sqrt 4)))

; ==

; (+ (* 3/2 2/3)
;    (- 20 (sqrt 4)))

; ==

; (+  1
;    (- 20 (sqrt 4)))

; ==

; (+  1
;    (- 20 2))

; ==

; (+ 1 18)

; ==

; 19



; 2.

; (cond
;  [(= 0 0) #false]
;  [(> 0 1) (string=? "a" "a")]
;  [else (= (/  1 0) 9)])

; ==

; (cond
;  [#true #false]
;  [(> 0 1) (string=? "a" "a")]
;  [else (= (/  1 0) 9)])

; ==

; #false



; 3.

; (cond
;  [(= 2 0) #false]
;  [(> 2 1) (string=? "a" "a")]
;  [else (= (/  1 2) 9)])

; ==

; (cond
;  [#false #false]
;  [(> 2 1) (string=? "a" "a")]
;  [else (= (/  1 2) 9)])

; ==

; (cond
;  [(> 2 1) (string=? "a" "a")]
;  [else (= (/  1 2) 9)])

; ==

; (cond
;  [#true (string=? "a" "a")]
;  [else (= (/  1 2) 9)])

; ==

; (string=? "a" "a")

; ==

; #true