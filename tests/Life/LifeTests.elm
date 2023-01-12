module Life.LifeTests exposing (..)

import Expect
import Fuzz exposing (intRange)
import Life.Life as Life
import Life.TestData.Oscillator exposing (Oscillator, oscillators)
import Life.TestData.Spaceship exposing (Spaceship, spaceships)
import Life.TestData.StillLife exposing (StillLife, stillLives)
import Loop exposing (for)
import Set
import Test exposing (Test, describe, fuzz, test)
import Vector2


suite : Test
suite =
    describe "Life"
        [ describe "next"
            [ describe "still lives" <|
                List.map testStillLifeDoesNotChange stillLives
            , describe "oscillators" <|
                List.map testOscillatorChangesAndThenReturnsToOriginalAfterPeriod oscillators
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
    test ("spaceship " ++ name ++ " is displaced by " ++ Vector2.toString String.fromInt movement.direction ++ " after " ++ String.fromInt movement.period) <|
        \_ ->
            Expect.equal
                (Set.map (Vector2.fold (+) movement.direction) (Set.fromList cells))
                (for movement.period Life.next (Set.fromList cells))


testOscillatorChangesAndThenReturnsToOriginalAfterPeriod : Oscillator -> Test
testOscillatorChangesAndThenReturnsToOriginalAfterPeriod { name, cells, period } =
    fuzz (intRange 1 period) ("oscillator " ++ name ++ " changes and then returns to original when it reaches its period") <|
        \steps ->
            let
                expect =
                    if steps == period then
                        Expect.equal

                    else
                        Expect.notEqual
            in
            expect
                (Set.fromList cells)
                (for steps Life.next (Set.fromList cells))
