port module Main exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas
import Dict
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
import Set exposing (Set)
import Vector2 exposing (Vector2, x, y)


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
        , Life.render page.cellSizeInPixels life
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
                    -- Debug.log "numSteps" <|
                    lifeStepsFromScroll position model
            in
            ( { model
                | life = for numSteps Life.next model.life
                , scroll = Debug.log "scrollState" <| ScrollState.update position model.scroll
              }
            , Cmd.none
            )

        ParsingError error ->
            ( Debug.log (Decode.errorToString error) model, Cmd.none )


scrolledCellsPerStep : number
scrolledCellsPerStep =
    4


lifeStepsFromScroll : Float -> Model -> Int
lifeStepsFromScroll scrollPosition { page, scroll } =
    let
        toLifeGridCoordinates : Float -> Int
        toLifeGridCoordinates pageCoordinate =
            floor (pageCoordinate / (page.cellSizeInPixels * scrolledCellsPerStep))
    in
    max 0 <|
        (toLifeGridCoordinates scrollPosition - toLifeGridCoordinates scroll.mostRecent)


updateLife : PatternDict -> Page -> LifeGrid -> LifeGrid
updateLife patternDict page life =
    let
        -- resized = resizeLife page life
        resized =
            life

        applyOffset : ( Int, Int ) -> Vector2 Int -> Vector2 Int
        applyOffset ( yOffset, xOffset ) position =
            ( xOffset + x position
            , yOffset + y position
            )

        getPattern : GridPatternAnchor -> Maybe (Set (Vector2 Int))
        getPattern { id, position } =
            case Dict.get id patternDict of
                Nothing ->
                    Debug.log ("Could not find pattern for id " ++ id) Nothing

                Just pattern ->
                    Just <|
                        Set.map (applyOffset position)
                            pattern.cells

        patterns : List (Set (Vector2 Int))
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
