module Life.RleParserTests exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Expect
import Life.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion, Movement)
import Life.GridCells exposing (GridCells)
import Life.Pattern as Pattern exposing (Pattern)
import Life.RleParser as RleParser
import Set
import Size2 exposing (Size2)
import Test exposing (..)
import Vector2 exposing (Vector2)


suite : Test
suite =
    describe "RLE Parser"
        [ test "parses one dead cell" <|
            \_ ->
                Expect.equal (Ok Pattern.empty) (RleParser.parse "b!")
        , test "parses multiple dead cells" <|
            \_ ->
                Expect.equal (Ok Pattern.empty) (RleParser.parse "3b!")
        , test "parses one live cell" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ) ])
                    (RleParser.parse "o!" |> Result.map getCells)
        , test "parses multiple live cells" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ) ])
                    (RleParser.parse "3o!" |> Result.map getCells)
        , test "parses combination of dead and live cells" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ) ])
                    (RleParser.parse "3o2b!" |> Result.map getCells)
        , test "parses multiple lines" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Set.fromList
                            [ ( 0, 0 )
                            , ( 1, 0 )
                            , ( 2, 0 )
                            , ( 0, 1 )
                            , ( 2, 1 )
                            ]
                    )
                    (RleParser.parse "3o$obo!" |> Result.map getCells)
        , test "parses blank lines" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 0, 2 ) ])
                    (RleParser.parse "o2$o!" |> Result.map getCells)
        , test "does not fail without trailing bang" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 0, 1 ) ])
                    (RleParser.parse "2o$ob" |> Result.map getCells)
        , test "errors on an invalid rle string" <|
            \_ ->
                Expect.err (RleParser.parse "$#df%%fsd$!$$")
        , test "parses extent" <|
            \_ ->
                Expect.equal
                    (Ok { width = 11, height = 13 })
                    (RleParser.parse "x = 11, y = 13" |> Result.map getExtent)
        , test "parses a pattern consisting only of a comment" <|
            \_ ->
                Expect.equal (Ok Pattern.empty) (RleParser.parse "#C   ")
        , test "parses a pattern consisting only of a comment and a newline" <|
            \_ ->
                Expect.equal (Ok Pattern.empty) (RleParser.parse "#C   \n")
        , test "parses a pattern consisting only of multiple comments" <|
            \_ ->
                Expect.equal (Ok Pattern.empty) (RleParser.parse "#C   \n#C  \n#C  ")
        , test "parses a pattern with extent and grid cells" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        { extent = { width = 2, height = 3 }
                        , cells = Set.fromList [ ( 0, 0 ) ]
                        , atomicUpdateRegion = AtomicUpdateRegion.empty
                        }
                    )
                    (RleParser.parse "x = 2, y = 3\no!")
        , test "parses a pattern with comment, extent, and grid cells" <|
            \_ ->
                Expect.equal
                    (Ok
                        { cells =
                            Set.fromList
                                [ ( 0, 1 )
                                , ( 1, 0 )
                                , ( 1, 2 )
                                , ( 2, 0 )
                                , ( 2, 2 )
                                , ( 3, 1 )
                                ]
                        , extent = { height = 3, width = 4 }
                        , atomicUpdateRegion = AtomicUpdateRegion.empty
                        }
                    )
                    (RleParser.parse "#N Beehive\n#O John Conway\n#C An extremely common 6…eehive\nx = 4, y = 3, rule = B3/S23\nb2ob$o2bo$b2o!")
        , test "parses a pattern with grid cells across multiple lines" <|
            \_ ->
                Expect.equal (Ok <| withoutExtent [ ( 0, 0 ), ( 1, 0 ) ]) (RleParser.parse "o\no!")
        , test "parses a pattern with a movement comment" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Just
                            { direction = ( 1, 2 )
                            , speed = 3
                            }
                    )
                    (RleParser.parse "# MOVEMENT DIRECTION (1,2) SPEED 3\no!" |> Result.map getMovement)
        , test "parses a pattern with a movement comment with negative movement" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Just
                            { direction = ( -1, 2 )
                            , speed = 3
                            }
                    )
                    (RleParser.parse "# MOVEMENT DIRECTION (-1,2) SPEED 3\no!" |> Result.map getMovement)
        , test "parses a pattern with an atomic update region bounds comment" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        { top = 1
                        , left = 2
                        , bottom = 3
                        , right = 4
                        }
                    )
                    (RleParser.parse "# MAXIMUM EXTENT TOP 1 LEFT 2 BOTTOM 3 RIGHT 4l\no!"
                        |> Result.map getAtomicUpdateRegionBounds
                    )
        , test "parses a pattern with atomic update region bounds comments" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        { bounds =
                            { top = 1
                            , left = 2
                            , bottom = 3
                            , right = 4
                            }
                        , movement =
                            Just
                                { direction = ( 1, 2 )
                                , speed = 3
                                }
                        , stepsElapsed = 0
                        }
                    )
                    (RleParser.parse "# MOVEMENT DIRECTION (1,2) SPEED 3\n# MAXIMUM EXTENT TOP 1 LEFT 2 BOTTOM 3 RIGHT 4l\no!"
                        |> Result.map getAtomicUpdateRegion
                    )
        ]


withoutExtent : List (Vector2 Int) -> Pattern
withoutExtent cells =
    { extent = emptyExtent
    , cells = Set.fromList cells
    , atomicUpdateRegion = AtomicUpdateRegion.empty
    }


emptyExtent : Size2 Int
emptyExtent =
    { width = 0
    , height = 0
    }


getMovement : Pattern -> Maybe Movement
getMovement pattern =
    pattern.atomicUpdateRegion.movement


getCells : Pattern -> GridCells
getCells pattern =
    pattern.cells


getExtent : Pattern -> Size2 Int
getExtent pattern =
    pattern.extent


getAtomicUpdateRegionBounds : Pattern -> BoundingRectangle Int
getAtomicUpdateRegionBounds pattern =
    pattern.atomicUpdateRegion.bounds


getAtomicUpdateRegion : Pattern -> AtomicUpdateRegion
getAtomicUpdateRegion pattern =
    pattern.atomicUpdateRegion
