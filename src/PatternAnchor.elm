module PatternAnchor exposing (..)

import Json.Decode as Decode exposing (Decoder, field, float, string)
import Vector2 exposing (Vector2)


type alias PatternAnchor a =
    { id : String
    , position : Vector2 a
    }


type alias PagePatternAnchor =
    PatternAnchor Float


type alias GridPatternAnchor =
    PatternAnchor Int


decoder : Decoder PagePatternAnchor
decoder =
    Decode.map2 PatternAnchor
        (field "id" string)
        (Decode.map2 Tuple.pair (field "x" float) (field "y" float))
