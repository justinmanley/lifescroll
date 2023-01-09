module Life.RleParser.AtomicUpdateRegionParserTests exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Expect
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion, Movement)
import Life.RleParser.AtomicUpdateRegionParser as RleParser exposing (atomicUpdateRegion)
import Parser exposing (DeadEnd)
import Result exposing (Result(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "AtomicUpdateRegionParser"
        [ test "should parse a lone maximum extent" <|
            \_ ->
                Expect.equal
                    (Ok
                        { top = 0
                        , left = 0
                        , bottom = 1
                        , right = 1
                        }
                    )
                    (parse "update atomically within extent top 0 left 0 bottom 1 right 1" |> Result.map getBounds)
        , test "parses a pattern with a movement comment" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Just
                            { direction = ( 1, 2 )
                            , period = 3
                            }
                    )
                    (""
                        ++ "update atomically within extent top 0 left 0 bottom 0 right 0 "
                        ++ "moving in direction (1,2) with period 3\no!"
                        |> (parse >> Result.map getMovement)
                    )
        , test "parses a pattern with a movement comment with negative movement" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Just
                            { direction = ( -1, 2 )
                            , period = 3
                            }
                    )
                    (""
                        ++ "update atomically within extent top 0 left 0 bottom 0 right 0 "
                        ++ "moving in direction (-1,2) with period 3\no!"
                        |> (parse >> Result.map getMovement)
                    )
        ]


parse : String -> Result (List DeadEnd) AtomicUpdateRegion
parse =
    Parser.run RleParser.atomicUpdateRegion


getBounds : AtomicUpdateRegion -> BoundingRectangle Int
getBounds atomicUpdateRegion =
    atomicUpdateRegion.bounds


getMovement : AtomicUpdateRegion -> Maybe Movement
getMovement atomicUpdateRegion =
    atomicUpdateRegion.movement
