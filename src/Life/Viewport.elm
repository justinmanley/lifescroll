module Life.Viewport exposing (next, scroll, scrolledCellsPerStep)

import BoundingRectangle exposing (BoundingRectangle)
import Life.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.Life as Life exposing (LifeGrid)
import Loop exposing (for)
import Set
import Vector2 exposing (Vector2)


next : BoundingRectangle Int -> LifeGrid -> LifeGrid
next viewport { cells, atomicUpdateRegions } =
    let
        belongsToAtomicUpdateRegion : Vector2 Int -> AtomicUpdateRegion -> Bool
        belongsToAtomicUpdateRegion cell { bounds } =
            (bounds |> BoundingRectangle.hasPartialIntersection viewport)
                && (bounds |> BoundingRectangle.containsPoint cell)

        isSteppable : Vector2 Int -> Bool
        isSteppable cell =
            BoundingRectangle.containsPoint cell viewport
                && not (List.any (belongsToAtomicUpdateRegion cell) atomicUpdateRegions)

        ( steppable, notSteppable ) =
            Set.partition isSteppable cells
    in
    { cells = Set.union (Life.next steppable) notSteppable
    , atomicUpdateRegions = List.map (AtomicUpdateRegion.next viewport) atomicUpdateRegions
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
