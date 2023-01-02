module MainTests exposing (..)

import BoundingRectangle
import DebugSettings
import Dict exposing (Dict)
import Expect exposing (Expectation)
import Life.AtomicUpdateRegion as AtomicUpdateRegion
import Life.Life as Life
import Life.Pattern exposing (Pattern)
import Main exposing (Model, Msg(..), insertPattern, insertPatterns)
import Page exposing (Page)
import PatternAnchor exposing (PatternAnchor)
import Set exposing (Set)
import Test exposing (Test, describe, test)
import Tuple


suite : Test
suite =
    describe "Main"
        [ describe "updateLife"
            [ test "inserts every cell in a pattern into an empty GridCells" <|
                \() ->
                    let
                        page =
                            { testPage | anchors = [ { testAnchor | id = "PatternWithMoreThanOneUniqueCell" } ] }

                        allPatternsCells =
                            Dict.foldl (\_ pattern cells -> Set.union pattern.cells cells) Set.empty testPatternDict
                    in
                    insertPatterns page Life.empty
                        |> (\life -> Set.size life.cells)
                        |> Expect.equal (Set.size allPatternsCells)
            ]
        , describe "insertPattern"
            [ test "inserts every cell in a pattern into an empty set of GridCells" <|
                \_ ->
                    let
                        grid =
                            insertPattern True testPattern Life.empty
                    in
                    expectEqualSize testPattern.cells grid.cells
            ]
        ]


type alias PatternDict =
    Dict String Pattern


testPatternDict : PatternDict
testPatternDict =
    Dict.fromList
        [ ( "PatternWithMoreThanOneUniqueCell"
          , testPattern
          )
        ]


testPattern : Pattern
testPattern =
    { cells =
        Set.fromList
            [ ( 0, 0 )
            , ( 1, 1 )
            ]
    , extent = { height = 1, width = 2 }
    , atomicUpdateRegion = AtomicUpdateRegion.empty
    }


testPage : Page
testPage =
    { anchors = []
    , body = BoundingRectangle.empty
    , article = BoundingRectangle.empty
    , debug = DebugSettings.allEnabled
    , cellSizeInPixels = 10
    }


testAnchor : PatternAnchor
testAnchor =
    { id = ""
    , bounds =
        { top = 0
        , left = 0
        , bottom = 10
        , right = 10
        }
    , patternRle = "oo!"
    }


updateModel : Msg -> Model -> Model
updateModel msg model =
    Main.update msg model |> Tuple.first


expectEqualSize : Set a -> Set b -> Expectation
expectEqualSize expected actual =
    Expect.equal (Set.size expected) (Set.size actual)
