module Life.Patterns exposing (..)

import Dict
import Life.Pattern exposing (Pattern)
import Life.PatternDict exposing (PatternDict)
import Set


verticalPadding : Int
verticalPadding =
    1


withVerticalPadding : Pattern -> Pattern
withVerticalPadding pattern =
    let
        extent =
            pattern.extent
    in
    { pattern
        | extent =
            { extent
                | height = extent.height + verticalPadding -- at the top
            }
    }


patternDict : PatternDict
patternDict =
    Dict.fromList <|
        List.map (Tuple.mapSecond withVerticalPadding)
            [ ( "beehive"
              , { extent =
                    { height = 3
                    , width = 4
                    }
                , cells =
                    Set.fromList
                        [ ( 1, 0 )
                        , ( 2, 0 )
                        , ( 0, 1 )
                        , ( 3, 1 )
                        , ( 1, 2 )
                        , ( 2, 2 )
                        ]
                }
              )
            , ( "blinker"
              , { extent = { height = 3, width = 3 }
                , cells =
                    Set.fromList
                        [ ( 0, 0 )
                        , ( 0, 1 )
                        , ( 0, 2 )
                        ]
                }
              )
            , ( "little-m"
              , { extent = { height = 10, width = 10 } -- finesse!
                , cells =
                    Set.fromList
                        [ ( 0, 0 )
                        , ( 0, 1 )
                        , ( 0, 2 )
                        , ( 1, 2 )
                        , ( 2, 1 )
                        , ( 3, 2 )
                        , ( 4, 2 )
                        , ( 4, 1 )
                        , ( 4, 0 )
                        ]
                }
              )
            ]
