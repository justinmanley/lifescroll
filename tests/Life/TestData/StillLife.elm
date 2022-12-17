module Life.TestData.StillLife exposing (..)

import Set exposing (Set)
import Vector2 exposing (Vector2)


type alias StillLife =
    { name : String
    , cells : Set (Vector2 Int)
    }


stillLives : List StillLife
stillLives =
    [ { name = "block"
      , cells =
            Set.fromList
                [ ( 0, 0 ), ( 0, 1 ), ( 1, 1 ), ( 1, 0 ) ]
      }
    , { name = "beehive"
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
    ]
