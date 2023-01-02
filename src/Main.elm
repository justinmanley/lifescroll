port module Main exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas
import Canvas.Renderable as Renderable
import DebugSettings exposing (withLogging)
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode exposing (Decoder, at, decodeValue, oneOf)
import Json.Encode as Encode
import Life.GridCells exposing (GridCells)
import Life.Life as Life exposing (LifeGrid)
import Life.Pattern exposing (Pattern)
import Life.Viewport as Viewport
import Page exposing (Page)
import PatternAnchor exposing (PatternAnchor)
import ScrollState exposing (ScrollState)
import Set
import Vector2 exposing (Vector2)


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
        , if page.debug.grid then
            Life.renderGrid page.cellSizeInPixels page.body

          else
            Renderable.empty
        , if page.debug.protected then
            Life.renderProtectedRegions page.cellSizeInPixels life.protected

          else
            Renderable.empty
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageUpdate page ->
            ( { model
                | page = withLogging page.debug.log "page" page
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
            ( withLogging True (Decode.errorToString error) model, Cmd.none )


insertPatterns : Page -> LifeGrid -> LifeGrid
insertPatterns page life =
    List.foldl (insertPattern page.debug.log) life <| Page.patterns page


insertPattern : Bool -> Pattern -> LifeGrid -> LifeGrid
insertPattern loggingEnabled pattern grid =
    let
        insertWithConflictLogging : Vector2 Int -> GridCells -> GridCells
        insertWithConflictLogging cell allCells =
            if Set.member cell allCells then
                withLogging loggingEnabled "found a conflict while attempting to insert pattern" allCells

            else
                Set.insert cell allCells
    in
    { cells = Set.foldl insertWithConflictLogging grid.cells pattern.cells
    , protected =
        pattern.protected
            :: grid.protected
    }


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
