module Graphics.D3.Examples.ForceLayout1 where

import Control.Monad.Eff
import Data.Either
import Data.Foreign
import Data.Foreign.EasyFFI
import Debug.Trace
import Graphics.D3.Base
import Graphics.D3.Layout
import Graphics.D3.Request
import Graphics.D3.Scale
import Graphics.D3.Selection
import Graphics.D3.Util

-- | This is a PureScrit adaptation of the Sticky Force Layout example:
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

type Node = { x :: Number, y :: Number, text :: String }
type Link = { x :: Number, y :: Number }

main :: forall eff. Eff (trace :: Trace, d3 :: D3 | eff) Unit
main = do
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

  json dataUrl (dataHandler force svg drag)

  return unit

tickHandler :: forall eff e a b.
               (Existing e)
            => e a
            -> e b
            -> _
            -> Eff (d3 :: D3 | eff) Unit
tickHandler link node e = do
  link ... attr' "x1" getSourceX
    .. attr' "y1" getSourceY
    .. attr' "x2" getTargetX
    .. attr' "y2" getTargetY

  node ... attr' "cx" getX
    .. attr' "cy" getY
    .. attr' "transform" toTranslate

  return unit

dataHandler :: forall eff a.
               ForceLayout
            -> Selection a
            -> ForceLayout
            -> Either RequestError Foreign
            -> Eff (trace :: Trace, d3 :: D3 | eff) Unit
dataHandler _ _ drag (Left s) = trace $ "Error: " ++ s.statusText
dataHandler force svg drag (Right r) = do
  let v = toGraphData r

  link <- svg ... selectAll ".link"
      .. bind v.links
    .. enter .. append "line"
      .. attr "class" "link"

  node <- svg ... selectAll ".node"
       .. bind v.nodes
    .. enter .. append "g"
      .. attr "class" "node"
      .. onDoubleClick doubleClickHandler
      .. createDrag drag

  append "circle" node
    .. attr "r" 12

  append "text" node
    .. attr "x" 12
    .. attr "dy" ".35em"
    .. text' getText

  force ... nodes v.nodes
    .. links v.links
    .. start

  onTick (tickHandler link node) force

  trace "Handler done"

dragStartHandler :: forall d. d -> D3Eff Unit
dragStartHandler = ffi ["d"] "d3.select(this).classed(\"fixed\", d.fixed = true);"

doubleClickHandler :: forall d. d -> D3Eff Unit
doubleClickHandler = ffi ["d"] "d3.select(this).classed(\"fixed\", d.fixed = false);"

toGraphData :: Foreign -> GraphData
toGraphData = ffi ["g"] "g"

toTranslate :: forall o. o -> String
toTranslate =
  ffi ["o"]
  "'translate(' + o.x + ',' + o.y + ')'"

getText :: forall r. { text :: String | r } -> String
getText o = o.text

getX :: forall o. o -> Number
getX = ffi ["o"] "o.x"

getY :: forall o. o -> Number
getY = ffi ["o"] "o.y"

getSourceX :: forall o. o -> Number
getSourceX = ffi ["o"] "o.source.x"

getSourceY :: forall o. o -> Number
getSourceY = ffi ["o"] "o.source.y"

getTargetX :: forall o. o -> Number
getTargetX = ffi ["o"] "o.target.x"

getTargetY :: forall o. o -> Number
getTargetY = ffi ["o"] "o.target.y"

canvasWidth :: Number
canvasWidth = 800

canvasHeight :: Number
canvasHeight = 600

dataUrl :: String
dataUrl = "data/graph.json"

ffi = unsafeForeignFunction
