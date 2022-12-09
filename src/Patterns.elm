module Patterns exposing (..)

import Dict
import Life exposing (PatternDict)


patternDict : PatternDict
patternDict =
    Dict.fromList
        [ ( "beehive"
          , [ { row = 0, col = 1 }
            , { row = 0, col = 2 }
            , { row = 1, col = 0 }
            , { row = 1, col = 3 }
            , { row = 2, col = 1 }
            , { row = 2, col = 2 }
            ]
          )
        ]
