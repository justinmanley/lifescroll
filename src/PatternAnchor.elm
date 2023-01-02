module PatternAnchor exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import DebugSettings exposing (withLogging)
import Json.Decode as Decode exposing (Decoder, field, string)
import Life.Pattern as Pattern exposing (Pattern, withVerticalPadding)
import Life.RleParser as RleParser
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

        toGrid : Float -> Int
        toGrid f =
            f / cellSizeInPixels |> floor

        offset : Pattern -> Vector2 Int
        offset pattern =
            ( toGrid articleCenter - pattern.extent.width // 2
            , toGrid anchor.bounds.top + Pattern.verticalPadding
            )
    in
    case Result.map withVerticalPadding <| RleParser.parse anchor.patternRle of
        Err err ->
            withLogging True ("Could not parse pattern " ++ anchor.id ++ deadEndsToString err) Nothing

        Ok pattern ->
            let
                start =
                    offset pattern

                ( left, top ) =
                    start
            in
            Just <|
                { cells = Set.map (Vector2.add start) pattern.cells
                , extent = pattern.extent
                , atomicUpdateRegion =
                    { bounds =
                        { top = top + pattern.atomicUpdateRegion.bounds.top
                        , left = left + pattern.atomicUpdateRegion.bounds.left
                        , bottom = top + BoundingRectangle.height pattern.atomicUpdateRegion.bounds
                        , right = left + BoundingRectangle.width pattern.atomicUpdateRegion.bounds
                        }
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
