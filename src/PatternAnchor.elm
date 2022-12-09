module PatternAnchor exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, field, float, string)


type alias PatternAnchor a =
    { id : String
    , side : Side
    , position : ( a, a )
    }


type alias PagePatternAnchor =
    PatternAnchor Float


decoder : Decoder PagePatternAnchor
decoder =
    Decode.map3 PatternAnchor
        (field "id" string)
        (field "side" string |> andThen sideDecoder)
        (Decode.map2 Tuple.pair (field "x" float) (field "y" float))


type Side
    = Left
    | Right


sideDecoder : String -> Decoder Side
sideDecoder side =
    case side of
        "left" ->
            Decode.succeed Left

        "right" ->
            Decode.succeed Right

        _ ->
            Decode.fail ""
