module Set.Extra exposing (..)

import Set exposing (Set)


any : (comparable -> Bool) -> Set comparable -> Bool
any predicate =
    Set.filter predicate >> Set.isEmpty


all : (comparable -> Bool) -> Set comparable -> Bool
all predicate =
    Set.filter (predicate >> not) >> Set.isEmpty >> not


flatMap : (comparable -> Set comparable) -> Set comparable -> Set comparable
flatMap f =
    Set.foldl (f >> Set.union) Set.empty
