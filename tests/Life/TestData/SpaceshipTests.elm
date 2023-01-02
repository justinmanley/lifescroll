module Life.TestData.SpaceshipTests exposing (..)

import Expect
import Fuzz exposing (intRange)
import Life.Life as Life
import Life.TestData.Spaceship as Spaceship exposing (glider, inViewFor)
import Life.Viewport as Viewport
import Loop exposing (for)
import Set
import Test exposing (Test, describe, fuzz, test)
import Vector2 exposing (Vector2)


suite : Test
suite =
    describe "Spaceship"
        [ describe "glider"
            [ fuzz (intRange 1 10) "movement matches the direction and period of the cells" <|
                \numGliderSteps ->
                    let
                        numSteps =
                            numGliderSteps * glider.movement.period

                        initial =
                            Spaceship.toLifeGrid glider
                    in
                    Expect.equalSets
                        (Set.map (advanceSpaceshipCell numGliderSteps) initial.cells)
                        (for numSteps Life.next initial.cells)
            ]
        , describe "inViewFor"
            [ fuzz (intRange 1 10) "allows the pattern to change for the specified number of steps" <|
                \numGliderSteps ->
                    let
                        numSteps =
                            numGliderSteps * glider.movement.period

                        viewport =
                            glider |> inViewFor numSteps

                        initial =
                            Spaceship.toLifeGrid glider

                        { cells } =
                            for numSteps (Viewport.next viewport) initial
                    in
                    Expect.equalSets cells (Set.map (advanceSpaceshipCell numGliderSteps) initial.cells)
            ]
        ]


advanceSpaceshipCell : Int -> Vector2 Int -> Vector2 Int
advanceSpaceshipCell numGliderSteps =
    Vector2.add (Vector2.map ((*) numGliderSteps) glider.movement.direction)
