module Life.Viewport exposing (next)

import BoundingRectangle exposing (BoundingRectangle)
import Life.GridCells exposing (GridCells)
import Life.Life as Life
import Life.ProtectedRegion exposing (ProtectedRegion)
import Set
import Vector2 exposing (Vector2)


next : BoundingRectangle Int -> List ProtectedRegion -> GridCells -> GridCells
next viewport protectedRegions cells =
    let
        isProtected : Vector2 Int -> ProtectedRegion -> Bool
        isProtected cell { bounds } =
            (bounds |> BoundingRectangle.hasPartialIntersection viewport)
                && (bounds |> BoundingRectangle.containsPoint cell)

        isAdvanceable : Vector2 Int -> Bool
        isAdvanceable cell =
            BoundingRectangle.containsPoint cell viewport
                && not (List.any (isProtected cell) protectedRegions)

        ( advanceable, notAdvanceable ) =
            Set.partition isAdvanceable cells
    in
    Set.union (Life.next advanceable) notAdvanceable
