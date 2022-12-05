module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Decode as Decode exposing (Decoder, field, float, list)
import PatternAnchor exposing (PatternAnchor)


type alias Page =
    { patterns : List PatternAnchor
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
