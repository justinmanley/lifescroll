port module Main exposing (main)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas exposing (Point, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode exposing (Decoder, decodeValue, oneOf)
import Life exposing (LifeGrid)
import Page exposing (Page)
import PatternAnchor exposing (PatternAnchor)


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
    , life : LifeGrid
    }


type Msg
    = ParsingError Decode.Error
    | PageUpdate Page
    | ScrollEvent Int


emptyModel : Model
emptyModel =
    { page = Page.empty
    , life = Life.empty
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( emptyModel
    , Cmd.none
    )


canvasDimensions : BoundingRectangle -> ( Int, Int )
canvasDimensions rect =
    ( BoundingRectangle.width rect |> ceiling, BoundingRectangle.height rect |> ceiling )


view : Model -> Html Msg
view model =
    Canvas.toHtml
        (canvasDimensions model.page.body)
        [ style "position" "absolute"
        , style "height" "100%"
        , style "width" "100%"
        , style "top" "0"
        , style "left" "0"
        ]
        [ Debug.log "shapes" <| shapes [ fill Color.black ] <| List.map (viewPattern model.page.articleFontSizeInPixels) model.page.patterns
        ]


square : Point -> Float -> Shape
square point size =
    Canvas.rect point size size


viewPattern : Float -> PatternAnchor -> Shape
viewPattern size pattern =
    square ( 10, 10 ) size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageUpdate page ->
            ( { page = page, life = model.life }, Cmd.none )

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
        [ Decode.map PageUpdate Page.decoder ]
