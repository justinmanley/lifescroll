port module Main exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas
import Dict
import GridPosition exposing (GridPosition)
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode exposing (Decoder, at, decodeValue, field, float, oneOf, succeed)
import Json.Encode as Encode
import Life exposing (LifeGrid)
import Loop exposing (for)
import Page exposing (Page)
import PatternAnchor exposing (GridPatternAnchor)
import PatternDict exposing (PatternDict)
import Patterns exposing (patternDict)
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
    | GetPatterns
    | PageUpdate Page
    | ScrollPage Float


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
        [ Life.render model.page.cellSizeInPixels model.life
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPatterns ->
            ( model
            , sendMessage <|
                Encode.object
                    [ ( "patterns", PatternDict.encode patternDict )
                    ]
            )

        PageUpdate page ->
            ( { model
                | page = page
                , life = updateLife patternDict page model.life
              }
            , Cmd.none
            )

        ScrollPage position ->
            let
                numSteps =
                    max 0 <|
                        ceiling <|
                            (position - model.scroll.mostRecent)
                                / model.page.cellSizeInPixels
            in
            ( { model
                | life = for numSteps Life.next model.life
                , scroll = ScrollState.update position model.scroll
              }
            , Cmd.none
            )

        ParsingError error ->
            ( Debug.log (Decode.errorToString error) model, Cmd.none )


updateLife : PatternDict -> Page -> LifeGrid -> LifeGrid
updateLife patternDict page life =
    let
        -- resized = resizeLife page life
        resized =
            life

        applyOffset : ( Int, Int ) -> GridPosition -> GridPosition
        applyOffset ( yOffset, xOffset ) { y, x } =
            { x = xOffset + x
            , y = yOffset + y
            }

        getPattern : GridPatternAnchor -> Maybe (List GridPosition)
        getPattern { id, position } =
            case Dict.get id patternDict of
                Nothing ->
                    Debug.log ("Could not find pattern for id " ++ id) Nothing

                Just pattern ->
                    Just <|
                        List.map (applyOffset position)
                            pattern.cells

        patterns : List (List GridPosition)
        patterns =
            List.filterMap getPattern <| Page.gridPatternAnchors page
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


port sendMessage : Encode.Value -> Cmd msg



{- Decoding messages from the page. -}


port messageReceiver : (Decode.Value -> msg) -> Sub msg


decoder : Decoder Msg
decoder =
    oneOf
        [ field "GetPatterns" <| succeed GetPatterns
        , Decode.map PageUpdate (at [ "PageUpdate" ] Page.decoder)
        , Decode.map ScrollPage (at [ "ScrollPage", "scrollPosition" ] float)
        ]
