module Life.AtomicUpdateRegion.StepCriterion exposing (..)

import Json.Decode exposing (Decoder, andThen, fail, string, succeed)


type StepCriterion
    = AnyIntersectionWithSteppableRegion
    | FullyContainedWithinSteppableRegion


decoder : Decoder StepCriterion
decoder =
    string
        |> andThen
            (\str ->
                case str of
                    "AnyIntersectionWithSteppableRegion" ->
                        succeed AnyIntersectionWithSteppableRegion

                    "FullyContainedWithinSteppableRegion" ->
                        succeed FullyContainedWithinSteppableRegion

                    _ ->
                        fail <| "Unrecognized step criterion: " ++ str
            )
