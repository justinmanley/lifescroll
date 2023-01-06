module Life.Viewport exposing (next, scroll, scrolledCellsPerStep)

import BoundingRectangle exposing (BoundingRectangle, vertical)
import Interval exposing (Interval, containsValue)
import Life.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.Life as Life exposing (LifeGrid)
import Loop exposing (for)
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
        toGridCellsCoordinates : Float -> Int
        toGridCellsCoordinates pageCoordinate =
            floor (pageCoordinate / (cellSizeInPixels * scrolledCellsPerStep))

        numSteps =
            max 0 <|
                (toGridCellsCoordinates viewport.top - toGridCellsCoordinates mostRecentScrollPosition)

        toGrid : Float -> Int
        toGrid x =
            x / cellSizeInPixels |> floor

        gridViewport =
            { top = toGrid viewport.top
            , left = toGrid viewport.left
            , bottom = toGrid viewport.bottom
            , right = toGrid viewport.right
            }
    in
    for numSteps (next gridViewport) grid


scrolledCellsPerStep : number
scrolledCellsPerStep =
    4
