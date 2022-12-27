module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Dict
import Json.Decode as Decode exposing (Decoder, field, float, list)
import Maybe exposing (Maybe(..))
import Pattern exposing (GridCells, Pattern)
import PatternAnchor exposing (PatternAnchor)
import PatternDict exposing (PatternDict)
import Patterns exposing (verticalPadding)
import Set
import Vector2 exposing (Vector2)


type alias Page =
    { patterns : List PatternAnchor
    , body : BoundingRectangle
    , article : BoundingRectangle
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


patternAnchorToGridCells : Page -> PatternDict -> PatternAnchor -> Maybe GridCells
patternAnchorToGridCells page patterns anchor =
    let
        articleCenter =
            page.article.left + (BoundingRectangle.width page.article / 2)

        toGrid : Float -> Int
        toGrid f =
            f / page.cellSizeInPixels |> floor

        offset : Pattern -> Vector2 Int
        offset pattern =
            ( toGrid articleCenter - pattern.extent.width // 2
            , toGrid anchor.bounds.top + verticalPadding
            )
    in
    case Dict.get anchor.id patterns of
        Nothing ->
            Debug.log ("Could not find pattern for id " ++ anchor.id) Nothing

        Just pattern ->
            Just <| Set.map (Vector2.add <| offset pattern) pattern.cells


gridCells : Page -> PatternDict -> List GridCells
gridCells page patterns =
    List.filterMap (patternAnchorToGridCells page patterns) page.patterns
