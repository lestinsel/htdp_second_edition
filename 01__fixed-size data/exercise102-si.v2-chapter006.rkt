;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname exercise102-chapter006) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp")) #f)))
; exercise102-chapter006

; Q.:
; Turn the examples in figure 35 into test cases.

(define WIDTH 200)
(define HEIGHT 200)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define UFO (overlay (circle (/ WIDTH 30) "solid" "green") (rectangle (/ WIDTH 10) (/ WIDTH 100) "solid" "green")))
(define WIN-UFO (overlay (circle (/ WIDTH 30) "solid" "red") (rectangle (/ WIDTH 10) (/ WIDTH 100) "solid" "red")))
(define UFO-LAND-LEVEL (- (- HEIGHT (* (image-height UFO) 0.5 )) 1))
(define UFO-X-VELOCITY 2)
(define UFO-DESCENT-VELOCITY (/ WIDTH 200))
(define RANDOM-LIMIT 2)

(define TANK-HEIGHT (/ HEIGHT 30))
(define TANK-Y-LEVEL (- (- HEIGHT (* TANK-HEIGHT 0.5 )) 1))
(define TANK (rectangle (/ WIDTH 5) TANK-HEIGHT "solid" "blue"))

(define ROCKET (polygon (list (make-posn 0 0)
                 (make-posn (-(/ WIDTH 20)) (/ WIDTH 10))
                 (make-posn 0 (/ WIDTH 15) )
                 (make-posn (/ WIDTH 20) (/ WIDTH 10)))
           "solid"
           "black"))
(define MISSILE-OBJECT-DETECTION-ZONE (/ WIDTH 20))
(define MISSILE-FLIGHT-VELOCITY (- (/ WIDTH 100)))
(define MISSILE-START-Y-LEVEL (- HEIGHT (/ 2 (image-height ROCKET)) (image-height TANK)))

(define FIRE (star 20 "outline" "orange"))

(define TEXT-WIN (text "you win" (/ WIDTH 10) "red"))
(define TEXT-LOSE (text "you lose" (/ WIDTH 10) "red"))

; A UFO is a Posn. 
; interpretation (make-posn x y) is the UFO's location 
; (using the top-down, left-to-right convention)
 
(define-struct tank [loc vel])
; A Tank is a structure:
;   (make-tank Number Number). 
; interpretation (make-tank x dx) specifies the position:
; (x, HEIGHT) and the tank's speed: dx pixels/tick 
 
; A MissileOrNot is one of: 
; – #false
; – Posn
; interpretation#false means the missile is in the tank;
; Posn says the missile is at that location

(define-struct sigs.v2 [ufo tank missile])
; A SIGS.v2 (short for SIGS version 2) is a structure:
;   (make-sigs.v2 UFO Tank MissileOrNot)
; interpretation represents the complete state of a
; space invader game

(define SI1.v2 (make-sigs.v2 (make-posn 25 0) (make-tank 32 3) #false))


(define (main ws)
  (big-bang ws
    [to-draw si-render.v2]
    [on-key si-control.v2]
    [on-tick si-move.v2]
    [stop-when si-game-over?.v2 si-render-final.v2]))


; Functions:

; SIGS -> Image
; adds TANK, UFO, and possibly MISSILE to 
; the BACKGROUND scene
   
(define (si-render.v2 s)
  (tank-render (sigs.v2-tank s)
               (ufo-render (sigs.v2-ufo s)
                           (missile-render.v2 (sigs.v2-missile s)
                                           BACKGROUND))))



;; Missile Image -> Image 
; adds m to the given image im
; nothing if m is #false

;(check-expect (missile-render.v2 (make-posn 25 50) BACKGROUND)
;              (place-image ROCKET 25 50 BACKGROUND))
;
;(check-expect (missile-render.v2 #false BACKGROUND)
;              BACKGROUND)

(define (missile-render.v2 s im)
  (cond
    [(boolean? s) im]
    [(posn? s)
     (place-image ROCKET (posn-x s) (posn-y s) im)]))



; UFO Image -> Image 
; adds u to the given image im

;(check-expect (ufo-render (make-posn 25 30) BACKGROUND) (place-image UFO 25 30 BACKGROUND))

(define (ufo-render s im)
  (place-image UFO (posn-x s) (posn-y s) im))



; Tank Image -> Image 
; adds t to the given image im

;(check-expect (tank-render (make-tank 25 -3) BACKGROUND) (place-image TANK 25  TANK-Y-LEVEL BACKGROUND))

(define (tank-render s im)
  (place-image TANK (tank-loc s) TANK-Y-LEVEL im))



;; func for determine ufo missile hit or ufo landing
;; SIGS.v2 -> Boolean
;; determines the UFO hit by missile or ufo landing
;; and returns #true if it happened 

;(check-expect (si-game-over?.v2 (make-sigs
;                          (make-posn 10 20) (make-tank 28 -3) #false)) #false)
;
;(check-expect (si-game-over?.v2 (make-sigs
;                          (make-posn 10 UFO-LAND-LEVEL) (make-tank 28 -3) #false)) #true)
;
;(check-expect (si-game-over?.v2 (make-sigs
;                          (make-posn 10 UFO-LAND-LEVEL) (make-tank 28 -3) (make-posn 10 40))) #true)
;(check-expect (si-game-over?.v2 (make-sigs
;                          (make-posn 10 50) (make-tank 28 -3) (make-posn 10 40))) #false)
;
;(check-expect (si-game-over?.v2 (make-sigs
;                          (make-posn 10 50) (make-tank 28 -3) (make-posn 10 49))) #true)

(define (si-game-over?.v2 s)
  (cond
    [(ufo-land? (sigs.v2-ufo s)) #true]
    [(boolean? (sigs.v2-missile s)) #false]
    [else (missile-hit?.v2 (sigs.v2-ufo s) (sigs.v2-missile s))]))



;;  func for determine ufo landing
;;  UFO -> Boolean
;;  determines the UFO landing
;;  and returns #true if it happened

;(check-expect (ufo-land? (make-posn 50 0)) #false)
;(check-expect (ufo-land? (make-posn 50 200)) #true)

(define (ufo-land? s-ufo)
  (cond [(>= (posn-y s-ufo) UFO-LAND-LEVEL) #true]
        [else #false]))



;; func for determine ufo missile hit
;; UFO, Missile -> Boolean
;; determines the UFO hit by missile
;; and returns #true if it happened

;(check-expect (missile-hit?.v2 (make-posn 10 20) (make-posn 10 20)) #true)
;(check-expect (missile-hit?.v2 (make-posn 10 20) (make-posn 10 30)) #false)

(define (missile-hit?.v2 s-ufo s-missile)
  (cond [(boolean? s-missile) #false]
        [(<= (sqrt (+ (sqr (- (posn-x s-ufo) (posn-x s-missile)))
                      (sqr (- (posn-y s-ufo) (posn-y s-missile)))))
             MISSILE-OBJECT-DETECTION-ZONE) #true]
        [else #false]))



; we use A SIGS.v2 for interp.
; the complete state of a space invader game
; SIGS.v2, KeyEvent -> SIGS.v2
; func for big-bang for key-event handler
;  it consumes a game state and a KeyEvent
; and produces a new game state. It reacts to three different keys:
; pressing the left arrow ensures that the tank moves left;
; pressing the right arrow ensures that the tank moves right;
; pressing the space bar fires the missile if it hasn’t been launched yet

;(check-expect (si-control.v2 SI1 "right") SI1)
;(check-expect (si-control.v2 SI1 "left") (make-sigs (make-posn 100 100) (make-tank 100 -3) #false))
;(check-expect (si-control.v2 SI1 " ") (make-sigs (make-posn 100 100) (make-tank 100 3) (make-posn 100 MISSILE_START_Y-LEVEL)))
;(check-expect (si-control.v2 (make-sigs (make-posn 100 100) (make-tank 100 3) (make-posn 100 MISSILE_START_Y-LEVEL)) " ")
;              (make-sigs (make-posn 100 100) (make-tank 100 3) (make-posn 100 MISSILE_START_Y-LEVEL)))

(define (si-control.v2 s ke)
  (cond
    [(or (string=? ke "right") (string=? ke "left"))
     (make-sigs.v2
      (sigs.v2-ufo s)
      (si-tank-update-dir-keys (sigs.v2-tank s) ke)
      (sigs.v2-missile s))]
    [(string=? ke " ")
     (make-sigs.v2
      (sigs.v2-ufo s)
      (sigs.v2-tank s)
      (cond [(boolean? (sigs.v2-missile s)) (si-missile-appear.v2 s)]
            [else (sigs.v2-missile s)]))]
    [else s]))



; we use A SIGS.v2 for interp.
; the complete state of a space invader game
; TANK, ke -> TANK
; func for si-control (for aim and dired makers) for
; handle directional key events
; and updates TANK velocity

;(check-expect (si-tank-update-dir-keys (make-tank 100 -3) "left") (make-tank 100 -3))
;(check-expect (si-tank-update-dir-keys (make-tank 100 -3) "right") (make-tank 100 3))
;(check-expect (si-tank-update-dir-keys (make-tank 100 3) "right") (make-tank 100 3))
;(check-expect (si-tank-update-dir-keys (make-tank 100 -3) "right") (make-tank 100 3))

(define (si-tank-update-dir-keys s-tank ke)
  (make-tank
   (tank-loc s-tank)
   (cond
     [(string=? ke "right")
      (cond
        [(>= (tank-vel s-tank) 0)
         (tank-vel s-tank)]
        [else
         (- (tank-vel s-tank))])]
     [(string=? ke "left")
      (cond
        [(>= (tank-vel s-tank) 0)
         (- (tank-vel s-tank))]
        [else
         (tank-vel s-tank)])])))



; we use A SIGS.v2 for interp.
; the complete state of a space invader game
; SIGS -> SIGS
; func for si-control for
; updates SIGS.v2 when a missile appears
; from change missile parameter from boolean to posn

(define (si-missile-appear.v2 s)
  (make-posn (tank-loc (sigs.v2-tank s)) MISSILE-START-Y-LEVEL))



;; func for SIGS parameter changes over time
;; SIGS.v2 -> SIGS.v2
;; this function is called for every clock tick to
;; determine to which position the objects move now
;; consumes an element of SIGS.v2 and produces another one
;; Moving the tank and the missile (if any)
;; in straight lines at a constant speed
;; Moving the UFO calls for small random jumps
;; to the left or the right

(define (si-move.v2 s)
  (make-sigs.v2
   (si-move-ufo (sigs.v2-ufo s))
   (si-move-tank (sigs.v2-tank s))
   (si-move-missile.v2 (sigs.v2-missile s))))



; si-move-ufo
; func for change ufo-type coord parametres per time
; UFO -> UFO
; change ufo x, y position of the vel per time
; x - to the constant change, y - random

;(check-random (si-move-ufo (make-posn 100 100)) (make-posn  (cond [(even? (random RANDOM-LIMIT)) (+ 100 2)] [else (- 100 2)]) 97))
;(check-random (si-move-ufo (make-posn 178 100)) (make-posn   176 97))
;(check-random (si-move-ufo (make-posn 22 100)) (make-posn   24 97))
;(check-expect (si-move-tank (make-tank 173 4)) (make-tank 177 4))
;(check-expect (si-move-tank (make-tank 178 -4)) (make-tank 174 -4))
;(check-expect (si-move-tank (make-tank 25 -4)) (make-tank 21 -4))
;(check-expect (si-move-tank (make-tank 24 -4)) (make-tank 24 -4))

(define (si-move-ufo s-ufo)
  (make-posn
   (cond
     [(> (si-move-proper (posn-y s-ufo) UFO-DESCENT-VELOCITY) UFO-LAND-LEVEL)
      (posn-x s-ufo)]
     [(<= (si-move-proper (posn-x s-ufo) (- UFO-X-VELOCITY)) (image-width UFO))
      (si-move-proper (posn-x s-ufo) UFO-X-VELOCITY)]
     [(>= (si-move-proper (posn-x s-ufo) UFO-X-VELOCITY) UFO-LAND-LEVEL)
      (si-move-proper (posn-x s-ufo) (- UFO-X-VELOCITY))]
     [else (si-move-random (posn-x s-ufo) UFO-X-VELOCITY)])
   (cond
     [(>= (si-move-proper (posn-y s-ufo) UFO-DESCENT-VELOCITY) UFO-LAND-LEVEL)
      UFO-LAND-LEVEL]
     [else (si-move-proper (posn-y s-ufo) UFO-DESCENT-VELOCITY)])))



; si-move-tank
; func for change tank-type coord parametres per time
; Tank -> Tank
; change Tank loc position of the vel per time

;(check-expect (si-move-tank (make-tank 178 4)) (make-tank 178 4))
;(check-expect (si-move-tank (make-tank 173 4)) (make-tank 177 4))
;(check-expect (si-move-tank (make-tank 178 -4)) (make-tank 174 -4))
;(check-expect (si-move-tank (make-tank 25 -4)) (make-tank 21 -4))
;(check-expect (si-move-tank (make-tank 24 -4)) (make-tank 24 -4))

(define (si-move-tank s-tank)
  (make-tank
   (cond
    [(or (>= (si-move-proper (tank-loc s-tank) (tank-vel s-tank)) (- WIDTH (/ (image-width TANK) 2)))
         (<= (si-move-proper (tank-loc s-tank) (tank-vel s-tank)) (/ (image-width TANK) 2)))
     (tank-loc s-tank)]
    [else
     (si-move-proper (tank-loc s-tank) (tank-vel s-tank))])
    (tank-vel s-tank)))



;; si-move-missile
; func for change missile-type coord parametres per time
; MISSILE -> MISSILE
; change y position of the MISSILE per time
; to the constant change
; return #false if missle not fired

;(check-expect (si-move-missile.v2 (make-posn 100 100)) (make-posn  100 (+ 100 MISSILE-FLIGHT-VELOCITY)))
;(check-expect (si-move-missile.v2 #false) #false)

(define (si-move-missile.v2 s-missile)
  (cond [(boolean? s-missile) s-missile]
        [(posn? s-missile)
         (make-posn
          (posn-x s-missile)
          (si-move-proper (posn-y s-missile) MISSILE-FLIGHT-VELOCITY))]))



; si-move-proper
; func for determine in process of time
; new coord for the space-invader objects 
; Number (Coord), Number -> Number (Coord)
; (define (si-move-random w delta) w)
; adds delta to the given w coord

;(check-random (si-move-proper 100 3) 103)

(define (si-move-proper w delta)
  (+ w delta))



; si-move-random
; func for creates a random coordinate for the
; space-invader objects 
; Number -> Number
; (define (si-move-random w) w)
; adds rand number (limits of WIDTH/100) to the given w coord

;(check-random (si-move-random 185 2) (cond [(even? (random RANDOM_LIMIT)) (+ 185 UFO_X_VELOCITY)]
;               [else (- 185 UFO_X_VELOCITY)]))
;(check-random (si-move-random 176 2) (cond [(even? (random RANDOM_LIMIT)) (+ 176 UFO_X_VELOCITY)]
;               [else (- 176 UFO_X_VELOCITY)]))
;(check-random (si-move-random 100 2) (cond [(even? (random RANDOM_LIMIT)) (+ 100 UFO_X_VELOCITY)]
;               [else (- 100 UFO_X_VELOCITY)]))
;(check-random (si-move-random 18 2) (cond [(even? (random RANDOM_LIMIT)) (+ 18 UFO_X_VELOCITY)]
;               [else (- 18 UFO_X_VELOCITY)]))

(define (si-move-random w delta)
  (cond [(even? (random RANDOM-LIMIT)) (+ w delta)]
               [else (- w delta)]))



; SIGS.v2 -> Image
; creates the last scene with the result of the game after the final event, with the final text and effects

(define (si-render-final.v2 s)
  (cond
    [(missile-hit?.v2 (sigs.v2-ufo s) (sigs.v2-missile s))
        (win-text-render (star-fire-render (sigs.v2-ufo s) (sigs.v2-missile s) (missile-render.v2 (sigs.v2-missile s) (tank-render (sigs.v2-tank s)
                  (ufo-render (sigs.v2-ufo s) BACKGROUND)))))]
    [else (lose-text-render (missile-render.v2 (sigs.v2-missile s) (tank-render (sigs.v2-tank s)
                  (red-ufo-render (sigs.v2-ufo s) BACKGROUND))))]))



; UFO, MISSILE, Image -> Image
; consume ufo, missile calculates the location of the explosion
; from the contact and adds fire to the given image

(define (star-fire-render s-ufo s-missile im)
  (place-image FIRE
               (/ (+ (posn-x s-ufo) (posn-x s-missile)) 2)
               (/ (+ (posn-y s-ufo) (posn-y s-missile)) 2)
               im))



;; Image -> Image 
;  adds lose-text to the given image im

(define (lose-text-render im)
  (place-image TEXT-LOSE
               (- (/ WIDTH 1) (image-width TEXT-LOSE))
              (image-height TEXT-LOSE)
              im))


;; Image -> Image 
;  adds win-text to the given image im

(define (win-text-render im)
  (place-image TEXT-WIN
               (- WIDTH (image-width TEXT-WIN))
              (image-height TEXT-WIN)
              im))



; UFO Image -> Image 
; adds red-ufo to the given image im

(define (red-ufo-render m im)
  (place-image WIN-UFO (posn-x m) (posn-y m) im))
