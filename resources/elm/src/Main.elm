module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Events
import Browser.Navigation as Nav exposing (Key)
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Document exposing (Document)
import Flags exposing (Flags)
import Html exposing (Html)
import Http
import Inertia.PageData exposing (PageData)
import Json.Decode
import Layouts.Sidebar
import Pages
import Pages.Dashboard.Index
import Process
import Task
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
    , pageData : PageData Json.Decode.Value
    , xsrfToken : String
    , page : Pages.Model
    , sidebar : Layouts.Sidebar.Model
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        sidebar : Layouts.Sidebar.Model
        sidebar =
            Layouts.Sidebar.init

        context : Context
        context =
            { url = url
            , sidebar = sidebar
            }

        ( page, pageCmd ) =
            Pages.init context flags.pageData

        model : Model
        model =
            { url = url
            , key = key
            , pageData = flags.pageData
            , xsrfToken = flags.xsrfToken
            , page = page
            , sidebar = sidebar
            }
    in
    ( model
    , toCmd model (Effect.map Page pageCmd)
    )



-- UPDATE


type Msg
    = Page Pages.Msg
    | UrlChanged Url
    | UrlRequested UrlRequest
    | InertiaPageDataResponded Url (Result Http.Error (PageData Json.Decode.Value))
    | Sidebar Layouts.Sidebar.Msg
    | PressedEsc


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        UrlRequested (Browser.External href) ->
            ( model
            , Nav.load href
            )

        UrlChanged url ->
            ( { model | url = url }
            , toInertiaNavigateCmd model url
            )

        InertiaPageDataResponded url (Ok pageData) ->
            let
                context : Context
                context =
                    { url = url
                    , sidebar = model.sidebar
                    }

                ( page, pageCmd ) =
                    Pages.init context pageData
            in
            ( { model | pageData = pageData, page = page }
            , toCmd model (Effect.map Page pageCmd)
            )

        InertiaPageDataResponded url (Err httpError) ->
            -- TODO: Notify user of the problem, they might be offline!
            ( model
            , Nav.load (Url.toString url)
            )

        Page pageMsg ->
            let
                context : Context
                context =
                    { url = model.url
                    , sidebar = model.sidebar
                    }
            in
            Pages.update context pageMsg model.page
                |> Tuple.mapBoth
                    (\page -> { model | page = page })
                    (Effect.map Page >> toCmd model)

        Sidebar sidebarMsg ->
            Layouts.Sidebar.update
                { msg = sidebarMsg
                , model = model.sidebar
                , toModel = \sidebar -> { model | sidebar = sidebar }
                , toMsg = Sidebar
                }
                |> Tuple.mapSecond (toCmd model)

        PressedEsc ->
            ( { model | sidebar = Layouts.Sidebar.dismissDropdown model.sidebar }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        context : Context
        context =
            { url = model.url
            , sidebar = model.sidebar
            }
    in
    Sub.batch
        [ Pages.subscriptions context model.page
            |> Sub.map Page
        , Browser.Events.onKeyDown onEscDecoder
        ]


onEscDecoder : Json.Decode.Decoder Msg
onEscDecoder =
    Json.Decode.field "key" Json.Decode.string
        |> Json.Decode.andThen
            (\key ->
                if key == "Escape" then
                    Json.Decode.succeed PressedEsc

                else
                    Json.Decode.fail "Other key pressed"
            )



-- VIEW


view : Model -> Document Msg
view model =
    let
        context : Context
        context =
            { url = model.url
            , sidebar = model.sidebar
            }
    in
    Pages.view context model.page
        |> Extra.Document.map Page



-- PERFORMING EFFECTS


toCmd :
    Model
    -> Effect Msg
    -> Cmd Msg
toCmd model effect =
    case effect of
        Effect.None ->
            Cmd.none

        Effect.Batch effects ->
            Cmd.batch (List.map (toCmd model) effects)

        Effect.SendMsg msg ->
            Task.succeed msg
                |> Task.perform identity

        Effect.SendDelayedMsg delay msg ->
            Process.sleep delay
                |> Task.map (\_ -> msg)
                |> Task.perform identity

        Effect.SendSidebarMsg sidebarMsg ->
            Task.succeed sidebarMsg
                |> Task.perform Sidebar

        Effect.ShowProblem problem ->
            Debug.todo "SHOW PROBLEM"

        Effect.InertiaHttp req ->
            Http.request
                { method = req.method
                , url = req.url
                , headers =
                    [ Http.header "Accept" "text/html, application/xhtml+xml"
                    , Http.header "X-Requested-With" "XMLHttpRequest"
                    , Http.header "X-Inertia" "true"
                    , Http.header "X-XSRF-TOKEN" model.xsrfToken
                    ]
                , body = req.body
                , timeout = Nothing
                , tracker = Nothing
                , expect =
                    Http.expectJson (toHttpMsg model req)
                        (Inertia.PageData.decoder req.decoder)
                }


toHttpMsg :
    Model
    -> { req | onFailure : Http.Error -> Msg }
    -> Result Http.Error (PageData Msg)
    -> Msg
toHttpMsg ({ url } as model) req result =
    case result of
        Ok newPageData ->
            if model.pageData.component == newPageData.component then
                newPageData.props

            else
                -- TODO: This way of making a URL seems dumb
                UrlRequested
                    (Browser.Internal
                        { url
                            | path = newPageData.url
                            , fragment = Nothing
                            , query = Nothing
                        }
                    )

        Err httpError ->
            req.onFailure httpError



-- INERTIA NAVIGATION


toInertiaNavigateCmd : Model -> Url -> Cmd Msg
toInertiaNavigateCmd model url =
    if model.url == url then
        Cmd.none

    else
        Http.request
            { method = "GET"
            , url = url.path
            , headers =
                [ Http.header "Accept" "text/html, application/xhtml+xml"
                , Http.header "X-Requested-With" "XMLHttpRequest"
                , Http.header "X-Inertia" "true"
                , Http.header "X-XSRF-TOKEN" model.xsrfToken
                ]
            , body = Http.emptyBody
            , timeout = Nothing
            , tracker = Nothing
            , expect =
                Http.expectJson
                    (InertiaPageDataResponded url)
                    (Inertia.PageData.decoder Json.Decode.value)
            }
