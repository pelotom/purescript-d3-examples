module Graphics.D3.Examples.LetsMakeABarChart where

import Data.Either
import Data.Array (length)
import Data.Foreign
import Data.Foreign.EasyFFI

import Graphics.D3.Util
import Graphics.D3.Selection
import Graphics.D3.Scale
import Graphics.D3.Request

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

type NameValuePair = { name :: String, value :: Number }

castNVP :: forall a. a -> NameValuePair
castNVP = unsafeForeignFunction ["x"] "{ name: x.name, value: Number(x.value) }"

barChart2 = do
  let width = 420
      barHeight = 20
      chart = rootSelect ".chart" .. attr "width" (const width)

  tsv "data/barChart2.tsv" $ \(Right array) -> do
    let typedData = castNVP <$> array

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
