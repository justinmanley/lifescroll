module Page exposing (..)

import BoundingRectangle exposing (BoundingRectangle, horizontal)
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
    , body = BoundingRectangle.empty 0
    , article = BoundingRectangle.empty 0
    , debug = DebugSettings.empty
    , cellSizeInPixels = 16 -- web default
    }


decoder : Decoder Page
decoder =
    Decode.map5
        Page
        (field "patterns" (list PatternAnchor.decoder))
        (field "body" <| BoundingRectangle.decoder float)
        (field "article" <| BoundingRectangle.decoder float)
        (field "debug" DebugSettings.decoder)
        (field "cellSizeInPixels" float)


patterns : Page -> List Pattern
patterns { cellSizeInPixels, article, anchors } =
    List.filterMap (PatternAnchor.toPattern cellSizeInPixels <| horizontal article) anchors
