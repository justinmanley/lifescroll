module PatternDict exposing (..)

import Dict exposing (Dict)
import Json.Encode as Encode
import Pattern exposing (Pattern)


type alias PatternDict =
    Dict String Pattern


encode : PatternDict -> Encode.Value
encode =
    Encode.dict identity Pattern.encode
