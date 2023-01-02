module Life.TestData.Spaceship exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion, Movement)
import Life.Life exposing (LifeGrid)
import Life.Pattern exposing (Pattern)
import Set
import Vector2 exposing (Vector2, x, y)


glider : Spaceship
glider =
    { name = "glider"
    , cells =
        [ ( 0, 0 )
        , ( 1, 0 )
        , ( 2, 0 )
        , ( 2, 1 )
        , ( 1, 2 )
        ]
    , movement =
        { speed = 4
        , direction = ( 1, -1 )
        }
    , atomicUpdateBounds =
        { top = -1
        , left = 0
        , bottom = 2
        , right = 3
        }
    }


lightweightSpaceship : Spaceship
lightweightSpaceship =
    { name = "lightweight spaceship"
    , cells =
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
    , movement =
        { speed = 4
        , direction = ( 2, 0 )
        }
    , atomicUpdateBounds =
        { top = 0
        , left = 0
        , bottom = 4
        , right = 3
        }
    }


type alias Spaceship =
    { name : String
    , cells : List (Vector2 Int)
    , movement : Movement
    , atomicUpdateBounds : BoundingRectangle Int
    }


toPattern : Spaceship -> Pattern
toPattern spaceship =
    let
        bounds =
            { top = List.foldl (y >> min) 0 spaceship.cells
            , left = List.foldl (x >> min) 0 spaceship.cells
            , bottom = List.foldl (y >> max) 0 spaceship.cells
            , right = List.foldl (x >> max) 0 spaceship.cells
            }
    in
    { cells = Set.fromList spaceship.cells
    , extent =
        { width = BoundingRectangle.width bounds
        , height = BoundingRectangle.height bounds
        }
    , atomicUpdateRegion = toAtomicUpdateRegion spaceship
    }


toLifeGrid : Spaceship -> LifeGrid
toLifeGrid spaceship =
    { cells = Set.fromList spaceship.cells
    , atomicUpdateRegions = [ toAtomicUpdateRegion spaceship ]
    }


toAtomicUpdateRegion : Spaceship -> AtomicUpdateRegion
toAtomicUpdateRegion spaceship =
    { movement = Just spaceship.movement
    , bounds = spaceship.atomicUpdateBounds
    , stepsElapsed = 0
    }


inViewFor : Int -> Spaceship -> BoundingRectangle Int
inViewFor numSteps { atomicUpdateBounds, movement } =
    { top = atomicUpdateBounds.top + (min 0 <| y movement.direction) * numSteps // movement.speed
    , left = atomicUpdateBounds.left + (min 0 <| x movement.direction) * numSteps // movement.speed
    , bottom = atomicUpdateBounds.left + (max 0 <| y movement.direction) * numSteps // movement.speed
    , right = atomicUpdateBounds.left + (max 0 <| x movement.direction) * numSteps // movement.speed
    }


spaceships : List Spaceship
spaceships =
    [ glider
    , lightweightSpaceship
    ]
