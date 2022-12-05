port module Main exposing (main)

import Browser
import Canvas
import Html exposing (Html)
import Html.Attributes exposing (property, style)
import Json.Decode as Decode exposing (Decoder, andThen, decodeValue, field, float, int, list, oneOf, string)


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


type alias BoundingRectangle =
    { top : Int
    , left : Int
    , bottom : Int
    , right : Int
    }


width : BoundingRectangle -> Int
width bounds =
    bounds.right - bounds.left


height : BoundingRectangle -> Int
height bounds =
    bounds.bottom - bounds.top


emptyBoundingRectangle : BoundingRectangle
emptyBoundingRectangle =
    { top = 0
    , left = 0
    , bottom = 0
    , right = 0
    }



{- Page -}


type alias Page =
    { patterns : List PatternAnchor, body : BoundingRectangle, article : BoundingRectangle }



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
    , body = emptyBoundingRectangle
    , article = emptyBoundingRectangle
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( emptyModel
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    Canvas.toHtml ( width model.page.body, height model.page.body )
        [ style "position" "absolute"
        , style "height" "100%"
        , style "width" "100%"
        , style "top" "0"
        , style "left" "0"
        ]
        []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageUpdate page ->
            ( { page = page }, Cmd.none )

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


boundingRectangleDecoder : Decoder BoundingRectangle
boundingRectangleDecoder =
    Decode.map4 BoundingRectangle
        (field "top" int)
        (field "left" int)
        (field "bottom" int)
        (field "right" int)


pageDecoder : Decoder Msg
pageDecoder =
    Decode.map PageUpdate <|
        Decode.map3
            Page
            (field "patterns" (list patternDecoder))
            (field "body" boundingRectangleDecoder)
            (field "article" boundingRectangleDecoder)
