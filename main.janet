(import spork/math)
(use sh)
(use jaylib)

(defn main [& args]
  ($ echo "hello")
  (print (math/factorial 3))
  (comment # TODO: figure out how to get this working.
  (init-window 800 600 "Test Game")
  (while (not (window-should-close))
    (begin-drawing)
    (clear-background :raywhite)
    (draw-text "Hello World" 190 200 20 :black)
    (end-drawing))
  (close-window)))
