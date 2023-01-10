module Life.RleParserTests exposing (..)

import Expect
import Life.RleParser as RleParser
import Set
import Test exposing (..)


suite : Test
suite =
    describe "RLE Parser"
        [ test "parses one dead cell" <|
            \_ ->
                Expect.equal (Ok Set.empty) (RleParser.parse "b!")
        , test "parses multiple dead cells" <|
            \_ ->
                Expect.equal (Ok Set.empty) (RleParser.parse "3b!")
        , test "parses one live cell" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ) ])
                    (RleParser.parse "o!")
        , test "parses multiple live cells" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ) ])
                    (RleParser.parse "3o!")
        , test "parses combination of dead and live cells" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ) ])
                    (RleParser.parse "3o2b!")
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
                    (RleParser.parse "3o$obo!")
        , test "parses blank lines" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 0, 2 ) ])
                    (RleParser.parse "o2$o!")
        , test "does not fail without trailing bang" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 0, 1 ) ])
                    (RleParser.parse "2o$ob")
        , test "errors on an invalid rle string" <|
            \_ ->
                Expect.err (RleParser.parse "$#df%%fsd$!$$")
        , test "parses a pattern consisting only of a comment" <|
            \_ ->
                Expect.equal (Ok Set.empty) (RleParser.parse "#C   ")
        , test "parses a pattern consisting only of a comment and a newline" <|
            \_ ->
                Expect.equal (Ok Set.empty) (RleParser.parse "#C   \n")
        , test "parses a pattern consisting only of multiple comments" <|
            \_ ->
                Expect.equal (Ok Set.empty) (RleParser.parse "#C   \n#C  \n#C  ")
        , test "parses a pattern with extent and grid cells" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Set.fromList [ ( 0, 0 ) ]
                    )
                    (RleParser.parse "x = 2, y = 3\no!")
        , test "parses a pattern with comment, extent, and grid cells" <|
            \_ ->
                Expect.equal
                    (Ok <|
                        Set.fromList
                            [ ( 0, 1 )
                            , ( 1, 0 )
                            , ( 1, 2 )
                            , ( 2, 0 )
                            , ( 2, 2 )
                            , ( 3, 1 )
                            ]
                    )
                    (RleParser.parse "#N Beehive\n#O John Conway\n#C An extremely common 6…eehive\nx = 4, y = 3, rule = B3/S23\nb2ob$o2bo$b2o!")
        , test "parses a pattern with grid cells across multiple lines" <|
            \_ ->
                Expect.equal
                    (Ok <| Set.fromList [ ( 0, 0 ), ( 1, 0 ) ])
                    (RleParser.parse "o\no!")
        ]
