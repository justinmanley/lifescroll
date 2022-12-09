module ScrollState exposing (..)


type alias ScrollState =
    { furthest : Float
    , mostRecent : Float
    }


empty : ScrollState
empty =
    { furthest = 0
    , mostRecent = 0
    }


update : Float -> ScrollState -> ScrollState
update position { furthest } =
    { mostRecent = position
    , furthest = max position furthest
    }
