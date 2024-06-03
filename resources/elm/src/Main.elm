module Main exposing (main)

import Browser
import Html exposing (Html)
import Json.Decode


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Flags =
    { component : String
    , props : Json.Decode.Value
    , url : String
    , version : String
    }


type alias Model =
    { flags : Flags
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags = flags
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Html.text ("Flags: " ++ Debug.toString model.flags)
