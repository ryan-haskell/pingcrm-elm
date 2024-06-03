module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Extra.Document exposing (Document)
import Flags exposing (Flags)
import Html exposing (Html)
import Json.Decode
import Pages
import Pages.Dashboard.Index
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- MODEL


type alias Model =
    { url : Url
    , key : Key
    , page : Pages.Model
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( page, pageCmd ) =
            Pages.init flags.pageData
    in
    ( { url = url
      , key = key
      , page = page
      }
    , Cmd.map Page pageCmd
    )



-- UPDATE


type Msg
    = Page Pages.Msg
    | UrlChanged Url
    | UrlRequested UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , Nav.load (Url.toString url)
            )

        UrlRequested (Browser.External href) ->
            ( model
            , Nav.load href
            )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

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


view : Model -> Document Msg
view model =
    Pages.view model.page
        |> Extra.Document.map Page
