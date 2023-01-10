module Life.Viewport exposing (..)

import BoundingRectangle exposing (BoundingRectangle, containsPoint, vertical)
import Interval exposing (Interval, containedIn)
import Life.AtomicUpdateRegion.AtomicUpdateRegion as AtomicUpdateRegion exposing (bounds)
import Life.AtomicUpdateRegion.StepCriterion exposing (StepCriterion(..))
import Life.Life as Life exposing (LifeGrid)
import Loop exposing (for)
import PageCoordinate
import PageCoordinates
import Set
import Vector2 exposing (Vector2, y)


numProtectedBottomCells : number
numProtectedBottomCells =
    6


steppableVerticalBounds : BoundingRectangle Int -> Interval Int
steppableVerticalBounds viewport =
    let
        viewportVerticalBounds =
            vertical viewport
    in
    { start = viewportVerticalBounds.start
    , end = viewportVerticalBounds.end - numProtectedBottomCells
    }


next : BoundingRectangle Int -> LifeGrid -> LifeGrid
next viewport { cells, atomicUpdateRegions } =
    let
        viewportVerticalBounds =
            steppableVerticalBounds viewport

        -- Note that it is possible for a pattern to be corrupted if that pattern
        -- is straddling the boundary of the steppable viewport and belongs to BOTH
        -- an atomic update region with criterion AnyIntersectionWithSteppableRegion
        -- and another atomic update region with FullyContainedWithinSteppableRegion.
        -- In this case, the cells within the atomic update region inside the viewport
        -- will not be updated, while the cells within the atomic update region outside
        -- the viewport will be updated.
        -- TODO: Handle this proactively by preventing incompatible overlapping
        -- atomicUpdateRegions (but: what to do when they overlap? convert one into
        -- the other type?
        isCellSteppable : Vector2 Int -> Bool
        isCellSteppable cell =
            if y cell |> containedIn viewportVerticalBounds then
                not (List.any (bounds >> containsPoint cell) notSteppableRegions)

            else
                List.any (bounds >> containsPoint cell) steppableRegions

        ( steppableRegions, notSteppableRegions ) =
            List.partition (AtomicUpdateRegion.isSteppable viewportVerticalBounds) atomicUpdateRegions

        ( steppableCells, notSteppableCells ) =
            Set.partition isCellSteppable cells
    in
    { cells = Set.union (Life.next steppableCells) notSteppableCells
    , atomicUpdateRegions =
        List.append
            (List.map AtomicUpdateRegion.next steppableRegions)
            notSteppableRegions
    }


scroll : Float -> Float -> BoundingRectangle Float -> LifeGrid -> LifeGrid
scroll cellSizeInPixels mostRecentScrollPosition viewport grid =
    let
        pixelsToSteps : Float -> Int
        pixelsToSteps pageCoordinate =
            floor (pageCoordinate / (cellSizeInPixels * scrolledCellsPerStep))

        numSteps =
            max 0 <|
                -- pixelsToSteps must be applied separately in order to capture the difference
                -- between flooring the two values.
                (pixelsToSteps viewport.top - pixelsToSteps mostRecentScrollPosition)
    in
    for numSteps (next <| PageCoordinates.toGrid cellSizeInPixels viewport) grid


scrolledCellsPerStep : number
scrolledCellsPerStep =
    4


toggleCell : Float -> Vector2 Float -> LifeGrid -> LifeGrid
toggleCell cellSizeInPixels position grid =
    let
        gridPosition =
            Vector2.map (PageCoordinate.toGrid cellSizeInPixels) position
    in
    { grid
        | cells = Life.toggleCell gridPosition grid.cells
    }
