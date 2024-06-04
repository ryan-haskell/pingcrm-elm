module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Document exposing (Document)
import Flags exposing (Flags)
import Html exposing (Html)
import Http
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
    | InertiaPageDataResponded Url (Result Http.Error PageData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , toInertiaNavigateCmd model url
            )

        UrlRequested (Browser.External href) ->
            ( model
            , Nav.load href
            )

        InertiaPageDataResponded url (Ok pageData) ->
            let
                context : Context
                context =
                    { url = url
                    }

                ( page, pageCmd ) =
                    Pages.init context pageData
            in
            ( { model | pageData = pageData, page = page }
            , Cmd.batch
                [ Nav.pushUrl model.key (Url.toString url)
                , toCmd model (Effect.map Page pageCmd)
                ]
            )

        InertiaPageDataResponded url (Err httpError) ->
            -- TODO: Notify user of the problem, they might be offline!
            ( model
            , Nav.load (Url.toString url)
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
                    }
            in
            Pages.update context pageMsg model.page
                |> Tuple.mapBoth
                    (\page -> { model | page = page })
                    (Effect.map Page >> toCmd model)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        context : Context
        context =
            { url = model.url
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
                        (Json.Decode.map4 PageDataWithProps
                            (Json.Decode.field "component" Json.Decode.string)
                            (Json.Decode.field "props" req.decoder)
                            (Json.Decode.field "url" Json.Decode.string)
                            (Json.Decode.field "version" Json.Decode.string)
                        )
                }


type alias PageDataWithProps =
    { component : String
    , props : Msg
    , url : String
    , version : String
    }


toHttpMsg : Model -> { req | onFailure : Http.Error -> Msg } -> Result Http.Error PageDataWithProps -> Msg
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
            , expect = Http.expectJson (InertiaPageDataResponded url) Inertia.PageData.decoder
            }
