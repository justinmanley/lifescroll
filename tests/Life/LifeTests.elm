module Life.LifeTests exposing (..)

import Expect exposing (Expectation)
import Life.Life as Life exposing (insertPattern)
import Life.TestData.Spaceship exposing (Spaceship, spaceships)
import Life.TestData.StillLife exposing (StillLife, stillLives)
import Loop exposing (for)
import Set exposing (Set)
import Test exposing (Test, describe, test)
import Vector2 exposing (Vector2)


testPattern : Set (Vector2 Int)
testPattern =
    Set.fromList
        [ ( 0, 0 )
        , ( 1, 0 )
        ]


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
                    insertPattern testPattern Life.empty
                        |> expectEqualSize testPattern
            ]
        , describe "next"
            [ describe "still lives" <|
                List.map testStillLifeDoesNotChange stillLives
            , describe "spaceships" <|
                List.map testSpaceshipIsDisplacedAfterPeriod spaceships
            ]
        ]
