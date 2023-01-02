module Parser.Extra exposing (..)

import Parser exposing ((|.), (|=), Parser, oneOf, succeed, symbol)


nat : Parser Int
nat =
    Parser.int


int : Parser Int
int =
    oneOf
        [ succeed negate
            |. symbol "-"
            |= nat
        , nat
        ]
