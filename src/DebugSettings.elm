module DebugSettings exposing (..)

import Debug
import Json.Decode as Decode exposing (Decoder, string)
import String exposing (contains)


type alias DebugSettings =
    { atomicUpdateRegions : Bool
    , grid : Bool
    , log : Bool
    }


empty : DebugSettings
empty =
    { atomicUpdateRegions = False
    , grid = False
    , log = False
    }


allEnabled : DebugSettings
allEnabled =
    { atomicUpdateRegions = True
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
            { atomicUpdateRegions = debug |> contains "atomicUpdateRegions"
            , grid = debug |> contains "grid"
            , log = debug |> contains "log"
            }
    in
    Decode.oneOf
        [ Decode.map decodeQueryString string
        , Decode.succeed empty
        ]
