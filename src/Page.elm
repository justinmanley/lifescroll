module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Decode as Decode exposing (Decoder, field, float, list)
import Life.BoundedGridCells exposing (BoundedGridCells)
import Life.Pattern as Pattern exposing (Pattern, withVerticalPadding)
import Life.RleParser as RleParser
import Maybe exposing (Maybe(..))
import PatternAnchor exposing (PatternAnchor)
import Result exposing (Result(..))
import Set
import Vector2 exposing (Vector2)


type alias Page =
    { patterns : List PatternAnchor
    , body : BoundingRectangle Float
    , article : BoundingRectangle Float
    , cellSizeInPixels : Float
    }


empty : Page
empty =
    { patterns = []
    , body = BoundingRectangle.empty
    , article = BoundingRectangle.empty
    , cellSizeInPixels = 16 -- web default
    }


decoder : Decoder Page
decoder =
    Decode.map4
        Page
        (field "patterns" (list PatternAnchor.decoder))
        (field "body" BoundingRectangle.decoder)
        (field "article" BoundingRectangle.decoder)
        (field "cellSizeInPixels" float)


patternAnchorToGridCells : Page -> PatternAnchor -> Maybe BoundedGridCells
patternAnchorToGridCells page anchor =
    let
        articleCenter =
            page.article.left + (BoundingRectangle.width page.article / 2)

        toGrid : Float -> Int
        toGrid f =
            f / page.cellSizeInPixels |> floor

        offset : Pattern -> Vector2 Int
        offset pattern =
            ( toGrid articleCenter - pattern.extent.width // 2
            , toGrid anchor.bounds.top + Pattern.verticalPadding
            )
    in
    case Result.map withVerticalPadding <| RleParser.parse anchor.patternRle of
        Err err ->
            Debug.log ("Could not parse pattern " ++ anchor.id ++ Debug.toString err) Nothing

        Ok pattern ->
            let
                start =
                    offset pattern

                ( left, top ) =
                    start
            in
            Just <|
                { cells = Set.map (Vector2.add start) pattern.cells
                , bounds =
                    { top = top
                    , left = left
                    , bottom = top + pattern.extent.height
                    , right = left + pattern.extent.width
                    }
                }


gridCells : Page -> List BoundedGridCells
gridCells page =
    List.filterMap (patternAnchorToGridCells page) page.patterns
