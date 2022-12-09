module Patterns exposing (..)

import Dict
import PatternDict exposing (PatternDict)


patternDict : PatternDict
patternDict =
    Dict.fromList
        [ ( "beehive"
          , { extent =
                { height = 3
                , width = 4
                }
            , cells =
                [ { x = 1, y = 0 }
                , { x = 2, y = 0 }
                , { x = 0, y = 1 }
                , { x = 3, y = 1 }
                , { x = 1, y = 2 }
                , { x = 2, y = 2 }
                ]
            }
          )
        ]
