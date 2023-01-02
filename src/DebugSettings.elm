module DebugSettings exposing (..)

import Debug
import Json.Decode as Decode exposing (Decoder, string)
import String exposing (contains)


type alias DebugSettings =
    { protected : Bool
    , grid : Bool
    , log : Bool
    }


empty : DebugSettings
empty =
    { protected = False
    , grid = False
    , log = False
    }


allEnabled : DebugSettings
allEnabled =
    { protected = True
    , grid = True
    , log = True
    }


withLogging : Bool -> String -> a -> a
withLogging enabled message =
    if enabled then
        Debug.log message

    else
        identity


decoder : Decoder DebugSettings
decoder =
    let
        decodeQueryString : String -> DebugSettings
        decodeQueryString debug =
            { protected = debug |> contains "protected"
            , grid = debug |> contains "grid"
            , log = debug |> contains "log"
            }
    in
    Decode.map decodeQueryString string
