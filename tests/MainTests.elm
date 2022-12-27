module MainTests exposing (..)

import BoundingRectangle
import Dict
import Expect
import Fuzz exposing (intAtLeast)
import Life
import Main exposing (Model, Msg(..), emptyModel, insertPatterns, lifeStepsFromScroll, scrolledCellsPerStep)
import Page exposing (Page)
import PatternAnchor exposing (PatternAnchor)
import PatternDict exposing (PatternDict)
import Set
import Test exposing (Test, describe, fuzz, test)
import Tuple


testPatternDict : PatternDict
testPatternDict =
    Dict.fromList
        [ ( "PatternWithMoreThanOneUniqueCell"
          , { cells =
                Set.fromList
                    [ ( 0, 0 )
                    , ( 1, 1 )
                    ]
            , extent = { height = 1, width = 2 }
            }
          )
        ]


testPage : Page
testPage =
    { patterns = []
    , body = BoundingRectangle.empty
    , article = BoundingRectangle.empty
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
    }


updateModel : Msg -> Model -> Model
updateModel msg model =
    Main.update msg model |> Tuple.first


suite : Test
suite =
    describe "Main"
        [ describe "lifeStepsFromScroll"
            [ fuzz (intAtLeast 0) "when starting from an empty page, advances Life by one generation for each unit of advance" <|
                \numCellsScrolled ->
                    let
                        scrollPosition =
                            Page.empty.cellSizeInPixels * toFloat numCellsScrolled * scrolledCellsPerStep
                    in
                    Expect.equal
                        (lifeStepsFromScroll scrollPosition emptyModel)
                        numCellsScrolled
            , fuzz (intAtLeast 0) "when the page is almost scrolled to a unit boundary, advances Life by one generation upon reaching the unit boundary" <|
                \numCellsScrolled ->
                    let
                        scrollPosition =
                            Page.empty.cellSizeInPixels * toFloat numCellsScrolled * scrolledCellsPerStep

                        previousScrollPosition =
                            max 0 (scrollPosition - 0.1 * Page.empty.cellSizeInPixels * scrolledCellsPerStep)

                        model =
                            { emptyModel
                                | scroll =
                                    { furthest = previousScrollPosition
                                    , mostRecent = previousScrollPosition
                                    }
                            }

                        baseline =
                            floor (previousScrollPosition / (Page.empty.cellSizeInPixels * scrolledCellsPerStep))
                    in
                    Expect.equal (lifeStepsFromScroll scrollPosition model) (numCellsScrolled - baseline)
            ]
        , describe "updateLife"
            [ test "inserts every cell in a pattern into an empty LifeGrid" <|
                \() ->
                    let
                        page =
                            { testPage | patterns = [ { testAnchor | id = "PatternWithMoreThanOneUniqueCell" } ] }

                        allPatternsCells =
                            Dict.foldl (\_ pattern cells -> Set.union pattern.cells cells) Set.empty testPatternDict
                    in
                    insertPatterns testPatternDict page Life.empty
                        |> Set.size
                        |> Expect.equal (Set.size allPatternsCells)
            ]
        ]
