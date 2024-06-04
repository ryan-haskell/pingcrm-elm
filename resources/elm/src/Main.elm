module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Context exposing (Context)
import Extra.Document exposing (Document)
import Flags exposing (Flags)
import Html exposing (Html)
import Inertia.PageData exposing (PageData)
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
    , pageData : PageData
    , xsrfToken : String
    , page : Pages.Model
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        context : Context
        context =
            { url = url
            , xsrfToken = flags.xsrfToken
            }

        ( page, pageCmd ) =
            Pages.init context flags.pageData
    in
    ( { url = url
      , key = key
      , pageData = flags.pageData
      , xsrfToken = flags.xsrfToken
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
            let
                context : Context
                context =
                    { url = model.url
                    , xsrfToken = model.xsrfToken
                    }
            in
            Pages.update context pageMsg model.page
                |> Tuple.mapBoth
                    (\page -> { model | page = page })
                    (Cmd.map Page)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        context : Context
        context =
            { url = model.url
            , xsrfToken = model.xsrfToken
            }
    in
    Pages.subscriptions context model.page
        |> Sub.map Page



-- VIEW


view : Model -> Document Msg
view model =
    let
        context : Context
        context =
            { url = model.url
            , xsrfToken = model.xsrfToken
            }
    in
    Pages.view context model.page
        |> Extra.Document.map Page
