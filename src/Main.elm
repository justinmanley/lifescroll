port module Main exposing (main)

import Browser
import Html exposing (..)
import Json.Decode as Decode exposing (Decoder, andThen, decodeValue, field, float, list, oneOf, string)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { page : Page
    }


type Msg
    = ParsingError Decode.Error
    | PageUpdate Page
    | ScrollEvent Int



{- Bounds -}


type alias Bounds =
    { min : Float
    , max : Float
    }


bounds : Float -> Float -> Bounds
bounds min max =
    { min = min, max = max }



{- Page -}


type alias Page =
    { patterns : List PatternAnchor, articleHorizontalBounds : Bounds }


page : List PatternAnchor -> Bounds -> Page
page patterns articleHorizontalBounds =
    { patterns = patterns, articleHorizontalBounds = articleHorizontalBounds }



{- PatternAnchor -}


type Side
    = Left
    | Right


type alias PatternAnchor =
    { id : String
    , side : Side
    , x : Float
    , y : Float
    }


emptyModel : Model
emptyModel =
    { page = emptyPage }


emptyPage : Page
emptyPage =
    { patterns = []
    , articleHorizontalBounds =
        { min = 0
        , max = 0
        }
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( emptyModel
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div [] []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageUpdate { patterns, articleHorizontalBounds } ->
            ( { page = page patterns articleHorizontalBounds }, Cmd.none )

        ScrollEvent _ ->
            ( model, Cmd.none )

        ParsingError error ->
            ( Debug.log (Decode.errorToString error) model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map
        (\value ->
            case value of
                Ok msg ->
                    msg

                Err error ->
                    ParsingError error
        )
        (messageReceiver
            (decodeValue decoder)
        )


port sendMessage : String -> Cmd msg



{- Decoding messages from the page. -}


port messageReceiver : (Decode.Value -> msg) -> Sub msg


decoder : Decoder Msg
decoder =
    oneOf
        [ pageDecoder ]


sideDecoder : String -> Decoder Side
sideDecoder side =
    case side of
        "left" ->
            Decode.succeed Left

        "right" ->
            Decode.succeed Right

        _ ->
            Decode.fail ""


patternDecoder : Decoder PatternAnchor
patternDecoder =
    Decode.map4 PatternAnchor
        (field "id" string)
        (field "side" string |> andThen sideDecoder)
        (field "x" float)
        (field "y" float)


boundsDecoder : Decoder Bounds
boundsDecoder =
    Decode.map2 bounds (field "min" float) (field "max" float)


pageDecoder : Decoder Msg
pageDecoder =
    Decode.map PageUpdate <|
        Decode.map2
            page
            (field "patterns" (list patternDecoder))
            (field "bounds" boundsDecoder)
