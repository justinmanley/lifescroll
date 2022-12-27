port module Main exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Browser
import Canvas
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode exposing (Decoder, at, decodeValue, field, oneOf, succeed)
import Json.Encode as Encode
import Life.Life exposing (LifeGrid)
import Life.PatternDict exposing (PatternDict)
import Life.Patterns exposing (patternDict)
import Loop exposing (for)
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
    | GetPatterns
    | PageUpdate Page
    | ScrollPage (BoundingRectangle Float)


emptyModel : Model
emptyModel =
    { page = Page.empty
    , life = Life.Life.empty
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
        , Life.Life.render page.cellSizeInPixels life
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPatterns ->
            ( model
            , sendMessage <|
                Encode.object
                    [ ( "patterns", Life.PatternDict.encode patternDict )
                    ]
            )

        PageUpdate page ->
            ( { model
                | page = page
                , life = insertPatterns patternDict page model.life
              }
            , Cmd.none
            )

        ScrollPage viewport ->
            let
                numSteps =
                    lifeStepsFromScroll viewport.top model

                toGrid x =
                    x / model.page.cellSizeInPixels |> floor

                gridViewport =
                    { top = toGrid viewport.top
                    , left = toGrid viewport.left
                    , bottom = toGrid viewport.bottom
                    , right = toGrid viewport.right
                    }
            in
            ( { model
                | life = for numSteps (Life.Life.nextInViewport gridViewport) model.life
                , scroll = ScrollState.update viewport.top model.scroll
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


insertPatterns : PatternDict -> Page -> LifeGrid -> LifeGrid
insertPatterns patternDict page life =
    List.foldl Life.Life.insertPattern life <| Page.gridCells page patternDict


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
        , Decode.map ScrollPage (at [ "ScrollPage", "viewport" ] BoundingRectangle.decoder)
        ]
