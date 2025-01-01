(import spork/math)
(use sh)
(use jaylib)

(defn main [& args]
  ($ echo "hello")
  (print (math/factorial 3))
  (init-window 800 600 "Test Game")
  (while (not (window-should-close))
    (begin-drawing)
    (clear-background :black)
    (draw-text "Hello World" 190 200 20 :white)
    (end-drawing))
  (close-window))
