module Life exposing (..)

import Matrix exposing (Matrix)


type alias LifeGrid =
    Matrix Bool


empty : Matrix Bool
empty = Matrix.empty
