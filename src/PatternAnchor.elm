module PatternAnchor exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy)
import DebugSettings exposing (withLogging)
import Json.Decode as Decode exposing (Decoder, field, string)
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells
import Life.Pattern exposing (Pattern)
import Life.RleParser.RleParser as RleParser
import Maybe exposing (withDefault)
import PageCoordinate
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
            ( PageCoordinate.toGrid cellSizeInPixels articleCenter - BoundingRectangle.width bounds // 2
            , PageCoordinate.toGrid cellSizeInPixels (anchor.bounds.top + BoundingRectangle.height anchor.bounds / 2) - BoundingRectangle.height bounds // 2
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

                offsetAtomicUpdateRegion : AtomicUpdateRegion -> AtomicUpdateRegion
                offsetAtomicUpdateRegion atomicUpdateRegion =
                    { atomicUpdateRegion
                        | bounds = atomicUpdateRegion.bounds |> offsetBy start
                    }
            in
            Just <|
                { cells = Set.map (Vector2.add start) pattern.cells
                , atomicUpdateRegions = List.map offsetAtomicUpdateRegion pattern.atomicUpdateRegions
                }


decoder : Decoder PatternAnchor
decoder =
    Decode.map3 PatternAnchor
        (field "id" string)
        (field "rle" string)
        (field "bounds" BoundingRectangle.decoder)
