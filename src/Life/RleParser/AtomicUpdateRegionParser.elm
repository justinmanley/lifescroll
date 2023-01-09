module Life.RleParser.AtomicUpdateRegionParser exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion, Movement)
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
        , spaces
        , succeed
        , symbol
        , token
        )
import Parser.Extra exposing (int, spacesOrTabs)



-- Maximum bounds coordinates are relative to the upper-leftmost live cell
-- in the pattern (i.e. the first generation of the pattern).


atomicUpdateRegion : Parser AtomicUpdateRegion
atomicUpdateRegion =
    succeed initialUpdateRegion
        |. spacesOrTabs
        |. token "update atomically"
        |. spacesOrTabs
        |= extent
        |. spacesOrTabs
        |= oneOf
            [ map Just movement
            , succeed Nothing
            ]
        |. spacesOrTabs


extent : Parser (BoundingRectangle Int)
extent =
    succeed BoundingRectangle
        |. token "within extent"
        |. spacesOrTabs
        |. token "top"
        |. spacesOrTabs
        |= int
        |. spacesOrTabs
        |. token "left"
        |. spacesOrTabs
        |= int
        |. spacesOrTabs
        |. token "bottom"
        |. spacesOrTabs
        |= int
        |. spacesOrTabs
        |. token "right"
        |. spacesOrTabs
        |= int


movement : Parser Movement
movement =
    let
        toMovement : Int -> Int -> Int -> Movement
        toMovement x y period =
            { direction = ( x, y )
            , period = period
            }
    in
    succeed toMovement
        |. token "moving"
        |. spacesOrTabs
        |. token "in direction"
        |. spacesOrTabs
        |. symbol "("
        |. spacesOrTabs
        |= int
        |. spacesOrTabs
        |. symbol ","
        |. spacesOrTabs
        |= int
        |. spacesOrTabs
        |. symbol ")"
        |. spacesOrTabs
        |. symbol "with period"
        |. spacesOrTabs
        |= int


initialUpdateRegion : BoundingRectangle Int -> Maybe Movement -> AtomicUpdateRegion
initialUpdateRegion bounds maybeMovement =
    { bounds = bounds
    , movement = maybeMovement
    , stepsElapsed = 0
    }
