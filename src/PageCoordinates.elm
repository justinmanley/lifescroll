module PageCoordinates exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import PageCoordinate
import Vector2 exposing (Vector2)


type alias PageBounds =
    BoundingRectangle Float


type alias PagePosition =
    Vector2 Float


toGrid : Float -> PageBounds -> BoundingRectangle Int
toGrid cellSizeInPixels { top, left, bottom, right } =
    { top = PageCoordinate.toGrid cellSizeInPixels top
    , left = PageCoordinate.toGrid cellSizeInPixels left
    , bottom = PageCoordinate.toGrid cellSizeInPixels bottom
    , right = PageCoordinate.toGrid cellSizeInPixels right
    }
