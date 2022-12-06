module Life exposing (..)

import Basics.Extra exposing (uncurry)
import Matrix exposing (Matrix)


type alias LifeGrid =
    Matrix Bool


empty : LifeGrid
empty =
    Matrix.empty


resize : Int -> Int -> LifeGrid -> LifeGrid
resize newWidth newHeight grid =
    let
        oldWidth =
            Matrix.width grid

        oldHeight =
            Matrix.height grid

        toCenteredInNewGrid ( i, j ) =
            ( i - floor (toFloat newWidth / 2)
            , j - floor (toFloat newHeight / 2)
            )

        fromCenteredInOldGrid ( i, j ) =
            ( i + floor (toFloat oldWidth / 2)
            , j + floor (toFloat oldWidth / 2)
            )

        newIndexToOldIndex =
            toCenteredInNewGrid >> fromCenteredInOldGrid

        initialize : ( Int, Int ) -> Bool
        initialize ( i, j ) =
            case uncurry Matrix.get (newIndexToOldIndex ( i, j )) grid of
                Just val ->
                    val

                Nothing ->
                    False
    in
    if newWidth == oldWidth && newHeight == oldHeight then
        grid

    else
        Matrix.initialize newWidth newHeight initialize
