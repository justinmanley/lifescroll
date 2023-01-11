module Life.AtomicUpdateRegion.Movement exposing (..)


type alias Movement a =
    { direction : a
    , period : Int
    }
