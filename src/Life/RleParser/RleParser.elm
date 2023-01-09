module Life.RleParser.RleParser exposing (comment, parse)

import BoundingRectangle as BoundingRectangle
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells exposing (GridCells)
import Life.Pattern as Pattern exposing (Pattern, setCells)
import Life.RleParser.AtomicUpdateRegionParser exposing (atomicUpdateRegion)
import Parser
    exposing
        ( (|.)
        , (|=)
        , DeadEnd
        , Parser
        , Step(..)
        , chompUntil
        , chompWhile
        , end
        , loop
        , map
        , oneOf
        , problem
        , run
        , succeed
        , symbol
        , token
        )
import Parser.Extra exposing (int, spacesOrTabs)
import Result
import Set
import Size2 exposing (Size2)


type alias GridState =
    { x : Int
    , y : Int
    , gridCells : GridCells
    }


type CellState
    = Alive
    | Dead
    | EmptyLine


initGrid : GridState
initGrid =
    { x = 0
    , y = 0
    , gridCells = Set.empty
    }


parse : String -> Result (List DeadEnd) Pattern
parse =
    run lines >> Result.map setAtomicUpdateBoundsFromCellsIfEmpty


lines : Parser Pattern
lines =
    loop Pattern.empty line


line : Pattern -> Parser (Step Pattern Pattern)
line pattern =
    oneOf
        [ oneOf
            [ succeed (Loop pattern)
                |. extent
            , succeed (Done << setCells pattern)
                |= cells
            , succeed (Loop << addComment pattern)
                |= comment
            ]
            |. spacesOrTabs
            |. oneOf [ symbol "\n", end ]
        , succeed (Done pattern)
            |. end
        ]


cells : Parser GridCells
cells =
    loop initGrid cell


cell : GridState -> Parser (Step GridState GridCells)
cell gridState =
    oneOf
        [ succeed (addCells gridState)
            |= int
            |= cellToken
        , succeed (addCells gridState 1)
            |= cellToken
        , succeed (nextGridLine gridState 1)
            |. token "$"
        , succeed (Done gridState.gridCells)
            |. token "!"
        , succeed (Loop gridState)
            |. symbol "\n"
        , succeed (Done gridState.gridCells)
            |. end
        , problem "Invalid RLE string. I support only two states, so use `b` and `o` for cells"
        ]


cellToken : Parser CellState
cellToken =
    oneOf
        [ map (\_ -> Dead) (token "b")
        , map (\_ -> Alive) (token "o")
        , map (\_ -> EmptyLine) (token "$")
        ]


addCells : GridState -> Int -> CellState -> Step GridState GridCells
addCells gridState count aliveOrDead =
    case aliveOrDead of
        Alive ->
            let
                newX =
                    gridState.x + count

                xRange =
                    List.range gridState.x (newX - 1)

                cellsToAdd =
                    List.map (\i -> ( i, gridState.y )) xRange |> Set.fromList
            in
            Loop
                { gridState
                    | x = newX
                    , gridCells = Set.union gridState.gridCells cellsToAdd
                }

        Dead ->
            Loop { gridState | x = gridState.x + count }

        EmptyLine ->
            nextGridLine gridState count


nextGridLine : GridState -> Int -> Step GridState GridCells
nextGridLine gridState count =
    Loop { gridState | x = 0, y = gridState.y + count }


type Comment
    = AtomicUpdateRegionComment AtomicUpdateRegion
    | Ignored


comment : Parser Comment
comment =
    succeed identity
        |. symbol "#"
        |. spacesOrTabs
        |= oneOf
            -- These comment types are not included in the standard RLE spec:
            -- https://conwaylife.com/wiki/Run_Length_Encoded.
            [ succeed AtomicUpdateRegionComment |= atomicUpdateRegion
            , succeed Ignored
            ]
        |. oneOf
            [ chompUntil "\n"
            , chompWhile (always True)
                |. end
            ]


addComment : Pattern -> Comment -> Pattern
addComment pattern c =
    { pattern
        | atomicUpdateRegion =
            case c of
                AtomicUpdateRegionComment atomicUpdateRegion ->
                    atomicUpdateRegion

                Ignored ->
                    pattern.atomicUpdateRegion
    }


rule : Parser ()
rule =
    spacesOrTabs
        |. symbol ","
        |. spacesOrTabs
        |. token "rule"
        |. spacesOrTabs
        |. symbol "="
        |. spacesOrTabs
        |. token "B3/S23"


extent : Parser (Size2 Int)
extent =
    succeed Size2
        |. spacesOrTabs
        |. symbol "x"
        |. spacesOrTabs
        |. symbol "="
        |. spacesOrTabs
        |= int
        |. spacesOrTabs
        |. symbol ","
        |. spacesOrTabs
        |. symbol "y"
        |. spacesOrTabs
        |. symbol "="
        |. spacesOrTabs
        |= int
        |. oneOf
            [ rule
            , spacesOrTabs
            ]


setAtomicUpdateBoundsFromCellsIfEmpty : Pattern -> Pattern
setAtomicUpdateBoundsFromCellsIfEmpty pattern =
    let
        atomicUpdateRegion =
            pattern.atomicUpdateRegion
    in
    if pattern.atomicUpdateRegion.bounds == BoundingRectangle.empty then
        case GridCells.bounds pattern.cells of
            Nothing ->
                pattern

            Just cellBounds ->
                { pattern
                    | atomicUpdateRegion =
                        { atomicUpdateRegion
                            | bounds = cellBounds
                        }
                }

    else
        pattern
