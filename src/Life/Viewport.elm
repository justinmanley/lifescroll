module Life.Viewport exposing (scroll, scrolledCellsPerStep)

import BoundingRectangle exposing (BoundingRectangle)
import Life.GridCells exposing (GridCells)
import Life.Life as Life exposing (LifeGrid)
import Life.ProtectedRegion as ProtectedRegion exposing (ProtectedRegion)
import Loop exposing (for)
import Set
import Vector2 exposing (Vector2)


next : BoundingRectangle Int -> List ProtectedRegion -> GridCells -> GridCells
next viewport protectedRegions cells =
    let
        isProtected : Vector2 Int -> ProtectedRegion -> Bool
        isProtected cell { bounds } =
            (bounds |> BoundingRectangle.hasPartialIntersection viewport)
                && (bounds |> BoundingRectangle.containsPoint cell)

        isSteppable : Vector2 Int -> Bool
        isSteppable cell =
            BoundingRectangle.containsPoint cell viewport
                && not (List.any (isProtected cell) protectedRegions)

        ( steppable, notSteppable ) =
            Set.partition isSteppable cells
    in
    Set.union (Life.next steppable) notSteppable


scroll : Float -> Float -> BoundingRectangle Float -> LifeGrid -> LifeGrid
scroll cellSizeInPixels mostRecentScrollPosition viewport { protected, cells } =
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
    { cells = for numSteps (next gridViewport protected) cells
    , protected = List.map (ProtectedRegion.stepIfEligible gridViewport numSteps) protected
    }


scrolledCellsPerStep : number
scrolledCellsPerStep =
    4
