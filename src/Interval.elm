module Interval exposing (..)


type alias Interval number =
    -- `start` is assumed to be less than or equal to `end`
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


containedIn : Interval number -> number -> Bool
containedIn interval value =
    containsValue value interval


contains : Interval number -> Interval number -> Bool
contains query container =
    container.start <= query.start && query.end <= container.end


hasIntersectionWith : Interval number -> Interval number -> Bool
hasIntersectionWith a b =
    -- Cannot use `intersects` because that will not help if one of the intervals
    -- has length zero.
    b.start < a.end || a.start < b.end
