module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Dict
import Json.Decode as Decode exposing (Decoder, field, float, list)
import Maybe exposing (Maybe(..))
import Pattern exposing (GridCells)
import PatternAnchor exposing (PagePatternAnchor)
import PatternDict exposing (PatternDict)
import Set
import Size2 exposing (Size2)
import Vector2 exposing (Vector2, x, y)


type alias Page =
    { patterns : List PagePatternAnchor
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


toAnchoredPattern : Page -> PatternDict -> PagePatternAnchor -> Maybe GridCells
toAnchoredPattern page patterns anchor =
    let
        articleCenter =
            page.article.left + (BoundingRectangle.width page.article / 2)

        toGrid : Float -> Int
        toGrid f =
            f / page.cellSizeInPixels |> floor

        offset =
            Vector2.map toGrid
                ( articleCenter
                , y anchor.position
                )

        addHalfToY : Vector2 Int -> Int -> Vector2 Int
        addHalfToY ( x2, y2 ) y1 =
            ( x2, y1 // 2 + y2 )
    in
    case Dict.get anchor.id patterns of
        Nothing ->
            Debug.log ("Could not find pattern for id " ++ anchor.id) Nothing

        Just pattern ->
            Just <| Set.map (Vector2.add <| addHalfToY offset pattern.extent.height) pattern.cells


anchoredPatterns : Page -> PatternDict -> List GridCells
anchoredPatterns page patterns =
    List.filterMap (toAnchoredPattern page patterns) page.patterns
