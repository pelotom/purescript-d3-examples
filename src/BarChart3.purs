module Graphics.D3.Examples.BarChart3 where

import Data.Either
import Data.Maybe
import Data.Array (length, (!!))
import Data.Traversable
import Data.Foreign
import Data.Foreign.EasyFFI

import Graphics.D3.Base
import Graphics.D3.Util
import Graphics.D3.Selection
import Graphics.D3.Scale
import Graphics.D3.Request
import Graphics.D3.SVG.Axis

-- | This is a PureScript adaptation of part 3 of Mike Bostock's "Let's Make a Bar Chart" series:
-- | http://bost.ocks.org/mike/bar/3/


type LetterAndFrequency = { letter :: String, frequency :: Number }

coerceLetterAndFrequency :: forall a. a -> D3Eff LetterAndFrequency
coerceLetterAndFrequency = unsafeForeignFunction ["x", ""] "{ letter: x.letter, frequency: Number(x.frequency) }"

margin = {top: 20, right: 20, bottom: 30, left: 40}
width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom
letter x = x.letter
frequency x = x.frequency

main = tsv "data/lettersAndFrequencies.tsv" \(Right array) -> do
  typedData <- traverse coerceLetterAndFrequency array

  xScale <- ordinalScale
    .. domain (letter <$> typedData)
    .. rangeRoundBands 0 width 0.1 0

  yScale <- linearScale
    .. domain [0, maxBy frequency typedData]
    .. range [height, 0]

  xAxis <- axis
    .. scale xScale
    .. orient "bottom"

  yAxis <- axis
    .. scale yScale
    .. orient "left"
    .. ticks 10
    .. tickFormat "%"

  svg <- rootSelect "body" .. append "svg"
    .. attr "width" (const $ width + margin.left + margin.right)
    .. attr "height" (const $ height + margin.top + margin.bottom)
    .. append "g"
      .. attr "transform" (const $ "translate(" ++ show margin.left ++ "," ++ show margin.top ++ ")")

  svg ... append "g"
    .. attr "class" (const "x axis")
    .. attr "transform" (const $ "translate(0," ++ show height ++ ")")
    .. renderAxis xAxis

  svg ... append "g"
      .. attr "class" (const "y axis")
      .. renderAxis yAxis
    .. append "text"
      .. attr "transform" (const "rotate(-90)")
      .. attr "y" (const 6)
      .. attr "dy" (const ".71em")
      .. style "text-anchor" (const "end")
      .. text (const "Frequency")

  x <- freeze xScale
  y <- freeze yScale
  barWidth <- rangeBand xScale

  svg ... selectAll ".bar"
      .. bind typedData
    .. enter .. append "rect"
      .. attr "class" (const "bar")
      .. attr "x" (x <<< letter)
      .. attr "width" (const barWidth)
      .. attr "y" (y <<< frequency)
      .. attr "height" (\d -> height - y d.frequency)
