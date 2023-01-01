module Life.LifeTests exposing (..)

import Expect exposing (Expectation)
import Life.BoundedGridCells exposing (BoundedGridCells)
import Life.Life as Life exposing (insertPattern)
import Life.TestData.Spaceship exposing (Spaceship, spaceships)
import Life.TestData.StillLife exposing (StillLife, stillLives)
import Loop exposing (for)
import Set exposing (Set)
import Test exposing (Test, describe, test)
import Vector2


testPattern : BoundedGridCells
testPattern =
    { cells =
        Set.fromList
            [ ( 0, 0 )
            , ( 1, 0 )
            ]
    , bounds =
        { top = 0
        , left = 0
        , right = 1
        , bottom = 0
        }
    }


expectEqualSize : Set a -> Set b -> Expectation
expectEqualSize expected actual =
    Expect.equal (Set.size expected) (Set.size actual)


testStillLifeDoesNotChange : StillLife -> Test
testStillLifeDoesNotChange { name, cells } =
    test ("still life " ++ name ++ " does not change") <|
        \_ -> Expect.equal cells (Life.next cells)


testSpaceshipIsDisplacedAfterPeriod : Spaceship -> Test
testSpaceshipIsDisplacedAfterPeriod { name, cells, period, direction } =
    test ("spaceship " ++ name ++ " is displaced by " ++ Vector2.toString (Vector2.map String.fromInt direction) ++ "after " ++ String.fromInt period) <|
        \_ -> Expect.equal (Set.map (Vector2.fold (+) direction) cells) (for period Life.next cells)


suite : Test
suite =
    describe "Life"
        [ describe "addPattern"
            [ test "inserts every cell in a pattern into an empty set of GridCells" <|
                \_ ->
                    let
                        grid =
                            insertPattern testPattern Life.empty
                    in
                    expectEqualSize testPattern.cells grid.cells
            ]
        , describe "next"
            [ describe "still lives" <|
                List.map testStillLifeDoesNotChange stillLives
            , describe "spaceships" <|
                List.map testSpaceshipIsDisplacedAfterPeriod spaceships
            ]
        ]
