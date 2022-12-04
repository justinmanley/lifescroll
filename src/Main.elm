module Main exposing (main)

import Browser
import Html exposing (..)

main : Program (Maybe Model) Model Msg
main =
    Browser.document
        { init = init
        , view = \model -> { title = "A page", body = [view model] }
        , update = update 
        , subscriptions = \_ -> Sub.none
        }

type alias Model = {}

type Msg = NoOp

emptyModel : Model
emptyModel = {}

init : Maybe Model -> ( Model, Cmd Msg )
init maybeModel =
  ( Maybe.withDefault emptyModel maybeModel
  , Cmd.none
  )

view : Model -> Html Msg
view model = div [] []

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = (model, Cmd.none)