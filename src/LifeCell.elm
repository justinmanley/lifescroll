module LifeCell exposing (..)


type alias Position =
    { y : Int
    , x : Int
    }


type alias LifeCell =
    { position : Position
    , alive : Bool
    }


type alias Pattern =
    List LifeCell
