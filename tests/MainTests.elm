module MainTests exposing (..)

import BoundingRectangle
import Dict
import Expect
import Life
import Main exposing (updateLife)
import Page exposing (Page)
import PatternAnchor exposing (PagePatternAnchor)
import PatternDict exposing (PatternDict)
import Set exposing (Set)
import Test exposing (Test, describe, test)


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
                        Dict.foldl (\_ pattern cells -> Set.union pattern.cells cells) Set.empty testPatternDict
                in
                updateLife testPatternDict page Life.empty
                    |> Set.size
                    |> Expect.equal (Set.size allPatternsCells)
        ]
