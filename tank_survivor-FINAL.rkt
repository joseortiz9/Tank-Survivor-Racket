#lang racket

;===================================================================================
; Proyecto Final: Fundamentos de Programación (750080M) Semestre 1 (2017-2).
; Profesor: Andrés Mauricio Castillo Robles.
; Estudiantes: Cesar Alberto Becerra (1744338),
;              José David Ortiz (1740634),
;              Juan Sebastian Velasquez (1744936).
;===================================================================================

(require 2htdp/universe
         2htdp/image
         lang/posn
         2htdp/batch-io
         htdp/gui)


;===================================================================================
; ESTRUCTURAS
;===================================================================================

; Contrato:
; world es una estructura define un mundo
; en el BigBang, que tiene como parámetros:
; jugador1 de tipo struct, jugador2 de tipo struct,
; balas de tipo list (lista de estructuras de balas),
; paredes de tipo list (lista de estructuras posicionales), 
; enemigos de tipo list (lista de estructuras de tanques con estado enemigo) y
; puntaje de tipo struct.
(define-struct world (jugador1 jugador2 balas paredes enemigos puntaje) #:transparent)

; Contrato:
; tanque es una estructura que tiene como parámetros:
; estado de tipo number (diferencia un tanque enemigo de un aliado), 
; imagen de tipo image, direccion que es string,
; velocidad de tipo number y vida de tipo number. 
(define-struct tanque (estado imagen posn direccion velocidad vida) #:transparent)

; Contrato: 
; img_tanque es una estructura para asignar una imagen a cada dirección del tanque.
(define-struct img_tanque (arriba abajo izquierda derecha))

; Contrato:
; bala es una estructura que tiene como atributos:
;posn es tipo struct
;direccion es tipo string
;estado es tipo number
(define-struct bala (posn direccion estado) #:transparent)

; Contrato:
; Pared es una estructura que tiene como atributo
;posn que representa su posició.
(define-struct pared (posn))

; Contrato:
; Puntaje es una estructura que tiene como atributos:
; nombreJug1 es tipo string
; nombreJug1 es tipo string
; valor es tipo number
 (define-struct puntaje (nombreJug1 nombreJug2 valor) #:transparent)


;===================================================================================
; GRÁFICOS
;===================================================================================

; Dimensiones de la ventana
(define ANCHO_JUEGO 650)
(define ALTO_JUEGO 650)
(define ANCHO_TOTAL 850)

; Fondo del juego
(define FONDO_JUEGO (bitmap "imagenes/bg.png"))

; Imágenes del jugador1 por dirección
(define ARRIBA_JUGADOR1 (bitmap "imagenes/arriba_jugador1.png"))
(define ABAJO_JUGADOR1 (bitmap "imagenes/abajo_jugador1.png"))
(define IZQUIERDA_JUGADOR1 (bitmap "imagenes/izq_jugador1.png"))
(define DERECHA_JUGADOR1 (bitmap "imagenes/der_jugador1.png"))

; Imágenes del jugador2 por dirección
(define ARRIBA_JUGADOR2 (bitmap "imagenes/arriba_jugador2.png"))
(define ABAJO_JUGADOR2 (bitmap "imagenes/abajo_jugador2.png"))
(define IZQUIERDA_JUGADOR2 (bitmap "imagenes/izq_jugador2.png"))
(define DERECHA_JUGADOR2 (bitmap "imagenes/der_jugador2.png"))

;Imagen para cuando un tanque aliado se queda sin vidas
(define TANQUE_MUERTO (bitmap "imagenes/jugador_muerto.png"))

; Imágenes para un tanque Enemigo por dirección
(define ARRIBA_ENEMIGO (bitmap "imagenes/arriba_enemigo.png"))
(define ABAJO_ENEMIGO (bitmap "imagenes/abajo_enemigo.png"))
(define IZQUIERDA_ENEMIGO (bitmap "imagenes/izq_enemigo.png"))
(define DERECHA_ENEMIGO (bitmap "imagenes/der_enemigo.png"))

; Imagen de bala
(define BALA_JUG (bitmap "imagenes/bala_jugador.png"))
(define BALA_ENE (bitmap "imagenes/bala_enemigo.png"))

; Imágenes para representar las vidas de cada jugador
(define CVACIO (bitmap "imagenes/corazon_vacio.png"))
(define CJUGADOR1A (bitmap "imagenes/corazon.png"))
(define CJUGADOR1B (bitmap "imagenes/corazon2.png"))
(define CJUGADOR1C (bitmap "imagenes/corazon3.png"))
(define CJUGADOR2A (bitmap "imagenes/corazon1.png"))
(define CJUGADOR2B (bitmap "imagenes/corazon21.png"))
(define CJUGADOR2C (bitmap "imagenes/corazon31.png"))
                      
; Lista de imágenes para las paredes
(define PAREDES_IMAGES (list (bitmap "imagenes/pared1.png")
                             (bitmap "imagenes/pared2.png")
                             (bitmap "imagenes/pared3.png")
                             (bitmap "imagenes/pared4.png")
                             (bitmap "imagenes/pared5.png")
                             (bitmap "imagenes/pared6.png")))

; Archivo de records
(define ARCH_RECORDS "records.csv")


;===================================================================================
; CONSTANTES
;===================================================================================

;Valor tick
(define VALOR_TICK 1/20)

;velocidades
(define VELOCIDAD_JUG1 25)
(define VELOCIDAD_JUG2 25)
(define VELOCIDAD_ENEMIGOS 5)
(define VELOCIDAD_BALA 10)

;rango de disparo del enemigo
(define RANGO_ENEMIGO 20)

;estados
(define EST_JUGADOR 0)
(define EST_ENEMIGO 1)

;vidas
(define VIDAS_JUGADOR 3)
(define VIDAS_ENEMIGO 1)

; Lista de posiciones donde puede reaparecer un enemigo
(define SPAWNS_ENEMIGOS (list (make-posn 25 25)
                              (make-posn 625 25)
                              (make-posn 325 325)
                              (make-posn 525 375)
                              (make-posn 125 375)
                              (make-posn 25 625)
                              (make-posn 625 625)))

; Instancia del jugador1
(define IMGES_JUGADOR1 (make-img_tanque ARRIBA_JUGADOR1 ABAJO_JUGADOR1 IZQUIERDA_JUGADOR1 DERECHA_JUGADOR1))
(define JUGADOR1 (make-tanque EST_JUGADOR IMGES_JUGADOR1 (make-posn 325 475) "up" VELOCIDAD_JUG1 VIDAS_JUGADOR))

; Instancia del JUGADOR2
(define IMGES_JUGADOR2 (make-img_tanque ARRIBA_JUGADOR2 ABAJO_JUGADOR2 IZQUIERDA_JUGADOR2 DERECHA_JUGADOR2))
(define JUGADOR2 (make-tanque EST_JUGADOR IMGES_JUGADOR2 (make-posn 325 525) "down" VELOCIDAD_JUG2 VIDAS_JUGADOR))

; Instancia de los ENEMIGOS
(define IMGES_ENEMIGO (make-img_tanque ARRIBA_ENEMIGO ABAJO_ENEMIGO IZQUIERDA_ENEMIGO DERECHA_ENEMIGO))
(define ENEMIGOS
  (list
   (make-tanque EST_ENEMIGO IMGES_ENEMIGO (make-posn 25 25) "down" VELOCIDAD_ENEMIGOS VIDAS_ENEMIGO)
   (make-tanque EST_ENEMIGO IMGES_ENEMIGO (make-posn 625 25) "down" VELOCIDAD_ENEMIGOS VIDAS_ENEMIGO)
   (make-tanque EST_ENEMIGO IMGES_ENEMIGO (make-posn 325 25) "down" VELOCIDAD_ENEMIGOS VIDAS_ENEMIGO)))

; Instancia inicial de las BALAS
(define BALAS empty)

; Instancia inicial de las PAREDES
(define PAREDES
  (list
   (make-pared (make-posn 75 75))
   (make-pared (make-posn 75 125))
   (make-pared (make-posn 175 75))
   (make-pared (make-posn 175 175))
   (make-pared (make-posn 175 225))
   (make-pared (make-posn 275 125))
   (make-pared (make-posn 275 175))
   (make-pared (make-posn 375 175))
   (make-pared (make-posn 475 75)) 
   (make-pared (make-posn 475 225))
   (make-pared (make-posn 575 75))
   (make-pared (make-posn 275 275))
   (make-pared (make-posn 375 275))
   (make-pared (make-posn 275 375))
   (make-pared (make-posn 425 275))
   (make-pared (make-posn 275 475))   
   (make-pared (make-posn 425 375))
   (make-pared (make-posn 375 475))
   (make-pared (make-posn 325 375))
   (make-pared (make-posn 175 325))
   (make-pared (make-posn 125 325))
   (make-pared (make-posn 175 425))
   (make-pared (make-posn 175 575))
   (make-pared (make-posn 75 425))
   (make-pared (make-posn 75 575))
   (make-pared (make-posn 575 575))
   (make-pared (make-posn 475 425)) 
   (make-pared (make-posn 475 575))   
   (make-pared (make-posn 75 325)) 
   (make-pared (make-posn 275 525))
   (make-pared (make-posn 375 525))
   (make-pared (make-posn 575 475))
   (make-pared (make-posn 325 625))
   (make-pared (make-posn 175 475))
   (make-pared (make-posn 575 275))
   (make-pared (make-posn 575 325))
   (make-pared (make-posn 75 275))
   (make-pared (make-posn 75 25))
   (make-pared (make-posn 375 25))
   (make-pared (make-posn 575 425))
   (make-pared (make-posn 625 425))
   (make-pared (make-posn 25 425))
   (make-pared (make-posn 175 375))
   (make-pared (make-posn 475 375))
   (make-pared (make-posn 525 325))))


; RANDOM
;========
; Contrato:
; random-element: list -> element
; Proposito:
; retorna un elemento aleatorio de una lista pasada por parámetro.
(define (random-element list)
  (list-ref list (random (length list))))

;===================================================================================
; PINTAR MUNDO
;===================================================================================


; Constante que almacena una lista de imágenes que representan cada pared.
; Contrato:
; pintarParedes: list -> list
; Proposito:
; retorna una lista de imágenes, asignandole una aleatoria a cada pared del mundo.
(define IMAGES-PAREDES
  (local
    ((define (pintarParedes paredes)
       (cond
         [(empty? paredes) empty]
         [else (append (list (random-element PAREDES_IMAGES)) (pintarParedes (rest paredes)))])))
    (pintarParedes PAREDES)))


; 1.Contrato:
; crearPuntaje: list -> list
; Proposito:
; Es una función auxiliar que recibe una lista y devuelve una instancia de puntaje.
; 2.Contrato:
; puntaje-by-line: list -> list
; Proposito:
; Recibe una lista de strings, convierte cada elemento en una instancia de puntaje y devuelve
; una lista de puntajes.
(define (puntaje-by-line lines)
  (local (
          ;Funcion para crear una instancia de la estructura a partir del primer elemento del archivo
          (define (crearPuntaje l) (make-puntaje (first l) (first (rest l)) (first (rest (rest l)))))

          (define (puntaje-by-line lines)
            (cond
              [(empty? lines) empty]
              [else (cons (crearPuntaje (string-split (first lines) ",")) (puntaje-by-line (rest lines)))]))
          ) (puntaje-by-line lines)))


; Contrato:
; pintar-vidas: number number -> image
; Proposito:
; devolver la representación gráfica de los corazones dependiendo de las vidas actuales de cada jugador, el segundo parámetro se utiliza para identificar si se están evaluando las vidas del jugador1 o jugador2.
(define (pintar-vidas vidas identificador)
  (cond
    [(= 1 identificador)
     (cond
       [(= 0 vidas) CVACIO]
       [(= 1 vidas) CJUGADOR1A]
       [(= 2 vidas) CJUGADOR1B]
       [(= 3 vidas) CJUGADOR1C])]
    [(= 2 identificador)
     (cond
       [(= 0 vidas) CVACIO]
       [(= 1 vidas) CJUGADOR2A]
       [(= 2 vidas) CJUGADOR2B]
       [(= 3 vidas) CJUGADOR2C])]))

; almacena una lista de strings, que se extrae del archivo de puntajes
; divididos por el salto de linea.
(define recordsList (string-split (read-file ARCH_RECORDS) "\n"))


; 1. Contrato:
; PintarRecords : list -> list
; Proposito:
; Recibe una lista de strings que representa los records
;  y las ordena para su posterior ubicación en el panel
; 2. Contrato:
; panelEstadisImages: mundo -> list
; Proposito:
; Ubica los records en el panel lateral de manera ordenada
; agregándole varias características visuales  
(define (panelEstadisImages mundo)
  (local
    ((define vidasJugador1 (tanque-vida (world-jugador1 mundo)))
     (define vidasJugador2 (tanque-vida (world-jugador2 mundo)))
     (define nombreJug1 (puntaje-nombreJug1 (world-puntaje mundo)))
     (define nombreJug2 (puntaje-nombreJug2 (world-puntaje mundo)))
     (define puntuacion (puntaje-valor (world-puntaje mundo)))
     ;1
     (define (PintarRecords lista)
       (cond
         [(empty? lista) empty]
         [else (cons (text (string-append (puntaje-nombreJug1 (first lista)) "-"
                                          (puntaje-nombreJug2 (first lista)) "->"
                                          (puntaje-valor (first lista))) 18 "white")
                     (PintarRecords (rest lista)))]))
     ;2
     (define (panelEstadisImages mundo)
       (append (list (text (string-append nombreJug1 ": ") 20 "red"))
               (list (pintar-vidas vidasJugador1 1))
               (list (text (string-append nombreJug2 ": ") 20 "lightseagreen"))
               (list (pintar-vidas vidasJugador2 2))
               (list (text (string-append "Puntaje: " (number->string puntuacion)) 20 "seagreen"))
               (list (text "RECORDS: " 20 "seagreen"))
               (PintarRecords (puntaje-by-line (take recordsList 3))))))
    (panelEstadisImages mundo)))
    

; Contrato:
; elm-get-posn: struct -> posn
; Proposito:
; Devolver la posición actual del elemento pasado por parametro.
(define (elm-get-posn elem)
  (cond
    [(tanque? elem) (tanque-posn elem)]
    [(bala? elem) (bala-posn elem)]
    [(pared? elem) (pared-posn elem)]))

; Contrato:
; elm-get-estado: struct -> number
; Proposito:
; Devolver el estado del elemento pasado por parámetro.
(define (elm-get-estado elem)
  (cond
    [(tanque? elem) (tanque-estado elem)]
    [(bala? elem) (bala-estado elem)]))

; Contrato:
; getImageTanque: tanque -> image
; Proposito:
; Devolver la representación gráfica de un tanque, dependiendo si está vivo o no y de su dirección.
(define (getImageTanque tanque)
  (if (equal? (tanque-vida tanque) 0)
      TANQUE_MUERTO
      (cond
        [(equal? (elm-get-direccion tanque) "up") (img_tanque-arriba (tanque-imagen tanque))]
        [(equal? (elm-get-direccion tanque) "left") (img_tanque-izquierda (tanque-imagen tanque))]
        [(equal? (elm-get-direccion tanque) "right") (img_tanque-derecha (tanque-imagen tanque))]
        [(equal? (elm-get-direccion tanque) "down") (img_tanque-abajo (tanque-imagen tanque))])))


; 1.Contrato:
; getPosn: list -> list
; Proposito:
; Retornar una lista de las posiciones de los elementos de la lista que se pasa por parámetro.
; 2.Contrato:
; getImageBala: balas -> image
; Proposito:
; Retornar la representación gráfica dependiendo del estado de la bala pasada por parametro.
; 3.Contrato:
; elm-get-imagen: struct -> image
; Proposito:
; Retornar la representación gráfica de un elemento pasado por parametro.
; 4.Contrato:
; getImagenes: list -> list
; Proposito:
; Retornar una lista de las imagenes de los elementos de la lista que se pasa por parámetro.
; 5.Contrato:
; pintarMundo: mundo -> void
; Proposito:
; Función que pinta todos los elementos en la ventana.
(define (pintarMundo mundo)
  (local
    (
     ;1.
     (define (getPosn elementos)
       (cond
         [(empty? elementos) empty]
         [else (append (list (elm-get-posn (first elementos))) (getPosn (rest elementos)))]))

     ; Lista de posiciones de cada elemento del panel lateral
     (define panelPosn
       (append (list (make-posn 750 40)) ;Nombre Jugador1
               (list (make-posn 750 80)) ;imagenes vidas jugador1
               (list (make-posn 750 130)) ;Nombre Jugador2
               (list (make-posn 750 170)) ;imagenes vidas jugador2
               (list (make-posn 750 220)) ;puntaje actual
               (list (make-posn 750 270)) ;titulo de records
               (list (make-posn 750 300)) ;record numero1
               (list (make-posn 750 340)) ;record numero2
               (list (make-posn 750 380)) ;record numero3
               ))
     
     (define panelImages (panelEstadisImages mundo))
     (define elementos (append (list (world-jugador1 mundo))
                               (list (world-jugador2 mundo))
                               (world-balas mundo)
                               (world-enemigos mundo)))
     (define paredesPosn (getPosn (world-paredes mundo)))

     ;2.
     (define (getImageBala bala)
       (cond
         [(equal? (elm-get-estado bala) 0) BALA_JUG]
         [(equal? (elm-get-estado bala) 1) BALA_ENE]))

     ;3.
     (define (elm-get-imagen elem)
       (cond
         [(tanque? elem) (getImageTanque elem)]
         [(bala? elem) (getImageBala elem)]))

     ;4.
     (define (getImagenes elementos)
       (cond
         [(empty? elementos) empty]
         [else (append (list (elm-get-imagen (first elementos))) (getImagenes (rest elementos)))]))
     
     (define imagenes (append (getImagenes elementos) panelImages IMAGES-PAREDES))
     (define posiciones (append (getPosn elementos) panelPosn paredesPosn))
     (define (pintarMundo mundo)
  
       (place-images imagenes posiciones FONDO_JUEGO)))
    ;5.
    (pintarMundo mundo)))



;===================================================================================
; LÓGICA
;===================================================================================


; Contrato:
; elm-get-direccion: struct -> string
; Proposito:
; Retornar un string que representa la dirección del elemento que se pasa por parámetro.
(define (elm-get-direccion elem)
  (cond
    [(tanque? elem) (cond
                      [(string=? (tanque-direccion elem) "w") "up"]
                      [(string=? (tanque-direccion elem) "s") "down"]
                      [(string=? (tanque-direccion elem) "a") "left"]
                      [(string=? (tanque-direccion elem) "d") "right"]
                      [else (tanque-direccion elem)])]
    [(bala? elem) (bala-direccion elem)]))

; Contrato:
; elm-getImg-w: struct -> number
; Proposito:
; Retornar un número que representa la distancia del centro a un lado
; de la imagen del elemento que se pasa por parámetro.
(define (elm-getImg-w elem)
  (cond
    [(tanque? elem) (/ (image-width (getImageTanque elem)) 2)]
    [(bala? elem) (/ (image-width BALA_JUG) 2)]
    [(pared? elem) (/ (image-width (first PAREDES_IMAGES)) 2)]))

;Colisiona con algun elemento
;1. Contrato:
; distancia: pons posn -> number
; Proposito:
; Es una función auxiliar que se utiliza para calcular la distancia entre
; dos puntos del plano
;2. Contrato:
; colisiona?: struct struct -> Boolean
; Proposito:
; Evalúa si dos objetos se sobrelapan entre sí, utilizando como auxiliar la función
; distancia, y tomando las posiciones de los parámetros dados  
(define (colisiona? obj1 obj2)
  (local(
         ;1
         (define (distancia p1 p2) (sqrt (+ (sqr (- (posn-x p1) (posn-x p2)))
                                            (sqr (- (posn-y p1) (posn-y p2))))))
         ;2
         (define (colisiona? obj1 obj2)
           (cond
             [(< (distancia (elm-get-posn obj1) (elm-get-posn obj2))
                 (+ (elm-getImg-w obj1) (elm-getImg-w obj2))) #true]
             [else #false])))
    (colisiona? obj1 obj2)))


;========================================
; JUGADORES
;========================================

; Contrato:
; cambiarPosnJugador: tanque string number -> tanque
; Proposito:
; Retorna un tanque en la siguiente posición que toma dependiendo de la
; tecla pasada por parámetro, es decir la dirección a donde moverse,
; el identificador ayuda a saber si se va a mover el jugador1 o el jugador2.
(define (cambiarPosnJugador tanque tecla identificador)
  (define estado (tanque-estado tanque))
  (define imagen (tanque-imagen tanque))
  (define direccion (tanque-direccion tanque))
  (define posn (tanque-posn tanque))
  (define x (posn-x (tanque-posn tanque)))
  (define y (posn-y (tanque-posn tanque)))
  (define velocidad (tanque-velocidad tanque))
  (define vida (tanque-vida tanque))
  (cond
    [(= identificador 1)
     (cond
       [(string=? tecla "up")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn x (- y velocidad)) "up" velocidad vida)]
          [else (make-tanque estado imagen posn "up" velocidad vida)])]
       
       [(string=? tecla "down")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn x (+ y velocidad)) "down" velocidad vida)]
          [else (make-tanque estado imagen posn "down" velocidad vida)])]
       
       [(string=? tecla "left")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn (- x velocidad) y) "left" velocidad vida)]
          [else (make-tanque estado imagen posn "left" velocidad vida)])]
       
       [(string=? tecla "right")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn (+ x velocidad) y) "right" velocidad vida)]
          [else (make-tanque estado imagen posn "right" velocidad vida)])]
       [else tanque])]
    
    [(= identificador 2)
     (cond
       [(string=? tecla "w")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn x (- y velocidad)) "w" velocidad vida)]
          [else (make-tanque estado imagen posn "w" velocidad vida)])]
       
       [(string=? tecla "s")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn x (+ y velocidad)) "s" velocidad vida)]
          [else (make-tanque estado imagen posn "s" velocidad vida)])]
       
       [(string=? tecla "a")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn (- x velocidad) y) "a" velocidad vida)]
          [else (make-tanque estado imagen posn "a" velocidad vida)])]
       
       [(string=? tecla "d")
        (cond
          [(string=? tecla direccion) (make-tanque estado imagen (make-posn (+ x velocidad) y) "d" velocidad vida)]
          [else (make-tanque estado imagen posn "d" velocidad vida)])]
       [else tanque])]))


; 1.Contrato:
; colisionanTanquesObjeto?: tanque tanque struct -> boolean
; Proposito:
; Evaluar si alguno de los tanques colisiona con algún objeto de la lista pasada como tercer
; parámetro. 
; 2.Contrato:
; moverTanquesAliados: mundo string -> mundo
; Proposito:
; Devuelve el mundo con las posiciones de los jugadores actualizadas si este movimiento se puede
; dar y su vida es mayor a cero.
(define (moverTanquesAliados mundo tecla)
  (local(
         (define jugador1 (world-jugador1 mundo))
         (define jugador1_nuevo (cambiarPosnJugador jugador1 tecla 1))
         (define jugador2 (world-jugador2 mundo))
         (define jugador2_nuevo (cambiarPosnJugador jugador2 tecla 2))
         (define balas (world-balas mundo))
         (define paredes (world-paredes mundo))
         (define enemigos (world-enemigos mundo))
         (define puntaje (world-puntaje mundo))
         
         ;1.
         (define (colisionanTanquesObjeto? tanque1 tanque2 objeto)
           (cond
             [(empty? objeto) #false]
             [(or (colisiona? tanque1 (first objeto)) (colisiona? tanque2 (first objeto))) #true]
             [else (colisionanTanquesObjeto? tanque1 tanque2 (rest objeto))]))

         ;2.
         (define (moverTanquesAliados mundo tecla)
           (cond
             [(or (colisionanObjetoLimite? jugador1_nuevo)
                  (colisionanObjetoLimite? jugador2_nuevo)
                  (colisionanTanquesObjeto? jugador1_nuevo jugador2_nuevo paredes)
                  (colisionanTanquesObjeto? jugador1_nuevo jugador2_nuevo enemigos)
                  (colisiona? jugador1_nuevo jugador2_nuevo))
              (make-world jugador1 jugador2 balas paredes enemigos puntaje)]
             [else
              (cond
                [(equal? (tanque-vida jugador1) 0)
                 (make-world jugador1 jugador2_nuevo balas paredes enemigos puntaje)]
                [(equal? (tanque-vida jugador2) 0)
                 (make-world jugador1_nuevo jugador2 balas paredes enemigos puntaje)]
                [else (make-world jugador1_nuevo jugador2_nuevo balas paredes enemigos puntaje)])
              ])))
    (moverTanquesAliados mundo tecla)))


;========================================
; ENEMIGOS
;========================================

; Contrato:
; colisionanEnemigoOBalaObjeto?: struct list -> Boolean
; Proposito:
; Esta función verifica si un enemigo o una bala 
; colisiona con algún objeto de la lista entregada  
; evaluando de una manera distinta dependiendo de la naturaleza
; de los parámetros, el enemigo no colisiona con sus mismas balas
(define (colisionanEnemigoOBalaObjeto? enem_bala objeto)
  (define est-enem_bala (elm-get-estado enem_bala))
  (cond
    [(empty? objeto) #false]
    [(colisiona? enem_bala (first objeto))
     (cond
       [(tanque? (first objeto))
        (cond
          [(equal? est-enem_bala (tanque-estado (first objeto)))
           (cond
             [(and (tanque? enem_bala) (= 1 (tanque-estado (first objeto)))) #true]
             [else #false])]
          [(not (equal? est-enem_bala (tanque-estado (first objeto)))) #true])]
       [(bala? (first objeto))
        (cond
          [(equal? est-enem_bala (bala-estado (first objeto))) #false]
          [(not (equal? est-enem_bala (bala-estado (first objeto)))) #true])]
       [(pared? (first objeto)) #true])]
    [else (colisionanEnemigoOBalaObjeto? enem_bala (rest objeto))]))

;Contrato:
;quitarEnemigoPorPosicion: list tanque -> list
;Proposito
;Elimina el tanque pasado como segundo parámetro de una lista de tanques.
(define (quitarEnemigoPorPosicion lista enemigo)
  (remove enemigo lista))

;Contrato:
;respawnEnemigos: tanque tanque tanque list  -> tanque
;Proposito
;Función usada cuando un tanque enemigo eliminado, esta evalua si alguno de
;los lugares en donde reaparecen los enemigos al morir está libre, dado este caso,
;devuelve el tanque en esa posición.
(define (respawnEnemigos enemigo jugador1 jugador2 copy_enemigos)
  (define randomposn (random-element SPAWNS_ENEMIGOS))
  (define estado (tanque-estado enemigo))
  (define velocidad (tanque-velocidad enemigo))
  (define direccion (tanque-direccion enemigo))
  (define imagen (tanque-imagen enemigo))
  (define vida (tanque-vida enemigo))
  (define sgte_posn_enemigo (make-tanque estado imagen randomposn direccion velocidad vida))
  (if (or
       (colisionanEnemigoOBalaObjeto? sgte_posn_enemigo (list jugador1))
       (colisionanEnemigoOBalaObjeto? sgte_posn_enemigo (list jugador2))
       (colisionanEnemigoOBalaObjeto? sgte_posn_enemigo (quitarEnemigoPorPosicion copy_enemigos enemigo)))
      (respawnEnemigos sgte_posn_enemigo jugador1 jugador2 copy_enemigos)
      sgte_posn_enemigo))


;Contrato:
;cambiarPosnEnemigo: tanque -> tanque
;Proposito:
;Devuelve el tanque pasado por parámetro en la siguiente posición que toma
;dependiendo de su dirección.
(define (cambiarPosnEnemigo enemigo)
  (define direccion (tanque-direccion enemigo))
  (define posn (tanque-posn enemigo))
  (define x (posn-x (tanque-posn enemigo)))
  (define y (posn-y (tanque-posn enemigo)))
  (define estado (tanque-estado enemigo))
  (define velocidad (tanque-velocidad enemigo))
  (define imagen (tanque-imagen enemigo))
  (define ancho-imagen (elm-getImg-w enemigo))
  (define vida (tanque-vida enemigo))
  (cond
    [(string=? direccion "up")
     (make-tanque estado imagen (make-posn x (- y velocidad)) direccion velocidad vida)]
    
    [(string=? direccion "down")
     (make-tanque estado imagen (make-posn x (+ y velocidad)) direccion velocidad vida)]
    
    [(string=? direccion "left")
     (make-tanque estado imagen (make-posn (- x velocidad) y) direccion velocidad vida)]
    
    [(string=? direccion "right")
     (make-tanque estado imagen (make-posn (+ x velocidad) y) direccion velocidad vida)]))



;Contrato:
;colisionaTodasDirecciones: tanque string tanque tanque list list  -> boolean
;Proposito
;Función usada cuando se requiere cambiar la dirección de un enemigo,
;esta retorna #true cuando el enemigo tiene el camino en la dirección que se
;le pasa por parámetro cerrado.
(define (colisionaTodasDirecciones enemigo direccion_man jugador1 jugador2 paredes copy_enemigos)
  (define posn (tanque-posn enemigo))
  (define estado (tanque-estado enemigo))
  (define velocidad (tanque-velocidad enemigo))
  (define imagen (tanque-imagen enemigo))
  (define vida (tanque-vida enemigo))
  (define sgte_dir_enemigo (make-tanque estado imagen posn direccion_man velocidad vida))
  (define sgte_mov_enemigo (cambiarPosnEnemigo sgte_dir_enemigo))
  (if (or
       (colisionanObjetoLimite? sgte_mov_enemigo)
       (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo (list jugador1))
       (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo (list jugador2))
       (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo (quitarEnemigoPorPosicion copy_enemigos enemigo))
       (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo paredes)) #true #false))


;Contrato:
;cambiarDireccionEnemigo: tanque tanque tanque list list  -> tanque
;Proposito:
;Función encargada de la IA. retorna el enemigo pasado por parámetro con una
;dirección en donde no colisione con ningún elemento del mundo.
(define (cambiarDireccionEnemigo enemigo jugador1 jugador2 paredes copy_enemigos)
  (define randomdireccion (random-element (list "up" "down" "left" "right")))
  (define posn (tanque-posn enemigo))
  (define estado (tanque-estado enemigo))
  (define velocidad (tanque-velocidad enemigo))
  (define imagen (tanque-imagen enemigo))
  (define vida (tanque-vida enemigo))
  (define sgte_dir_enemigo (make-tanque estado imagen posn randomdireccion velocidad vida))
  (define sgte_mov_enemigo (cambiarPosnEnemigo sgte_dir_enemigo))
  (cond
    [(and (colisionaTodasDirecciones enemigo "up" jugador1 jugador2 paredes copy_enemigos)
          (colisionaTodasDirecciones enemigo "down" jugador1 jugador2 paredes copy_enemigos)
          (colisionaTodasDirecciones enemigo "left" jugador1 jugador2 paredes copy_enemigos)
          (colisionaTodasDirecciones enemigo "right" jugador1 jugador2 paredes copy_enemigos))
     enemigo]
    [(or
      (colisionanObjetoLimite? sgte_mov_enemigo)
      (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo (list jugador1))
      (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo (list jugador2))
      (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo (quitarEnemigoPorPosicion copy_enemigos enemigo))
      (colisionanEnemigoOBalaObjeto? sgte_mov_enemigo paredes))
     (cambiarDireccionEnemigo enemigo jugador1 jugador2 paredes copy_enemigos)]
    [else sgte_dir_enemigo]))

; Contrato:
; eliminarEnemigo: list list tanque tanque list -> list
; Proposito:
; Esta función actualiza la posición de un
; enemigo de la lista si este colisiona con alguna bala aliada,
; por medio de la funcion respawnEnemigos
; luego de esto, retorna una lista actualizada de enemigos 
; respawnEnemigos
(define (eliminarEnemigo enemigos balas jugador1 jugador2 copy_enemigos)
  (cond
    [(empty? enemigos) empty]
    [(colisionanEnemigoOBalaObjeto? (first enemigos) balas)
     (append (list (respawnEnemigos (first enemigos) jugador1 jugador2 copy_enemigos))
             (eliminarEnemigo (rest enemigos) balas jugador1 jugador2 copy_enemigos))]
    [else (append (list (first enemigos)) (eliminarEnemigo (rest enemigos) balas jugador1 jugador2 copy_enemigos))]))


; Contrato:
; movimientoEnemigoFinal: list tanque tanque list list -> list
; Proposito:
; Esta funcion retorna una lista de enemigos con su direccion actualizada, 
; si algún enemigo colisiona con algún elemento del mapa, o si colisiona al reaparecer.
(define (movimientoEnemigoFinal enemigos jugador1 jugador2 paredes copy_enemigos)
  (cond
    [(empty? enemigos) empty]
    [(or (colisionanObjetoLimite? (cambiarPosnEnemigo (first enemigos)))
         (colisionanEnemigoOBalaObjeto? (cambiarPosnEnemigo (first enemigos)) (list jugador1))
         (colisionanEnemigoOBalaObjeto? (cambiarPosnEnemigo (first enemigos)) (list jugador2))
         (colisionanEnemigoOBalaObjeto? (cambiarPosnEnemigo (first enemigos)) (quitarEnemigoPorPosicion copy_enemigos (first enemigos)))
         (colisionanEnemigoOBalaObjeto? (cambiarPosnEnemigo (first enemigos)) paredes))
     (cons (cambiarDireccionEnemigo (first enemigos) jugador1 jugador2 paredes copy_enemigos)
           (movimientoEnemigoFinal (rest enemigos) jugador1 jugador2 paredes copy_enemigos))]
    [else (append (list (first enemigos)) (movimientoEnemigoFinal (rest enemigos) jugador1 jugador2 paredes copy_enemigos))]))

;Contrato:
;colisionanObjetoLimite: struct  -> boolean
;Proposito:
;Retorna #true si el elemento pasado por parámetro colisiona con un límite del área
;de juego en su siguiente movimiento.
(define (colisionanObjetoLimite? objeto)
  (define direccion (elm-get-direccion objeto))
  (define x (posn-x (elm-get-posn objeto)))
  (define y (posn-y (elm-get-posn objeto)))
  (define ancho-imagen (elm-getImg-w objeto))
  (cond
    [(string=? direccion "up") (if (< y (+ 0 ancho-imagen)) #true #false)]
    [(string=? direccion "down") (if (> y (- ALTO_JUEGO ancho-imagen)) #true #false)]
    [(string=? direccion "left") (if (< x (+ 0 ancho-imagen)) #true #false)]
    [(string=? direccion "right") (if (> x (- ANCHO_JUEGO ancho-imagen)) #true #false)]))


;========================================
; BALAS
;========================================

;Contrato:
;eliminarBala: list tanque tanque list list -> list
;Proposito:
;Si una de las balas de la lista colisiona con alguno de los elementos pasados
;como parámetros esta se elimina de la lista, retornando la lista de balas actualizadas.
(define (eliminarBala balas jugador1 jugador2 paredes enemigos)
  (cond
    [(empty? balas) empty]
    [(or (colisionanObjetoLimite? (first balas))
         (colisionanEnemigoOBalaObjeto? (first balas) (list jugador1))
         (colisionanEnemigoOBalaObjeto? (first balas) (list jugador2))
         (colisionanEnemigoOBalaObjeto? (first balas) paredes)
         (colisionanEnemigoOBalaObjeto? (first balas) enemigos)
         (colisionanEnemigoOBalaObjeto? (first balas) balas))
     (eliminarBala (rest balas) jugador1 jugador2 paredes enemigos)]
    [else (append (list (first balas)) (eliminarBala (rest balas) jugador1 jugador2 paredes enemigos))]))

;Contrato:
;agregarBala: tanque list -> list
;Proposito:
;Agrega una instancia de la estructura bala a la lista de balas de mundo, el
;estado de la bala es dependiente del tanque la dispara.
(define (agregarBala tanque balas)
  (define posn (tanque-posn tanque))
  (define direccion (elm-get-direccion tanque))
  (define estadoTanque (tanque-estado tanque))
  (cons (make-bala posn direccion estadoTanque) balas))

;Contrato:
;bala_movimiento: bala -> bala
;Proposito:
;Retorna la bala pasada por parámetro en la siguiente posición que toma
;dependiendo de su dirección.
(define (bala_movimiento bala)
  (define direccion (bala-direccion bala))
  (define x (posn-x (bala-posn bala)))
  (define y (posn-y (bala-posn bala)))
  (define estado (bala-estado bala))
  (define ancho-imagen (elm-getImg-w bala))
  (cond
    [(string=? direccion "up") (make-bala (make-posn x (- y VELOCIDAD_BALA)) direccion estado)]
    [(string=? direccion "down") (make-bala (make-posn x (+ y VELOCIDAD_BALA)) direccion estado)]
    [(string=? direccion "left") (make-bala (make-posn (- x VELOCIDAD_BALA) y) direccion estado)]
    [(string=? direccion "right") (make-bala (make-posn (+ x VELOCIDAD_BALA) y) direccion estado)]))

;Contrato:
;dispararBalaEnemigo: list list -> list
;Proposito:
;Cada vez que un valor aleatorio de RANGO_ENEMIGO es igual a uno se agrega
;una instancia de la estructura bala a la lista de balas del mundo con las
;características del enemigo que se esté evaluando en esa iteración.
(define (dispararBalaEnemigo balas enemigos)
  (cond
    [(empty? enemigos) balas]
    [(= 1 (random RANGO_ENEMIGO))
     (dispararBalaEnemigo (agregarBala (first enemigos) balas) (rest enemigos))]
    [else (dispararBalaEnemigo balas (rest enemigos))]))

;Contrato:
;dispararBalaEnemigo: tanque mundo -> mundo
;Proposito:
;devuelve el mundo con balas agregadas, estas tienen las características
;del jugador que se pasa como primer parámetro. 
(define (dispararBalaJugador jugador mundo)
  (define vidas_jugador (tanque-vida jugador))
  (define jugador1 (world-jugador1 mundo))
  (define jugador2 (world-jugador2 mundo))
  (define balas_agregadas (agregarBala jugador (world-balas mundo)))
  (define paredes (world-paredes mundo))
  (define enemigos (world-enemigos mundo))
  (define puntaje (world-puntaje mundo))
  (cond
    [(> vidas_jugador 0)
     (make-world jugador1 jugador2 balas_agregadas paredes enemigos puntaje)]
    [else mundo]))

;Contrato:
;restarVidaJugador: tanque list -> tanque
;Proposito:
;Retorna el jugador con una vida menos si este colisiona con alguna bala
;de la lista pasada por parámetro.
(define (restarVidaJugador jugador balas)
  (define estado (tanque-estado jugador))
  (define imagen (tanque-imagen jugador))
  (define direccion (tanque-direccion jugador))
  (define posn (tanque-posn jugador))
  (define velocidad (tanque-velocidad jugador))
  (define vida (tanque-vida jugador))
  (cond
    [(and (> vida 0) (colisionanEnemigoOBalaObjeto? jugador balas))
     (make-tanque estado imagen posn direccion velocidad (- vida 1))]
    [else jugador]))


;========================================
; DIFICULTAD
;========================================

;Contrato:
;aumentarPuntaje: number list list -> number
;Proposito:
;Sumar 100 al puntaje del mundo si un enemigo es eliminado.
(define (aumentarPuntaje puntaje_ant balas enemigos)
  (cond
    [(or (empty? balas) (empty? enemigos)) puntaje_ant]
    [(colisionanEnemigoOBalaObjeto? (first enemigos) balas) (+ 100 puntaje_ant)]
    [else (aumentarPuntaje puntaje_ant balas (rest enemigos))]))

;Contrato:
;anadirEnemigos: list number tanque tanque list -> list
;Proposito:
;Añadir un enemigo a la lista si el puntaje del mundo cumple alguno de los
;criterios de la función, en esta también se aumentan algunas características
;de los enemigos con el objetivo de aumentar la dificultad.
(define (anadirEnemigos enemigos puntaje jugador1 jugador2 copy_enemigos)
  (define score (puntaje-valor puntaje))
  (cond
    [(and (= score 1000) (= (length enemigos) 3))
     (cons (respawnEnemigos (first enemigos) jugador1 jugador2 copy_enemigos) enemigos)]
    [(and (= score 2000) (= (length enemigos) 4))
     (cons (respawnEnemigos (first enemigos) jugador1 jugador2 copy_enemigos) enemigos)]
    [(and (= score 3000) (= (length enemigos) 5))
     (cons (respawnEnemigos (first enemigos) jugador1 jugador2 copy_enemigos) enemigos)]
    [(and (= score 5000) (= (length enemigos) 6))
     (begin (set! RANGO_ENEMIGO 15) (set! VELOCIDAD_ENEMIGOS 7) (cons (respawnEnemigos (first enemigos) jugador1 jugador2 copy_enemigos) enemigos))]
    [(and (= score 8000) (= (length enemigos) 7))
     (begin (set! RANGO_ENEMIGO 10) (set! VELOCIDAD_ENEMIGOS 8) (cons (respawnEnemigos (first enemigos) jugador1 jugador2 copy_enemigos) enemigos))]
    [(and (= score 10000) (= RANGO_ENEMIGO 10))
     (begin (set! RANGO_ENEMIGO 8) (set! VELOCIDAD_ENEMIGOS 9) enemigos)]
    [else enemigos]))


;========================================
; EVENTOS
;========================================

;Contrato:
;actMundoTeclado: mundo string -> mundo
;Proposito:
;Devolver un mundo actualizado dependiendo de la tecla que se presione.
(define (actMundoTeclado mundo tecla)
  (define jugador1 (world-jugador1 mundo))
  (define jugador2 (world-jugador2 mundo))
  (cond
    [(string=? tecla "p") (dispararBalaJugador jugador1 mundo)]
    [(string=? tecla " ") (dispararBalaJugador jugador2 mundo)]
    [else (moverTanquesAliados mundo tecla)]))

;1. Contrato:
;mover_list_objetos: list function -> list
;Proposito:
;Ejecutar la función pasada como segundo parametro a la lista, se
; utiliza para realizar el movimiento de las balas y los enemigos.
;2. Contrato:
;enemigo_movimiento: tanque -> tanque
;Proposito:
;devolver la siguiente posicion del enemigo pasado por parámetro.
;3. Contrato:
;actMundoTick: mundo -> mundo
;Proposito:
;actualizar el mundo pasado por parametro dependiendo del tiempo.
(define (actMundoTick mundo)
  (local(
         (define jugador1 (world-jugador1 mundo))
         (define jugador2 (world-jugador2 mundo))
         (define balas (world-balas mundo))
         (define paredes (world-paredes mundo))
         (define enemigos (world-enemigos mundo))
         (define puntaje (world-puntaje mundo))

         ;1.
         (define (mover_list_objetos objetos fun_mov)
           (cond
             [(empty? objetos) empty]
             [else (cons (fun_mov (first objetos)) (mover_list_objetos (rest objetos) fun_mov))]))
         
         (define balas_acts (mover_list_objetos balas bala_movimiento))

         ;2.
         (define (enemigo_movimiento enemigo)
           (cambiarPosnEnemigo enemigo))
         
         (define enem_acts (mover_list_objetos enemigos enemigo_movimiento))
             
        
         (define enems_remov (eliminarEnemigo enem_acts balas_acts jugador1 jugador2 enem_acts))
         (define enems_final (movimientoEnemigoFinal enems_remov jugador1 jugador2 paredes enem_acts))
         (define balas_remov (eliminarBala balas_acts jugador1 jugador2 paredes enemigos))
         (define balas_nuevas (dispararBalaEnemigo balas_remov enems_final))
         
         (define aum_puntaje (make-puntaje (puntaje-nombreJug1 puntaje)
                                           (puntaje-nombreJug2 puntaje)
                                           (aumentarPuntaje (puntaje-valor puntaje) balas_acts enem_acts)))
         
         (define enems_anadidos (anadirEnemigos enems_final aum_puntaje jugador1 jugador2 enem_acts))
         (define jugador1_sin_vidas (restarVidaJugador jugador1 balas_acts))
         (define jugador2_sin_vidas (restarVidaJugador jugador2 balas_acts))

         ;3.
         (define (actMundoTick mundo)
           (make-world jugador1_sin_vidas jugador2_sin_vidas balas_nuevas paredes enems_anadidos aum_puntaje)))
    (actMundoTick mundo)))


;========================================
; PUNTAJE
;========================================

;1.Contrato:
; list->string : list -> string
; Proposito:
; Esta función retorna una string 
; a partir de una lista ordenada pasada como parámetro.
;2. Contrato:
; organizarRecords: list -> list
; Proposito:
; Esta función organiza una lista de estructuras que representan 
; los puntajes de los jugadores, y los convierte a valores numéricos
; en caso de que estos se presenten como strings.
;3. Contrato:
; mergesort: list -> list
; Proposito:
; Esta función ordena los records, presentados 
; en una lista, descendentemente 
; 4. Contrato:
; anadirPuntajeArch: puntaje -> string
; Proposito:
; Reescribir los records presentes en el fichero externo, a partir de la lista ordenada
;que se recibe desde el mergesort.
(define (anadirPuntajeArch puntaje)
  (local(
         ;1
         (define (list->string l)
           (cond
             [(empty? l) empty]
             [(empty? (rest l)) (string-append (puntaje-nombreJug1 (first l)) ","
                                               (puntaje-nombreJug2 (first l)) ","
                                               (number->string (puntaje-valor (first l))) "\n")]
             [else (string-append (string-append (puntaje-nombreJug1 (first l)) ","
                                                 (puntaje-nombreJug2 (first l)) ","
                                                 (number->string (puntaje-valor (first l))) "\n")
                                  (list->string (rest l)))]))
         ;2
         (define (organizarRecords l)
           (cond
             [(empty? l) empty]
             [(string? (puntaje-valor (first l)))
              (cons (make-puntaje (puntaje-nombreJug1 (first l))
                                  (puntaje-nombreJug2 (first l))
                                  (string->number (puntaje-valor (first l))))
                    (organizarRecords (rest l)))]
             [else (cons (first l) (organizarRecords (rest l)))]))

         ;3.
         (define (merge-sort l)
           (local(
                  (define (partir f l )
                    (cond
                      [(empty? l) empty]
                      [else (f l (floor (/ (length l) 2)))]))
                  (define (merge l1 l2)
                    (cond
                      [(and(empty? l1) (empty? l2)) empty]
                      [(empty? l1) l2]
                      [(empty? l2) l1]
                      [(>= (puntaje-valor (first l1))
                           (puntaje-valor (first l2)))
                       (cons (first l1) (merge (rest l1) l2))]
                      [else (cons (first l2) (merge l1 (rest l2)))]))
                  (define (merge-sort l)
                    (cond
                      [(empty? l) empty]
                      [(empty? (rest l)) l]
                      [else (merge (merge-sort (partir take-right l))
                                   (merge-sort (partir drop-right l)))])))
             (merge-sort l)))
         
         (define listRecordsAnt (puntaje-by-line recordsList))
         (define records (cons puntaje listRecordsAnt))
         (define records_org (organizarRecords records))
         (define records_ordenados (merge-sort records_org))
         (define prims_records (take records_ordenados 5))
         (define records_string (list->string prims_records))
 
         ;4.
         (define (anadirPuntajeArch puntaje)
           (write-file "records.csv" records_string))
         ) (anadirPuntajeArch puntaje)))

;Contrato:
;finJuego?: mundo -> boolean
;Proposito:
;Determinar si la partida ha llegado a su fin, dado el caso que sí, llama la
;función para guardar el puntaje obtenido en el archivo externo y devuelve #true.
(define (finJuego? mundo)
  (define vidas_jug1 (tanque-vida (world-jugador1 mundo)))
  (define vidas_jug2 (tanque-vida (world-jugador2 mundo)))
  (define puntaje (world-puntaje mundo))
  (cond
    [(and (= vidas_jug1 0) (= vidas_jug2 0))
     (anadirPuntajeArch puntaje) #t]
    [else #false]))

;Contrato:
;gameover-scene: mundo -> void
;Proposito:
;Pinta una nueva escena de game over, mostrando el puntaje obtenido y un mensaje de gratitud.
(define (gameover-scene mundo)
  (define puntaje_final (puntaje-valor (world-puntaje mundo)))
  (overlay/align "middle" "middle" 
                 (above (text "GAME OVER." 20 "red")
                        (text "¡Gracias por jugar!" 20 "red")
                        (text "Puntaje Final:" 20 "seagreen")
                        (text (number->string puntaje_final) 20 "seagreen"))
                 (empty-scene ANCHO_TOTAL ALTO_JUEGO "black")))


;========================================
; BIG-BANG
;========================================

;Contrato:
;primerPuntaje: string string -> puntaje
;Proposito:
;Retorna una instancia de puntaje con valores por defecto cuando los campos de textos
;se dejan vacíos, esto con el fin de evitar inconsistencias al pintar los records obtenidos.
(define (primerPuntaje nombre1 nombre2)
  (cond
    [(and (equal? nombre1 "") (not (equal? nombre2 ""))) (make-puntaje "N.N" nombre2 0)]
    [(and (equal? nombre2 "") (not (equal? nombre1 ""))) (make-puntaje nombre1 "N.N" 0)]
    [(and (equal? nombre1 "") (equal? nombre2 "")) (make-puntaje "N.N" "N.N" 0)]
    [else (make-puntaje nombre1 nombre2 0)]))

; Big-Bang que ejecuta el juego.
(define (jugar e)
  (big-bang (make-world JUGADOR1 JUGADOR2 BALAS PAREDES ENEMIGOS (primerPuntaje (text-contents jugador1?) (text-contents jugador2?)))
            (to-draw pintarMundo)
            (on-key actMundoTeclado)
            (on-tick actMundoTick VALOR_TICK)
            (stop-when finJuego? gameover-scene)
            (name "Tank Survivor v1.0")) #t)


;========================================
; GUI
;========================================

; Funciones referentes a GUI
(define titulo
  (make-message "       Tank Survivor"))
 
(define instrucciones
  (make-message "       Objetivo: ¡Sobrevivir a las incansables hordas nazis!  "))
(define instrucciones1
  (make-message "  Cómo jugar(Primer jugador): se mueve con las flechas y dispara con p     
       (Segundo jugador): se mueve con las teclas (W,A,S,D) y dispara con space"))
(define instrucciones2
  (make-message " Los tanque enemigos no pueden ser eliminados por detrás y la dificultad   
       aumentan en proporción al puntaje."))

;Almacena el valor de la caja de texto para JUGADOR1 
(define jugador1?
  (make-text "(Jugador 1)Digite tres letras"))
 
;Almacena el valor de la caja de texto para JUGADOR2
(define jugador2?
  (make-text "(Jugador 2)Digite tres letras"))
 
;Ventana para las cajas de texto
(define (windowPlay e)
  (create-window
   (list
    (list jugador1?)
    (list jugador2?)
    (list (make-button "Jugar" jugar))))#t)
 
;Ventana de Instrucciones
(define (windowInstruc e)
  (create-window
   (list (list instrucciones)
         (list instrucciones1)
         (list instrucciones2)))#t)
 
;Ventana Principal
(define principalWindow
  (create-window
   (list
    (list titulo)
    (list (make-button "Jugar" windowPlay))
    (list (make-button "Cómo jugar" windowInstruc))
    (list (make-button "Salir" (lambda (e) (hide-window principalWindow)))))))

;==============================================================================