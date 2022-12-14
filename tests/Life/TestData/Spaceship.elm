module Life.TestData.Spaceship exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Life.AtomicUpdateRegion.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.AtomicUpdateRegion.BoundingRectangleEdgeMovements exposing (BoundingRectangleEdgeMovements)
import Life.AtomicUpdateRegion.Movement2 exposing (Movement2)
import Life.AtomicUpdateRegion.StepCriterion exposing (StepCriterion(..))
import Life.Life exposing (LifeGrid)
import Life.Pattern exposing (Pattern)
import Life.Viewport exposing (numProtectedBottomCells)
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
        { period = 4
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
        { period = 4
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
    , movement : Movement2
    , atomicUpdateBounds : BoundingRectangle Int
    }


toPattern : Spaceship -> Pattern
toPattern spaceship =
    let
        cells =
            Set.fromList spaceship.cells
    in
    { cells = cells
    , atomicUpdateRegions = [ toAtomicUpdateRegion spaceship ]
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
    , boundsEdgeMovements = BoundingRectangle.empty Nothing
    , stepCriterion = FullyContainedWithinSteppableRegion
    , stepsElapsed = 0
    }


inViewFor : Int -> Spaceship -> BoundingRectangle Int
inViewFor numSteps { atomicUpdateBounds, movement } =
    { top = atomicUpdateBounds.top + (min 0 <| y movement.direction) * numSteps // movement.period
    , left = atomicUpdateBounds.left + (min 0 <| x movement.direction) * numSteps // movement.period
    , bottom = atomicUpdateBounds.bottom + (max 0 <| y movement.direction) * numSteps // movement.period + 1 + numProtectedBottomCells
    , right = atomicUpdateBounds.right + (max 0 <| x movement.direction) * numSteps // movement.period + 1
    }


spaceships : List Spaceship
spaceships =
    [ glider
    , lightweightSpaceship
    ]
