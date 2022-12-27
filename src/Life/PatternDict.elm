module Life.PatternDict exposing (..)

import Dict exposing (Dict)
import Json.Encode as Encode
import Life.Pattern as Pattern exposing (Pattern)


type alias PatternDict =
    Dict String Pattern


encode : PatternDict -> Encode.Value
encode =
    Encode.dict identity Pattern.encode
