module Graphics.D3.Examples.Rectangles where

import Graphics.D3.Selection

drawRects array =
  selectAll "svg" $ bind [1] do
    enter $ append "svg" $ append "rect" do
      attr "width" 500
      attr "height" 500
      attr "fill" "gray"
    selectAll ".others" $ bind array do
      enter do
        append "rect" do
          attr "class" "others"
          attr "fill" \d -> if d > 4 then "blue" else "red"
          attr "stroke" "black"
          attr "x" \d -> d * 13
          attr "y" \d -> d * 20
          attr "opacity" 1
          attr "width" \d -> d * 60
          attr "height" \d -> d * 50
        append "circle" do
          attr "cx" \d -> d * 13
          attr "cy" \d -> d * 20
          attr "r" 10
          attr "fill" "green"
      exit $ transition do
        attr "opacity" 0
        remove

main = drawRects [1,2,3,4,5,6,7]

