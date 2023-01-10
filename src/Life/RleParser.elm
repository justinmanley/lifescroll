module Life.RleParser exposing (parse)

import Life.GridCells exposing (GridCells)
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


parse : String -> Result (List DeadEnd) GridCells
parse =
    run lines


lines : Parser GridCells
lines =
    loop initGrid line


line : GridState -> Parser (Step GridState GridCells)
line gridState =
    oneOf
        [ succeed (Done <| getCells gridState)
            |. end
        , oneOf
            [ succeed (Loop gridState)
                |. extent
            , succeed (Loop gridState)
                |. comment
            , succeed Loop
                |= cells gridState
            ]
            |. spacesOrTabs
            |. oneOf [ symbol "\n", end ]
        ]


cells : GridState -> Parser GridState
cells gridState =
    loop gridState cell


cell : GridState -> Parser (Step GridState GridState)
cell gridState =
    oneOf
        [ succeed (addCells gridState)
            |= int
            |= cellToken
        , succeed (addCells gridState 1)
            |= cellToken
        , succeed (nextGridLine gridState 1)
            |. token "$"
        , succeed (Done gridState)
            |. token "!"
        , succeed (Loop gridState)
            |. symbol "\n"
        , succeed (Done gridState)
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


addCells : GridState -> Int -> CellState -> Step GridState GridState
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


nextGridLine : GridState -> Int -> Step GridState GridState
nextGridLine gridState count =
    Loop { gridState | x = 0, y = gridState.y + count }


comment : Parser ()
comment =
    succeed ()
        |. symbol "#"
        |. spacesOrTabs
        |. oneOf
            [ chompUntil "\n"
            , chompWhile (always True)
                |. end
            ]


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


getCells : GridState -> GridCells
getCells gridState =
    gridState.gridCells
