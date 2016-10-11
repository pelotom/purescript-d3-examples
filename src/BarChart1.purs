module Graphics.D3.Examples.BarChart1 where

import Prelude(id,(<>),show,unit,Unit(),(>>=),bind)
import Graphics.D3.Base
import Graphics.D3.Util
import Graphics.D3.Selection
import Graphics.D3.Scale

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

array = [4.0, 8.0, 15.0, 16.0, 23.0, 42.0]

main = do
  x <- linearScale
    .. domain [0.0, max' id array]
    .. range [0.0, 420.0]
    .. toFunction

  rootSelect ".chart"
    .. selectAll "div"
      .. bindData array
    .. enter .. append "div"
      .. style' "width" (\d -> show (x d) <> "px")
      .. text' show
