module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import DebugSettings exposing (DebugSettings)
import Json.Decode as Decode exposing (Decoder, field, float, list)
import Life.Pattern exposing (Pattern)
import Maybe exposing (Maybe(..))
import PatternAnchor exposing (PatternAnchor)
import Result exposing (Result(..))


type alias Page =
    { anchors : List PatternAnchor
    , body : BoundingRectangle Float
    , article : BoundingRectangle Float
    , debug : DebugSettings
    , cellSizeInPixels : Float
    }


empty : Page
empty =
    { anchors = []
    , body = BoundingRectangle.empty
    , article = BoundingRectangle.empty
    , debug = DebugSettings.empty
    , cellSizeInPixels = 16 -- web default
    }


decoder : Decoder Page
decoder =
    Decode.map5
        Page
        (field "patterns" (list PatternAnchor.decoder))
        (field "body" BoundingRectangle.decoder)
        (field "article" BoundingRectangle.decoder)
        (field "debug" DebugSettings.decoder)
        (field "cellSizeInPixels" float)


patterns : Page -> List Pattern
patterns { cellSizeInPixels, article, anchors } =
    List.filterMap (PatternAnchor.toPattern cellSizeInPixels article) anchors
