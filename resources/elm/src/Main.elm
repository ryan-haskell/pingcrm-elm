module Main exposing (main)

import Browser
import Flags exposing (Flags)
import Html exposing (Html)
import Json.Decode
import Pages
import Pages.Dashboard.Index


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { page : Pages.Model
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( page, pageCmd ) =
            Pages.init flags.pageData
    in
    ( { page = page
      }
    , Cmd.map Page pageCmd
    )



-- UPDATE


type Msg
    = Page Pages.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Page pageMsg ->
            Pages.update pageMsg model.page
                |> Tuple.mapBoth
                    (\page -> { model | page = page })
                    (Cmd.map Page)


subscriptions : Model -> Sub Msg
subscriptions model =
    Pages.subscriptions model.page
        |> Sub.map Page



-- VIEW


view : Model -> Html Msg
view model =
    Pages.view model.page
        |> Html.map Page
