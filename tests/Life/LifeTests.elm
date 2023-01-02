module Life.LifeTests exposing (..)

import Expect exposing (Expectation)
import Life.Life as Life
import Life.TestData.Spaceship exposing (Spaceship, spaceships)
import Life.TestData.StillLife exposing (StillLife, stillLives)
import Loop exposing (for)
import Set exposing (Set)
import Test exposing (Test, describe, test)
import Vector2


suite : Test
suite =
    describe "Life"
        [ describe "next"
            [ describe "still lives" <|
                List.map testStillLifeDoesNotChange stillLives
            , describe "spaceships" <|
                List.map testSpaceshipIsDisplacedAfterPeriod spaceships
            ]
        ]


testStillLifeDoesNotChange : StillLife -> Test
testStillLifeDoesNotChange { name, cells } =
    test ("still life " ++ name ++ " does not change") <|
        \_ -> Expect.equal cells (Life.next cells)


testSpaceshipIsDisplacedAfterPeriod : Spaceship -> Test
testSpaceshipIsDisplacedAfterPeriod { name, cells, movement } =
    test ("spaceship " ++ name ++ " is displaced by " ++ Vector2.toString (Vector2.map String.fromInt movement.direction) ++ "after " ++ String.fromInt movement.period) <|
        \_ ->
            Expect.equal
                (Set.map (Vector2.fold (+) movement.direction) (Set.fromList cells))
                (for movement.period Life.next (Set.fromList cells))
