module Parser.Extra exposing (..)

import Parser exposing ((|.), (|=), Parser, chompWhile, oneOf, succeed, symbol)


nat : Parser Int
nat =
    Parser.int



-- The built-in Parser.int does not support leading minus signs.


int : Parser Int
int =
    oneOf
        [ succeed negate
            |. symbol "-"
            |= nat
        , nat
        ]



-- Use this rather than Parser.spaces in order to
-- be sensitive to line-endings.


spacesOrTabs : Parser ()
spacesOrTabs =
    chompWhile (\c -> c == ' ' || c == '\t')
