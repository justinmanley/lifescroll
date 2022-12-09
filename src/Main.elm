port module Main exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas
import Dict
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode exposing (Decoder, decodeValue, oneOf)
import Life exposing (GridPatternAnchor, GridPosition, LifeGrid, Pattern, PatternDict)
import Page exposing (Page)
import Patterns exposing (patternDict)


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
        [ Life.render model.page.articleFontSizeInPixels model.life
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageUpdate page ->
            ( { page = page, life = updateLife patternDict page model.life }, Cmd.none )

        ScrollEvent _ ->
            ( model, Cmd.none )

        ParsingError error ->
            ( Debug.log (Decode.errorToString error) model, Cmd.none )


updateLife : PatternDict -> Page -> LifeGrid -> LifeGrid
updateLife patternDict page life =
    let
        -- resized = resizeLife page life
        resized =
            life

        gridPatternAnchors : List GridPatternAnchor
        gridPatternAnchors =
            List.map (Life.positionInGrid page) page.patterns

        applyOffset : ( Int, Int ) -> GridPosition -> GridPosition
        applyOffset ( rowOffset, colOffset ) { row, col } =
            { row = rowOffset + row
            , col = colOffset + col
            }

        getPattern : GridPatternAnchor -> Maybe Pattern
        getPattern { id, position } =
            case Dict.get id patternDict of
                Nothing ->
                    Debug.log ("Could not find pattern for id " ++ id) Nothing

                Just pattern ->
                    Just <|
                        List.map (applyOffset position)
                            pattern

        patterns : List Pattern
        patterns =
            List.filterMap getPattern gridPatternAnchors
    in
    List.foldl Life.addPattern resized patterns


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


resizeLife : Page -> LifeGrid -> LifeGrid
resizeLife { body } =
    Life.resize
        (BoundingRectangle.width body |> ceiling)
        (BoundingRectangle.height body |> ceiling)


port sendMessage : String -> Cmd msg



{- Decoding messages from the page. -}


port messageReceiver : (Decode.Value -> msg) -> Sub msg


decoder : Decoder Msg
decoder =
    oneOf
        [ Decode.map PageUpdate Page.decoder ]
