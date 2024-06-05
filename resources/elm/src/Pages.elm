module Pages exposing
    ( Model
    , Msg
    , init
    , onPropsChanged
    , subscriptions
    , update
    , view
    )

import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Document exposing (Document)
import Html exposing (Html)
import Inertia.PageData exposing (PageData)
import Json.Decode
import Pages.Contacts
import Pages.Dashboard
import Pages.Error404
import Pages.Error500
import Pages.Login
import Pages.Organizations
import Pages.Reports
import Pages.Users



-- MODEL


type Model
    = Model_Login Pages.Login.Model
    | Model_Dashboard Pages.Dashboard.Model
    | Model_Organizations Pages.Organizations.Model
    | Model_Contacts Pages.Contacts.Model
    | Model_Users Pages.Users.Model
    | Model_Reports Pages.Reports.Model
    | Model_Error404 Pages.Error404.Model
    | Model_Error500 Pages.Error500.Model


init :
    Context
    -> PageData Json.Decode.Value
    -> ( Model, Effect Msg )
init context pageData =
    case pageData.component of
        "Auth/Login" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Login.decoder
                , init = Pages.Login.init
                , toModel = Model_Login
                , toMsg = Msg_Login
                }

        "Dashboard/Index" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Dashboard.decoder
                , init = Pages.Dashboard.init
                , toModel = Model_Dashboard
                , toMsg = Msg_Dashboard
                }

        "Organizations/Index" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.decoder
                , init = Pages.Organizations.init
                , toModel = Model_Organizations
                , toMsg = Msg_Organizations
                }

        "Contacts/Index" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Contacts.decoder
                , init = Pages.Contacts.init
                , toModel = Model_Contacts
                , toMsg = Msg_Contacts
                }

        "Users/Index" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Users.decoder
                , init = Pages.Users.init
                , toModel = Model_Users
                , toMsg = Msg_Users
                }

        "Reports/Index" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Reports.decoder
                , init = Pages.Reports.init
                , toModel = Model_Reports
                , toMsg = Msg_Reports
                }

        _ ->
            Pages.Error404.init context
                { page = pageData.component
                }
                |> Tuple.mapBoth
                    Model_Error404
                    (Effect.map Msg_Error404)


onPropsChanged :
    Context
    -> PageData Json.Decode.Value
    -> Model
    -> ( Model, Effect Msg )
onPropsChanged ctx pageData model =
    case model of
        Model_Login pageModel ->
            case Json.Decode.decodeValue Pages.Login.decoder pageData.props of
                Ok props ->
                    Pages.Login.onPropsChanged ctx props pageModel
                        |> Tuple.mapBoth
                            Model_Login
                            (Effect.map Msg_Login)

                Err jsonDecodeError ->
                    Pages.Error500.init ctx
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Effect.map Msg_Error500)

        Model_Dashboard pageModel ->
            case Json.Decode.decodeValue Pages.Dashboard.decoder pageData.props of
                Ok props ->
                    Pages.Dashboard.onPropsChanged ctx props pageModel
                        |> Tuple.mapBoth
                            Model_Dashboard
                            (Effect.map Msg_Dashboard)

                Err jsonDecodeError ->
                    Pages.Error500.init ctx
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Effect.map Msg_Error500)

        Model_Organizations pageModel ->
            case Json.Decode.decodeValue Pages.Organizations.decoder pageData.props of
                Ok props ->
                    Pages.Organizations.onPropsChanged ctx props pageModel
                        |> Tuple.mapBoth
                            Model_Organizations
                            (Effect.map Msg_Organizations)

                Err jsonDecodeError ->
                    Pages.Error500.init ctx
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Effect.map Msg_Error500)

        Model_Contacts pageModel ->
            case Json.Decode.decodeValue Pages.Contacts.decoder pageData.props of
                Ok props ->
                    Pages.Contacts.onPropsChanged ctx props pageModel
                        |> Tuple.mapBoth
                            Model_Contacts
                            (Effect.map Msg_Contacts)

                Err jsonDecodeError ->
                    Pages.Error500.init ctx
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Effect.map Msg_Error500)

        Model_Users pageModel ->
            case Json.Decode.decodeValue Pages.Users.decoder pageData.props of
                Ok props ->
                    Pages.Users.onPropsChanged ctx props pageModel
                        |> Tuple.mapBoth
                            Model_Users
                            (Effect.map Msg_Users)

                Err jsonDecodeError ->
                    Pages.Error500.init ctx
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Effect.map Msg_Error500)

        Model_Reports pageModel ->
            case Json.Decode.decodeValue Pages.Reports.decoder pageData.props of
                Ok props ->
                    Pages.Reports.onPropsChanged ctx props pageModel
                        |> Tuple.mapBoth
                            Model_Reports
                            (Effect.map Msg_Reports)

                Err jsonDecodeError ->
                    Pages.Error500.init ctx
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Effect.map Msg_Error500)

        Model_Error404 pageModel ->
            ( model, Effect.none )

        Model_Error500 pageModel ->
            ( model, Effect.none )



-- UPDATE


type Msg
    = Msg_Login Pages.Login.Msg
    | Msg_Dashboard Pages.Dashboard.Msg
    | Msg_Organizations Pages.Organizations.Msg
    | Msg_Contacts Pages.Contacts.Msg
    | Msg_Users Pages.Users.Msg
    | Msg_Reports Pages.Reports.Msg
    | Msg_Error404 Pages.Error404.Msg
    | Msg_Error500 Pages.Error500.Msg


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg model =
    case ( msg, model ) of
        ( Msg_Login pageMsg, Model_Login pageModel ) ->
            Pages.Login.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Login
                    (Effect.map Msg_Login)

        ( Msg_Dashboard pageMsg, Model_Dashboard pageModel ) ->
            Pages.Dashboard.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Dashboard
                    (Effect.map Msg_Dashboard)

        ( Msg_Organizations pageMsg, Model_Organizations pageModel ) ->
            Pages.Organizations.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Organizations
                    (Effect.map Msg_Organizations)

        ( Msg_Contacts pageMsg, Model_Contacts pageModel ) ->
            Pages.Contacts.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Contacts
                    (Effect.map Msg_Contacts)

        ( Msg_Users pageMsg, Model_Users pageModel ) ->
            Pages.Users.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Users
                    (Effect.map Msg_Users)

        ( Msg_Reports pageMsg, Model_Reports pageModel ) ->
            Pages.Reports.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Reports
                    (Effect.map Msg_Reports)

        ( Msg_Error404 pageMsg, Model_Error404 pageModel ) ->
            Pages.Error404.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Error404
                    (Effect.map Msg_Error404)

        ( Msg_Error500 pageMsg, Model_Error500 pageModel ) ->
            Pages.Error500.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Error500
                    (Effect.map Msg_Error500)

        _ ->
            ( model
            , Effect.none
            )


subscriptions : Context -> Model -> Sub Msg
subscriptions context model =
    case model of
        Model_Login pageModel ->
            Pages.Login.subscriptions context pageModel
                |> Sub.map Msg_Login

        Model_Dashboard pageModel ->
            Pages.Dashboard.subscriptions context pageModel
                |> Sub.map Msg_Dashboard

        Model_Organizations pageModel ->
            Pages.Organizations.subscriptions context pageModel
                |> Sub.map Msg_Organizations

        Model_Contacts pageModel ->
            Pages.Contacts.subscriptions context pageModel
                |> Sub.map Msg_Contacts

        Model_Users pageModel ->
            Pages.Users.subscriptions context pageModel
                |> Sub.map Msg_Users

        Model_Reports pageModel ->
            Pages.Reports.subscriptions context pageModel
                |> Sub.map Msg_Reports

        Model_Error404 pageModel ->
            Pages.Error404.subscriptions context pageModel
                |> Sub.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.subscriptions context pageModel
                |> Sub.map Msg_Error500



-- VIEW


view : Context -> Model -> Document Msg
view context model =
    case model of
        Model_Login pageModel ->
            Pages.Login.view context pageModel
                |> Extra.Document.map Msg_Login

        Model_Dashboard pageModel ->
            Pages.Dashboard.view context pageModel
                |> Extra.Document.map Msg_Dashboard

        Model_Organizations pageModel ->
            Pages.Organizations.view context pageModel
                |> Extra.Document.map Msg_Organizations

        Model_Contacts pageModel ->
            Pages.Contacts.view context pageModel
                |> Extra.Document.map Msg_Contacts

        Model_Users pageModel ->
            Pages.Users.view context pageModel
                |> Extra.Document.map Msg_Users

        Model_Reports pageModel ->
            Pages.Reports.view context pageModel
                |> Extra.Document.map Msg_Reports

        Model_Error404 pageModel ->
            Pages.Error404.view context pageModel
                |> Extra.Document.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.view context pageModel
                |> Extra.Document.map Msg_Error500



-- UTILS


initPage :
    { context : Context
    , pageData : PageData Json.Decode.Value
    , decoder : Json.Decode.Decoder props
    , init : Context -> props -> ( pageModel, Effect pageMsg )
    , toModel : pageModel -> Model
    , toMsg : pageMsg -> Msg
    }
    -> ( Model, Effect Msg )
initPage options =
    case Json.Decode.decodeValue options.decoder options.pageData.props of
        Ok props ->
            options.init options.context props
                |> Tuple.mapBoth
                    options.toModel
                    (Effect.map options.toMsg)

        Err jsonDecodeError ->
            Pages.Error500.init options.context
                { error = jsonDecodeError
                , page = options.pageData.component
                }
                |> Tuple.mapBoth
                    Model_Error500
                    (Effect.map Msg_Error500)
