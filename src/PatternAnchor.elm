module PatternAnchor exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy)
import DebugSettings exposing (withLogging)
import Json.Decode as Decode exposing (Decoder, field, string)
import Life.GridCells as GridCells exposing (toGrid)
import Life.Pattern exposing (Pattern)
import Life.RleParser as RleParser
import Maybe exposing (withDefault)
import Parser exposing (deadEndsToString)
import Set
import Vector2 exposing (Vector2)


type alias PatternAnchor =
    { id : String
    , patternRle : String
    , bounds : BoundingRectangle Float
    }


toPattern : Float -> BoundingRectangle Float -> PatternAnchor -> Maybe Pattern
toPattern cellSizeInPixels article anchor =
    let
        articleCenter =
            article.left + (BoundingRectangle.width article / 2)

        offset : BoundingRectangle Int -> Vector2 Int
        offset bounds =
            ( toGrid cellSizeInPixels articleCenter - BoundingRectangle.width bounds // 2
            , toGrid cellSizeInPixels (anchor.bounds.top + BoundingRectangle.height anchor.bounds / 2) - BoundingRectangle.height bounds // 2
            )
    in
    case RleParser.parse anchor.patternRle of
        Err err ->
            withLogging True ("Could not parse pattern " ++ anchor.id ++ deadEndsToString err) Nothing

        Ok pattern ->
            let
                initialBounds =
                    GridCells.bounds pattern.cells |> withDefault BoundingRectangle.empty

                start =
                    offset initialBounds
            in
            Just <|
                { cells = Set.map (Vector2.add start) pattern.cells
                , atomicUpdateRegion =
                    { bounds = pattern.atomicUpdateRegion.bounds |> offsetBy start
                    , movement = pattern.atomicUpdateRegion.movement
                    , stepsElapsed = pattern.atomicUpdateRegion.stepsElapsed
                    }
                }


decoder : Decoder PatternAnchor
decoder =
    Decode.map3 PatternAnchor
        (field "id" string)
        (field "rle" string)
        (field "bounds" BoundingRectangle.decoder)
