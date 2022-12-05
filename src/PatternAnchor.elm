module PatternAnchor exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, field, float, string)


type alias PatternAnchor =
    { id : String
    , side : Side
    , x : Float
    , y : Float
    }


decoder : Decoder PatternAnchor
decoder =
    Decode.map4 PatternAnchor
        (field "id" string)
        (field "side" string |> andThen sideDecoder)
        (field "x" float)
        (field "y" float)


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
