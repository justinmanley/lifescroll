port module Main exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode exposing (Decoder, at, decodeValue, oneOf)
import Json.Encode as Encode
import Life.Life as Life exposing (LifeGrid)
import Life.Viewport as Viewport
import Page exposing (Page)
import ScrollState exposing (ScrollState)


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
    , scroll : ScrollState
    }


type Msg
    = ParsingError Decode.Error
    | PageUpdate Page
    | ScrollPage (BoundingRectangle Float)


emptyModel : Model
emptyModel =
    { page = Page.empty
    , life = Life.empty
    , scroll = ScrollState.empty
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( emptyModel
    , Cmd.none
    )


canvasDimensions : BoundingRectangle Float -> ( Int, Int )
canvasDimensions rect =
    ( BoundingRectangle.width rect |> ceiling
    , BoundingRectangle.height rect |> ceiling
    )


view : Model -> Html Msg
view { page, life } =
    Canvas.toHtml
        (canvasDimensions page.body)
        [ style "position" "absolute"
        , style "height" "100%"
        , style "width" "100%"
        , style "top" "0"
        , style "left" "0"
        ]
        [ Canvas.clear
            ( page.body.left, page.body.top )
            (BoundingRectangle.width page.body)
            (BoundingRectangle.height page.body)
        , Life.render page.cellSizeInPixels life.cells
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageUpdate page ->
            ( { model
                | page = Debug.log "page" page
                , life = insertPatterns page model.life
              }
            , Cmd.none
            )

        ScrollPage viewport ->
            ( { model
                | life = Viewport.scroll model.page.cellSizeInPixels model.scroll.mostRecent viewport model.life
                , scroll = ScrollState.update viewport.top model.scroll
              }
            , Cmd.none
            )

        ParsingError error ->
            ( Debug.log (Decode.errorToString error) model, Cmd.none )


insertPatterns : Page -> LifeGrid -> LifeGrid
insertPatterns page life =
    List.foldl Life.insertPattern life <| Page.gridCells page


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map
        (\value ->
            case value of
                Ok msg ->
                    msg

                Err error ->
                    ParsingError (Debug.log "ParsingError" error)
        )
        (messageReceiver <| decodeValue decoder)


port sendMessage : Encode.Value -> Cmd msg



{- Decoding messages from the page. -}


port messageReceiver : (Decode.Value -> msg) -> Sub msg


decoder : Decoder Msg
decoder =
    oneOf
        [ Decode.map PageUpdate (at [ "PageUpdate" ] Page.decoder)
        , Decode.map ScrollPage (at [ "ScrollPage", "viewport" ] BoundingRectangle.decoder)
        ]
