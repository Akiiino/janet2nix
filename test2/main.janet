(use jaylib)

(defn main [& args]
  (init-window 800 600 "Test Game")
  (while (not (window-should-close))
    (begin-drawing)
    (clear-background :black)
    (draw-text "Hello World" 190 200 20 :white)
    (end-drawing))
  (close-window))
