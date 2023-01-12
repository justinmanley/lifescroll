module Life.TestData.Oscillator exposing (..)

import Vector2 exposing (Vector2)


type alias Oscillator =
    { name : String
    , cells : List (Vector2 Int)
    , period : Int
    }


oscillators : List Oscillator
oscillators =
    [ { name = "blinker"
      , cells = [ ( 0, 0 ), ( 0, 1 ), ( 0, 2 ) ]
      , period = 2
      }
    , { name = "pentadecathlon"
      , cells =
            [ ( 0, 1 ) -- Represents the Pentadecathlon in this phase:
            , ( 1, 1 ) --     o    o
            , ( 2, 0 ) --   oo oooo oo
            , ( 2, 2 ) --     o    o
            , ( 3, 1 )
            , ( 4, 1 )
            , ( 5, 1 )
            , ( 6, 1 )
            , ( 7, 0 )
            , ( 7, 2 )
            , ( 8, 1 )
            , ( 9, 1 )
            ]
      , period = 15
      }
    ]
