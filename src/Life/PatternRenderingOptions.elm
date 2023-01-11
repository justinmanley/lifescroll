module Life.PatternRenderingOptions exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Decode as Decode exposing (Decoder, field, int, list, maybe)
import Life.AtomicUpdateRegion.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)


type alias PatternRenderingOptions =
    { atomicUpdateRegions : List AtomicUpdateRegion

    -- The region of the pattern which should be centered on the page.
    -- As usual, x-coordinates are relative to the leftmost live cell
    -- in the starting pattern, while y-coordinates are relative to
    -- the rightmost live cell in the starting pattern.
    , focusRegion : Maybe (BoundingRectangle Int)
    }


decoder : Decoder PatternRenderingOptions
decoder =
    Decode.map2 PatternRenderingOptions
        (field "atomicUpdateRegions" <| list AtomicUpdateRegion.decoder)
        (maybe <| field "focusRegion" <| BoundingRectangle.decoder int)
