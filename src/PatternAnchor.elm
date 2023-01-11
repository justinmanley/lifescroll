module PatternAnchor exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy)
import DebugSettings exposing (log)
import Interval exposing (Interval)
import Json.Decode as Decode exposing (Decoder, decodeString, errorToString, field, float, string)
import Life.AtomicUpdateRegion.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells exposing (GridCells)
import Life.Pattern exposing (Pattern)
import Life.PatternRenderingOptions as PatternRenderingOptions
import Life.RleParser as RleParser
import Maybe exposing (withDefault)
import PageCoordinate
import Parser exposing (deadEndsToString)
import Set
import Vector2 exposing (Vector2)


type alias PatternAnchor =
    { id : String
    , patternRle : String
    , renderingOptions : String
    , bounds : BoundingRectangle Float
    }


toPattern : Float -> Interval Float -> PatternAnchor -> Maybe Pattern
toPattern cellSizeInPixels preferredHorizontalRange anchor =
    case RleParser.parse anchor.patternRle of
        Err err ->
            log ("Could not parse pattern " ++ anchor.id ++ deadEndsToString err) Nothing

        Ok cells ->
            case decodeString PatternRenderingOptions.decoder anchor.renderingOptions of
                Err err ->
                    log ("Could not parse rendering options " ++ anchor.id ++ ". " ++ errorToString err) Nothing

                Ok { atomicUpdateRegions, focusRegion } ->
                    let
                        params =
                            { cellSizeInPixels = cellSizeInPixels
                            , preferredHorizontalRange = preferredHorizontalRange
                            , reserved = anchor.bounds
                            }
                    in
                    Just <| layout params cells atomicUpdateRegions focusRegion


type alias PatternLayoutParams =
    { cellSizeInPixels : Float
    , preferredHorizontalRange : Interval Float
    , reserved : BoundingRectangle Float
    }


layout : PatternLayoutParams -> GridCells -> List AtomicUpdateRegion -> Maybe (BoundingRectangle Int) -> Pattern
layout { preferredHorizontalRange, cellSizeInPixels, reserved } cells atomicUpdateRegions focusRegion =
    let
        preferredHorizontalCenter =
            preferredHorizontalRange.start + (Interval.length preferredHorizontalRange / 2)

        topLeftPositionToAlignWithPatternAnchorTopAndCenterHorizontally : BoundingRectangle Int -> Vector2 Int
        topLeftPositionToAlignWithPatternAnchorTopAndCenterHorizontally gridBounds =
            ( PageCoordinate.toGrid cellSizeInPixels preferredHorizontalCenter - BoundingRectangle.width gridBounds // 2 - gridBounds.left
            , PageCoordinate.toGrid cellSizeInPixels (reserved.top + BoundingRectangle.height reserved / 2) - BoundingRectangle.height gridBounds // 2 - gridBounds.top
            )

        initialBounds =
            GridCells.bounds cells |> withDefault (BoundingRectangle.empty 0)

        topLeft =
            topLeftPositionToAlignWithPatternAnchorTopAndCenterHorizontally <|
                (focusRegion |> withDefault initialBounds)

        offsetAtomicUpdateRegion : AtomicUpdateRegion -> AtomicUpdateRegion
        offsetAtomicUpdateRegion atomicUpdateRegion =
            { atomicUpdateRegion
                | bounds = atomicUpdateRegion.bounds |> offsetBy topLeft
            }
    in
    { cells = Set.map (Vector2.add topLeft) cells
    , atomicUpdateRegions = List.map offsetAtomicUpdateRegion atomicUpdateRegions
    }


decoder : Decoder PatternAnchor
decoder =
    Decode.map4 PatternAnchor
        (field "id" string)
        (field "patternRle" string)
        (field "patternRenderingOptionsJson" string)
        (field "bounds" <| BoundingRectangle.decoder float)
