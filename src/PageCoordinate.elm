module PageCoordinate exposing (..)


toGrid : Float -> Float -> Int
toGrid cellSizeInPixels x =
    x / cellSizeInPixels |> floor
