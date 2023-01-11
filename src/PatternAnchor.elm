module PatternAnchor exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy)
import DebugSettings exposing (log)
import Json.Decode as Decode exposing (Decoder, decodeString, errorToString, field, float, list, string)
import Life.AtomicUpdateRegion.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells
import Life.Pattern exposing (Pattern)
import Life.RleParser as RleParser
import Maybe exposing (withDefault)
import PageCoordinate
import Parser exposing (deadEndsToString)
import Set
import Vector2 exposing (Vector2)


type alias PatternAnchor =
    { id : String
    , patternRle : String
    , atomicUpdateRegionsJson : String
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
            log ("Could not parse pattern " ++ anchor.id ++ deadEndsToString err) Nothing

        Ok cells ->
            let
                initialBounds =
                    GridCells.bounds cells |> withDefault (BoundingRectangle.empty 0)

                start =
                    offset initialBounds

                offsetAtomicUpdateRegion : AtomicUpdateRegion -> AtomicUpdateRegion
                offsetAtomicUpdateRegion atomicUpdateRegion =
                    { atomicUpdateRegion
                        | bounds = atomicUpdateRegion.bounds |> offsetBy start
                    }
            in
            case decodeString (list AtomicUpdateRegion.decoder) anchor.atomicUpdateRegionsJson of
                Err err ->
                    log ("Could not parse atomic update regions " ++ anchor.id ++ ". " ++ errorToString err) Nothing

                Ok atomicUpdateRegions ->
                    Just <|
                        { cells = Set.map (Vector2.add start) cells
                        , atomicUpdateRegions = List.map offsetAtomicUpdateRegion atomicUpdateRegions
                        }


decoder : Decoder PatternAnchor
decoder =
    Decode.map4 PatternAnchor
        (field "id" string)
        (field "patternRle" string)
        (field "atomicUpdateRegionsJson" string)
        (field "bounds" <| BoundingRectangle.decoder float)
