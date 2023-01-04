module DebugSettings exposing (..)

import Debug
import Json.Decode as Decode exposing (Decoder, string)
import String exposing (contains)


type alias DebugSettings =
    { atomicUpdates : Bool
    , reserved : Bool
    , layout : Bool
    , grid : Bool
    , log : Bool
    }


empty : DebugSettings
empty =
    { atomicUpdates = False
    , reserved = False
    , layout = False
    , grid = False
    , log = False
    }


allEnabled : DebugSettings
allEnabled =
    { atomicUpdates = True
    , layout = True
    , reserved = True
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
            { atomicUpdates = debug |> contains "atomic-updates"
            , reserved = debug |> contains "reserved"
            , layout = debug |> contains "layout"
            , grid = debug |> contains "grid"
            , log = debug |> contains "log"
            }
    in
    Decode.oneOf
        [ Decode.map decodeQueryString string
        , Decode.succeed empty
        ]
