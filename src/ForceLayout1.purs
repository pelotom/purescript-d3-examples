module Graphics.D3.Examples.ForceLayout1 where

import Control.Monad.Eff
import Data.Either
import Data.Foreign
import Data.Foreign.EasyFFI
import Debug.Trace
import Graphics.D3.Base
import Graphics.D3.Layout.Base
import Graphics.D3.Layout.Force
import Graphics.D3.Request
import Graphics.D3.Scale
import Graphics.D3.Selection
import Graphics.D3.Util

-- | This is a PureScript adaptation of the Sticky Force Layout example:
-- | http://bl.ocks.org/mbostock/3750558

{-

Original JavaScript code:
=========================

var width = 960,
    height = 500;

var force = d3.layout.force()
    .size([width, height])
    .charge(-400)
    .linkDistance(40)
    .on("tick", tick);

var drag = force.drag()
    .on("dragstart", dragstart);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

var link = svg.selectAll(".link"),
    node = svg.selectAll(".node");

d3.json("graph.json", function(error, graph) {
  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();

  link = link.data(graph.links)
    .enter().append("line")
      .attr("class", "link");

  node = node.data(graph.nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", 12)
      .on("dblclick", dblclick)
      .call(drag);
});

function tick() {
  link.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

  node.attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; });
}

function dblclick(d) {
  d3.select(this).classed("fixed", d.fixed = false);
}

function dragstart(d) {
  d3.select(this).classed("fixed", d.fixed = true);
}


  -}

type GraphData =
  { nodes :: [Node]
  , links :: [Link]
  }

type Node = { x :: Number, y :: Number }
type Link = { source :: Node, target :: Node }

main :: forall eff. Eff (trace :: Trace, d3 :: D3 | eff) Unit
main = do
  let canvasWidth = 960
      canvasHeight = 500

  force <- forceLayout
    .. size { width: canvasWidth, height: canvasHeight }
    .. charge (-400)
    .. linkDistance 40

  drag <- force ... drag
    .. onDragStart dragStartHandler

  svg <- rootSelect "body"
    .. append "svg"
    .. attr "width" canvasWidth
    .. attr "height" canvasHeight

  json "data/graph.json" \(Right v) -> do
    let graph = toGraphData v

    force ... nodes graph.nodes
      .. links graph.links
      .. start

    link <- svg ... selectAll ".link"
        .. bind graph.links
      .. enter .. append "line"
        .. attr "class" "link"

    node <- svg ... selectAll ".node"
        .. bind graph.nodes
      .. enter .. append "circle"
        .. attr "class" "node"
        .. attr "r" 12
        .. onDoubleClick doubleClickHandler
        .. createDrag drag
    
    force ... onTick \_ -> do
      link
       ... attr' "x1" (\d -> d.source.x)
        .. attr' "y1" (\d -> d.source.y)
        .. attr' "x2" (\d -> d.target.x)
        .. attr' "y2" (\d -> d.target.y)

      node
       ... attr' "cx" (.x)
        .. attr' "cy" (.y)

dragStartHandler :: forall d. d -> D3Eff Unit
dragStartHandler = ffi ["d"] "d3.select(this).classed('fixed', d.fixed = true);"

doubleClickHandler :: forall d. d -> D3Eff Unit
doubleClickHandler = ffi ["d"] "d3.select(this).classed('fixed', d.fixed = false);"

toGraphData :: Foreign -> GraphData
toGraphData = ffi ["g"] "g"

ffi = unsafeForeignFunction
