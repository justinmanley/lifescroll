module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Decode as Decode exposing (Decoder, field, float, list)
import PatternAnchor exposing (GridPatternAnchor, PagePatternAnchor)
import Tuple exposing (second)


type alias Page =
    { patterns : List PagePatternAnchor
    , body : BoundingRectangle
    , article : BoundingRectangle
    , articleFontSizeInPixels : Float
    }


empty : Page
empty =
    { patterns = []
    , body = BoundingRectangle.empty
    , article = BoundingRectangle.empty
    , articleFontSizeInPixels = 16 -- web default
    }


decoder : Decoder Page
decoder =
    Decode.map4
        Page
        (field "patterns" (list PatternAnchor.decoder))
        (field "body" BoundingRectangle.decoder)
        (field "article" BoundingRectangle.decoder)
        (field "articleFontSizeInPixels" float)


patternAnchorToGrid : Page -> PagePatternAnchor -> GridPatternAnchor
patternAnchorToGrid page pattern =
    let
        articleCenter =
            page.article.left + (BoundingRectangle.width page.article / 2)

        row =
            second pattern.position / page.articleFontSizeInPixels |> floor

        col =
            articleCenter / page.articleFontSizeInPixels |> floor
    in
    { id = pattern.id
    , side = pattern.side -- no longer necessary, but that's ok
    , position = ( row, col )
    }


gridPatternAnchors : Page -> List GridPatternAnchor
gridPatternAnchors page =
    List.map (patternAnchorToGrid page) page.patterns
