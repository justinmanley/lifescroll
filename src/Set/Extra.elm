module Set.Extra exposing (..)

import Set exposing (Set)


any : (comparable -> Bool) -> Set comparable -> Bool
any predicate =
    Set.filter predicate >> Set.isEmpty


flatMap : (comparable -> Set comparable) -> Set comparable -> Set comparable
flatMap f =
    Set.foldl (f >> Set.union) Set.empty
