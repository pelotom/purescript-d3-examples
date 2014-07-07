module Graphics.D3.Examples.LetsMakeABarChart where

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

-- | This is a PureScript adaptation of Mike Bostock's "Let's Make a Bar Chart" series 
-- | of tutorials for D3, which can be found here: http://bost.ocks.org/mike/bar/


-- | Bar Chart 1 - adapted from http://bl.ocks.org/mbostock/7322386
barChart1 = do
  let table = [4, 8, 15, 16, 23, 42]

  x <- linearScale
    .. domain [0, max table]
    .. range [0, 420]
    .. freeze

  rootSelect ".chart"
    .. selectAll "div"
      .. bind table
    .. enter .. append "div"
      .. style "width" (\d -> show (x d) ++ "px")
      .. text show


-- | Bar Chart 2 - adapted from http://bl.ocks.org/mbostock/7341714

type NameAndValue = { name :: String, value :: Number }

coerceNameAndValue :: forall a. a -> D3Eff NameAndValue
coerceNameAndValue = unsafeForeignFunction ["x", ""] "{ name: x.name, value: Number(x.value) }"

barChart2 = do
  let width = 420
      barHeight = 20
      chart = rootSelect ".chart" .. attr "width" (const width)

  tsv "data/namesAndNumbers.tsv" \(Right array) -> do
    typedData <- traverse coerceNameAndValue array

    x <- linearScale
      .. domain [0, maxBy (\d -> d.value) typedData]
      .. range [0, width]
      .. freeze

    chart .. attr "height" (const $ barHeight * length typedData)

    bar <- chart .. selectAll "g"
        .. bind typedData
      .. enter .. append "g"
        .. attr' "transform" (\_ i -> "translate(0," ++ show (i * barHeight) ++ ")")

    bar ... append "rect"
      .. attr "width" (\d -> x d.value)
      .. attr "height" (const $ barHeight - 1)

    bar ... append "text"
      .. attr "x" (\d -> x d.value - 3)
      .. attr "y" (const $ barHeight / 2)
      .. attr "dy" (const ".35em")
      .. text (\d -> show d.value)

-- | Bar Chart 3 - addapted from http://bl.ocks.org/mbostock/3885304

type LetterAndFrequency = { letter :: String, frequency :: Number }

coerceLetterAndFrequency :: forall a. a -> D3Eff LetterAndFrequency
coerceLetterAndFrequency = unsafeForeignFunction ["x", ""] "{ letter: x.letter, frequency: Number(x.frequency) }"

barChart3 = do
  let margin = {top: 20, right: 20, bottom: 30, left: 40}
      width = 960 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      letter x = x.letter
      frequency x = x.frequency

  xScale <- ordinalScale
    .. rangeRoundBands 0 width 0.1 0

  yScale <- linearScale
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

  tsv "data/lettersAndFrequencies.tsv" \(Right array) -> do
    typedData <- traverse coerceLetterAndFrequency array

    xScale ... domain (letter <$> typedData)
    yScale ... domain [0, maxBy frequency typedData]

    x <- freeze xScale
    y <- freeze yScale
    barWidth <- rangeBand xScale

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

    svg ... selectAll ".bar"
        .. bind typedData
      .. enter .. append "rect"
        .. attr "class" (const "bar")
        .. attr "x" (x <<< letter)
        .. attr "width" (const barWidth)
        .. attr "y" (y <<< frequency)
        .. attr "height" (\d -> height - y d.frequency)
