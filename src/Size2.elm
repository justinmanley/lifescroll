module Size2 exposing (..)


type alias Size2 number =
    { width : number
    , height : number
    }


empty : Size2 number
empty =
    { width = 0
    , height = 0
    }
