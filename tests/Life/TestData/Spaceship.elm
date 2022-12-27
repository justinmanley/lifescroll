module Life.TestData.Spaceship exposing (..)

import Set exposing (Set)
import Vector2 exposing (Vector2)


type alias Spaceship =
    { name : String
    , cells : Set (Vector2 Int)
    , period : Int
    , direction : Vector2 Int
    }


glider : Spaceship
glider =
    { name = "glider"
    , cells =
        Set.fromList
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 2, 1 )
            , ( 1, 2 )
            ]
    , period = 4
    , direction = ( 1, -1 )
    }


spaceships : List Spaceship
spaceships =
    [ glider
    , { name = "lightweight spaceship"
      , cells =
            Set.fromList
                [ ( 0, 1 )
                , ( 0, 3 )
                , ( 1, 0 )
                , ( 2, 0 )
                , ( 3, 0 )
                , ( 4, 0 )
                , ( 4, 1 )
                , ( 4, 2 )
                , ( 3, 3 )
                ]
      , period = 4
      , direction = ( 2, 0 )
      }
    ]
