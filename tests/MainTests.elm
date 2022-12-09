module MainTests exposing (..)

import BoundingRectangle
import Dict
import Expect
import Life
import Main exposing (updateLife)
import Page exposing (Page)
import PatternAnchor exposing (PagePatternAnchor)
import PatternDict exposing (PatternDict)
import Test exposing (Test, describe, test)


testPatternDict : PatternDict
testPatternDict =
    Dict.fromList
        [ ( "PatternWithMoreThanOneUniqueCell"
          , { cells =
                [ { row = 0, col = 0 }
                , { row = 1, col = 1 }
                ]
            , extent = { rows = 1, columns = 2 }
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


testAnchor : PagePatternAnchor
testAnchor =
    { position = ( 0, 0 ), id = "" }


suite : Test
suite =
    describe "Main"
        [ test "inserts every cell in a pattern into an empty LifeGrid" <|
            \() ->
                let
                    page =
                        { testPage | patterns = [ { testAnchor | id = "PatternWithMoreThanOneUniqueCell" } ] }

                    allPatternsCells =
                        Dict.foldl (\_ pattern cells -> List.append pattern.cells cells) [] testPatternDict
                in
                updateLife testPatternDict page Life.empty
                    |> (\{ cells } -> List.length cells)
                    |> Expect.equal (List.length allPatternsCells)
        ]
