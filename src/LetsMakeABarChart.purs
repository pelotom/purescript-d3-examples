module Graphics.D3.Examples.LetsMakeABarChart where

import Graphics.D3.Util
import Graphics.D3.Selection
import Graphics.D3.Scale

{- 
  This is a PureScript adaptation of Mike Bostock's "Let's Make a Bar Chart" series
  of tutorials for D3, which can be found here: http://bost.ocks.org/mike/bar/
-}

{-
  Bar Chart 1 - adapted from http://bl.ocks.org/mbostock/7322386
  
  JavaScript version:
  ===================
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
