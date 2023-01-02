module Canvas.Renderable exposing (..)

import Canvas exposing (Renderable, shapes)


empty : Renderable
empty =
    shapes [] []
