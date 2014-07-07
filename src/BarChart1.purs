module Graphics.D3.Examples.BarChart1 where

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

-- | This is a PureScript adaptation of part 1 of Mike Bostock's "Let's Make a Bar Chart" series:
-- | http://bost.ocks.org/mike/bar/1/

{-

Original JavaScript code:
=========================

var data = [4, 8, 15, 16, 23, 42];

var x = d3.scale.linear()
    .domain([0, d3.max(data)])
    .range([0, 420]);

d3.select(".chart")
  .selectAll("div")
    .data(data)
  .enter().append("div")
    .style("width", function(d) { return x(d) + "px"; })
    .text(function(d) { return d; });

-}

table = [4, 8, 15, 16, 23, 42]

main = do

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
