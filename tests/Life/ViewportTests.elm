module Life.ViewportTests exposing (..)

import BoundingRectangle exposing (BoundingRectangle, containsPoint)
import Expect exposing (Expectation)
import Fuzz exposing (intRange)
import Life.GridCells as GridCells exposing (GridCells)
import Life.Life exposing (LifeGrid)
import Life.TestData.Spaceship as Spaceship exposing (glider, inViewFor)
import Life.Viewport as Viewport exposing (numProtectedBottomCells, scrolledCellsPerStep)
import Loop exposing (for)
import Set
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Viewport"
        [ describe "scroll"
            [ fuzz (intRange 0 10) "when starting from an empty page, advances Life by one generation for each unit of advance" <|
                \numSteps ->
                    Expect.equal (stepsElapsed <| scrollSentinel numSteps (\_ -> 0)) (Just numSteps)
            , test "when the page is almost scrolled to a unit boundary, advances Life by one generation upon reaching the unit boundary" <|
                \_ ->
                    let
                        numSteps =
                            1

                        currentPageScrollPositionToMostRecent pageScrollPosition =
                            pageScrollPosition - 0.1
                    in
                    Expect.equal
                        (stepsElapsed <| scrollSentinel numSteps currentPageScrollPositionToMostRecent)
                        (Just numSteps)
            ]
        , describe "next"
            [ fuzz (intRange 0 10) "when the grid consists only of an atomic spaceship, the spaceship should always remain with the atomic update region" <|
                \numSteps ->
                    let
                        viewport =
                            glider |> inViewFor numSteps

                        { atomicUpdateRegions, cells } =
                            for numSteps (Viewport.next viewport) (Spaceship.toLifeGrid glider)
                    in
                    case atomicUpdateRegions of
                        atomicUpdateRegion :: [] ->
                            expectCellsToBeWithinBounds atomicUpdateRegion.bounds cells

                        [] ->
                            Expect.fail "Expected one atomic update region, but found none."

                        _ ->
                            Expect.fail "Expected one atomic update region, but found more than one."
            ]
        ]


scrollSentinel : Int -> (Float -> Float) -> LifeGrid
scrollSentinel numSteps currentPageScrollPositionToMostRecent =
    let
        -- arbitrary
        cellSizeInPixels =
            10

        gridScrollPosition =
            numSteps * scrolledCellsPerStep

        mostRecentPageScrollPosition =
            cellSizeInPixels
                * toFloat gridScrollPosition
                |> currentPageScrollPositionToMostRecent

        sentinel =
            { top = gridScrollPosition
            , left = 0
            , right = 1
            , bottom = gridScrollPosition + 1
            }

        scrolledViewport =
            { top = cellSizeInPixels * toFloat sentinel.top
            , left = cellSizeInPixels * toFloat sentinel.left
            , right = cellSizeInPixels * toFloat sentinel.right
            , bottom = cellSizeInPixels * toFloat (sentinel.bottom + numProtectedBottomCells)
            }

        life =
            { cells = GridCells.empty
            , atomicUpdateRegions =
                [ { bounds = sentinel
                  , movement = Nothing
                  , stepsElapsed = 0
                  }
                ]
            }
    in
    Viewport.scroll cellSizeInPixels mostRecentPageScrollPosition scrolledViewport life


stepsElapsed : LifeGrid -> Maybe Int
stepsElapsed grid =
    case grid.atomicUpdateRegions of
        [] ->
            Nothing

        region :: _ ->
            Just region.stepsElapsed


expectCellsToBeWithinBounds : BoundingRectangle Int -> GridCells -> Expectation
expectCellsToBeWithinBounds bounds cells =
    let
        isCellOutsideBounds cell =
            bounds |> not << containsPoint cell

        cellsOutsideBounds =
            Set.filter isCellOutsideBounds cells
    in
    Expect.equalSets cellsOutsideBounds Set.empty
        |> Expect.onFail
            ("Cells "
                ++ Debug.toString cellsOutsideBounds
                ++ " were outside the bounds "
                ++ Debug.toString bounds
                ++ "."
            )
