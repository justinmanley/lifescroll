module Life.Viewport exposing (..)

import BoundingRectangle exposing (BoundingRectangle, vertical)
import Interval exposing (Interval, containsValue)
import Life.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.Life as Life exposing (LifeGrid)
import Loop exposing (for)
import PageCoordinate
import PageCoordinates
import Set
import Vector2 exposing (Vector2)


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

        belongsToFrozenAtomicUpdateRegion : Vector2 Int -> AtomicUpdateRegion -> Bool
        belongsToFrozenAtomicUpdateRegion cell { bounds } =
            (vertical bounds |> Interval.hasPartialIntersection viewportVerticalBounds)
                && (bounds |> BoundingRectangle.containsPoint cell)

        isSteppable : Vector2 Int -> Bool
        isSteppable ( x, y ) =
            (viewportVerticalBounds |> containsValue y)
                && not (List.any (belongsToFrozenAtomicUpdateRegion ( x, y )) atomicUpdateRegions)

        ( steppable, notSteppable ) =
            Set.partition isSteppable cells
    in
    { cells = Set.union (Life.next steppable) notSteppable
    , atomicUpdateRegions = List.map (AtomicUpdateRegion.next viewportVerticalBounds) atomicUpdateRegions
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
