module LifeCell exposing (..)


type alias Position =
    { row : Int
    , col : Int
    }


type alias LifeCell =
    { position : Position
    , alive : Bool
    }


type alias Pattern =
    List LifeCell
