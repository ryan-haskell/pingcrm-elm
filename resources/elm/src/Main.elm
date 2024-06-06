module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav exposing (Key)
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Document exposing (Document)
import Extra.Http
import Extra.Url
import Html exposing (Html)
import Http
import Interop exposing (Flags)
import Json.Decode
import Layouts.Sidebar
import Pages
import Pages.Dashboard
import Process
import Shared.PageData exposing (PageData)
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
        , onUrlRequest = UrlRequested LinkClicked
        }



-- MODEL


type alias Model =
    { url : Url
    , key : Key
    , page : Pages.Model
    , pageData : PageData Json.Decode.Value
    , xsrfToken : String
    , isMobile : Bool
    , urlRequestSource : UrlRequestSource
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        isMobile : Bool
        isMobile =
            flags.window.width <= toFloat mobileBreakpoint

        context : Context
        context =
            { url = url
            , isMobile = isMobile
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
            , isMobile = isMobile
            , urlRequestSource = AppLoaded
            }
    in
    ( model
    , toCmd model (Effect.map Page pageCmd)
    )



-- UPDATE


type Msg
    = Page Pages.Msg
    | UrlChanged Url
    | UrlRequested UrlRequestSource UrlRequest
    | InertiaPageDataResponded Url (Result Http.Error (PageData Json.Decode.Value))
    | Resize Int Int
    | XsrfTokenRefreshed String
    | ScrollFinished


type UrlRequestSource
    = AppLoaded
    | LinkClicked
    | InertiaHttp (PageData Json.Decode.Value)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequestSource (Browser.Internal url) ->
            ( { model | urlRequestSource = urlRequestSource }
            , Nav.pushUrl model.key (Url.toString url)
            )

        UrlRequested urlRequestSource (Browser.External href) ->
            ( { model | urlRequestSource = urlRequestSource }
            , Nav.load href
            )

        UrlChanged url ->
            if model.url == url then
                ( model, Cmd.none )

            else
                let
                    performInertiaGetRequest : Cmd Msg
                    performInertiaGetRequest =
                        Http.request
                            { method = "GET"
                            , url = Url.toString url
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
                                    (Shared.PageData.decoder Json.Decode.value)
                            }
                in
                ( { model | url = url }
                , case model.urlRequestSource of
                    AppLoaded ->
                        performInertiaGetRequest

                    LinkClicked ->
                        performInertiaGetRequest

                    InertiaHttp newPageData ->
                        if newPageData.component == model.pageData.component then
                            performInertiaGetRequest

                        else
                            Task.succeed (Ok newPageData)
                                |> Task.perform (InertiaPageDataResponded url)
                )

        InertiaPageDataResponded url (Ok pageData) ->
            let
                context : Context
                context =
                    { url = url
                    , isMobile = model.isMobile
                    }

                ( page, pageCmd ) =
                    if model.pageData.component == pageData.component then
                        Pages.onPropsChanged context pageData model.page

                    else
                        Pages.init context pageData
            in
            ( { model | pageData = pageData, page = page }
            , Cmd.batch
                [ toCmd model (Effect.map Page pageCmd)
                , Interop.refreshXsrfToken ()
                , scrollToTop
                ]
            )

        InertiaPageDataResponded url (Err httpError) ->
            ( model
            , Interop.reportNavigationError
                { url = Url.toString url
                , error = Extra.Http.toUserFriendlyMessage httpError
                }
            )

        Page pageMsg ->
            let
                context : Context
                context =
                    { url = model.url
                    , isMobile = model.isMobile
                    }
            in
            Pages.update context pageMsg model.page
                |> Tuple.mapBoth
                    (\page -> { model | page = page })
                    (Effect.map Page >> toCmd model)

        XsrfTokenRefreshed token ->
            ( { model | xsrfToken = token }
            , Cmd.none
            )

        Resize width height ->
            ( { model | isMobile = width <= mobileBreakpoint }
            , Cmd.none
            )

        ScrollFinished ->
            ( model, Cmd.none )


scrollToTop : Cmd Msg
scrollToTop =
    Browser.Dom.setViewportOf "scroll-region" 0 0
        |> Task.attempt (\_ -> ScrollFinished)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        context : Context
        context =
            { url = model.url
            , isMobile = model.isMobile
            }
    in
    Sub.batch
        [ Pages.subscriptions context model.page
            |> Sub.map Page
        , Browser.Events.onResize Resize
        , Interop.onXsrfTokenRefreshed XsrfTokenRefreshed
        ]



-- VIEW


view : Model -> Document Msg
view model =
    let
        context : Context
        context =
            { url = model.url
            , isMobile = model.isMobile
            }
    in
    Pages.view context model.page
        |> Extra.Document.map Page



-- EFFECTS


toCmd : Model -> Effect Msg -> Cmd Msg
toCmd model effect =
    effect
        |> Effect.switch
            { onNone = Cmd.none
            , onBatch = onBatch model
            , onSendMsg = onSendMsg model
            , onSendDelayedMsg = onSendDelayedMsg model
            , onInertiaHttp = onInertiaHttp model
            , onReportJsonDecodeError = onReportJsonDecodeError model
            , onPushUrl = onPushUrl model
            }


onBatch : Model -> List (Effect Msg) -> Cmd Msg
onBatch model effects =
    Cmd.batch (List.map (toCmd model) effects)


onSendMsg : Model -> Msg -> Cmd Msg
onSendMsg model msg =
    Task.succeed msg
        |> Task.perform identity


onSendDelayedMsg : Model -> Float -> Msg -> Cmd Msg
onSendDelayedMsg model delay msg =
    Process.sleep delay
        |> Task.map (\_ -> msg)
        |> Task.perform identity


onInertiaHttp : Model -> Extra.Http.Request Msg -> Cmd Msg
onInertiaHttp ({ url } as model) req =
    let
        toHttpMsg : Result Http.Error (PageData Json.Decode.Value) -> Msg
        toHttpMsg result =
            case result of
                Ok newPageData ->
                    if model.pageData.component == newPageData.component then
                        case Json.Decode.decodeValue req.decoder newPageData.props of
                            Ok msg ->
                                msg

                            Err jsonDecodeError ->
                                req.onFailure (Http.BadBody (Json.Decode.errorToString jsonDecodeError))

                    else
                        case Extra.Url.fromAbsoluteUrl newPageData.url url of
                            Just newUrl ->
                                UrlRequested (InertiaHttp newPageData) (Browser.Internal newUrl)

                            Nothing ->
                                UrlRequested (InertiaHttp newPageData) (Browser.External newPageData.url)

                Err httpError ->
                    req.onFailure httpError

        decoder : Json.Decode.Decoder (PageData Json.Decode.Value)
        decoder =
            Shared.PageData.decoder Json.Decode.value
    in
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
        , expect = Http.expectJson toHttpMsg decoder
        }


onReportJsonDecodeError : Model -> { page : String, error : Json.Decode.Error } -> Cmd Msg
onReportJsonDecodeError model { page, error } =
    Interop.reportJsonDecodeError
        { page = page
        , error = Json.Decode.errorToString error
        }


onPushUrl : Model -> String -> Cmd Msg
onPushUrl model url =
    Nav.pushUrl model.key url



-- CONSTANTS


mobileBreakpoint : Int
mobileBreakpoint =
    740
