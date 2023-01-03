module Interval exposing (..)


type alias Interval number =
    { start : number
    , end : number
    }


intersect : Interval number -> Interval number -> Interval number
intersect a b =
    { start = max a.start b.start
    , end = min a.end b.end
    }


length : Interval number -> number
length { start, end } =
    end - start


containsValue : number -> Interval number -> Bool
containsValue value { start, end } =
    start <= value && value <= end


contains : Interval number -> Interval number -> Bool
contains query container =
    container.start <= query.start && query.end <= container.end


hasPartialIntersection : Interval number -> Interval number -> Bool
hasPartialIntersection a b =
    let
        intersectionLength =
            length <| intersect a b
    in
    intersectionLength < length a && intersectionLength < length b
