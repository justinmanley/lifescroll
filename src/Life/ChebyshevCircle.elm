module Life.ChebyshevCircle exposing (..)

import Set exposing (Set)
import Vector2 exposing (Vector2)


zip : List a -> List b -> List ( a, b )
zip =
    List.map2 Tuple.pair



-- Returns a set containing the coordinates of Chebyshev-metric circle:
-- https://en.wikipedia.org/wiki/Chebyshev_distance.


chebyshevCircle : Int -> Set (Vector2 Int)
chebyshevCircle radius =
    let
        -- We arbitrarily designate the vertical sides
        -- as the "long" sides
        longSide displacement =
            zip
                (List.repeat (2 * radius + 1) displacement)
                (List.range -radius radius)

        shortSide displacement =
            zip
                (List.range (-radius + 1) (radius - 1))
                (List.repeat (2 * radius - 1) displacement)
    in
    Set.fromList <|
        List.concat
            [ longSide radius
            , shortSide radius
            , longSide -radius
            , shortSide -radius
            ]
