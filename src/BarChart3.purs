module Graphics.D3.Examples.BarChart3 where

import Prelude(map,(-),(+),(<>),show,(<$>),(<<<),bind)
import Data.Either
import Data.Array (length)
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

{-

Original JavaScript code:
=========================

var margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .ticks(10, "%");

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.tsv("data.tsv", type, function(error, data) {
  x.domain(data.map(function(d) { return d.letter; }));
  y.domain([0, d3.max(data, function(d) { return d.frequency; })]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Frequency");

  svg.selectAll(".bar")
      .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function(d) { return x(d.letter); })
      .attr("width", x.rangeBand())
      .attr("y", function(d) { return y(d.frequency); })
      .attr("height", function(d) { return height - y(d.frequency); });

});

function type(d) {
  d.frequency = +d.frequency;
  return d;
}

-}

type LetterAndFrequency = { letter :: String, frequency :: Number }

coerceDatum :: forall a. a -> D3Eff LetterAndFrequency
coerceDatum = unsafeForeignFunction ["x", ""] "{ letter: x.letter, frequency: Number(x.frequency) }"

margin = {top: 20.0, right: 20.0, bottom: 30.0, left: 40.0}
width = 960.0 - margin.left - margin.right
height = 500.0 - margin.top - margin.bottom
letter x = x.letter
frequency x = x.frequency

main = do

  xScale <- ordinalScale
    .. rangeRoundBands 0.0 width 0.1 0.0

  yScale <- linearScale
    .. range [height, 0.0]

  xAxis <- axis
    .. scale xScale
    .. orient "bottom"

  yAxis <- axis
    .. scale yScale
    .. orient "left"
    .. ticks 10.0
    .. tickFormat "%"

  svg <- rootSelect "body" .. append "svg"
    .. attr "width" (width + margin.left + margin.right)
    .. attr "height" (height + margin.top + margin.bottom)
    .. append "g"
      .. attr "transform" ("translate(" <> show margin.left <> "," <> show margin.top <> ")")

  tsv "data/lettersAndFrequencies.tsv" \(Right array) -> do
    typedData <- traverse coerceDatum array

    xScale ... domain (letter <$> typedData)
    yScale ... domain [0.0, max' frequency typedData]

    x <- toFunction xScale
    y <- toFunction yScale
    barWidth <- rangeBand xScale

    svg ... append "g"
      .. attr "class" "x axis"
      .. attr "transform" ("translate(0," <> show height <> ")")
      .. renderAxis xAxis

    svg ... append "g"
        .. attr "class" "y axis"
        .. renderAxis yAxis
      .. append   "text"
        .. attr   "transform" "rotate(-90)"
        .. attr   "y" 6.0
        .. attr   "dy" ".71em"
        .. style  "text-anchor" "end"
        .. text   "Frequency"

    svg ... selectAll ".bar"
        .. bindData typedData
      .. enter .. append "rect"
        .. attr  "class" "bar"
        .. attr' "x" (x <<< letter)
        .. attr  "width" barWidth
        .. attr' "y" (y <<< frequency)
        .. attr' "height" (\d -> height - y d.frequency)
