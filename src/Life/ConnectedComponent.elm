module Life.ConnectedComponent exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Life.Neighborhoods exposing (extendedNeighbors, neighbors)
import Life.Pattern exposing (GridCells)
import Set
import Vector2 exposing (Vector2)


type alias ConnectedComponent =
    { cells : GridCells
    , bounds : BoundingRectangle Int
    }


singleton : Vector2 Int -> ConnectedComponent
singleton ( x, y ) =
    { cells = Set.fromList [ ( x, y ) ]
    , bounds =
        { top = y
        , left = x
        , bottom = y
        , right = x
        }
    }


insert : Vector2 Int -> ConnectedComponent -> ConnectedComponent
insert cell { cells, bounds } =
    { cells = Set.insert cell cells
    , bounds = BoundingRectangle.expand cell bounds
    }


combine : ConnectedComponent -> ConnectedComponent -> ConnectedComponent
combine c1 c2 =
    { cells = Set.union c1.cells c2.cells
    , bounds = BoundingRectangle.union c1.bounds c2.bounds
    }


expand : Vector2 Int -> List ConnectedComponent -> List ConnectedComponent
expand cell components =
    let
        isCellConnectedToComponent : ConnectedComponent -> Bool
        isCellConnectedToComponent { cells } =
            Set.union (neighbors cell) (extendedNeighbors cell)
                |> Set.intersect cells
                |> Set.isEmpty
                >> not

        ( connectedToCell, notConnectedToCell ) =
            List.partition isCellConnectedToComponent components

        cellComponent =
            case connectedToCell of
                [] ->
                    singleton cell

                component :: cs ->
                    insert cell (List.foldl combine component cs)
    in
    cellComponent :: notConnectedToCell


connectedComponents : GridCells -> List ConnectedComponent
connectedComponents =
    Set.foldl expand []
