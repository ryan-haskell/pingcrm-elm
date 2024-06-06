module Pages exposing
    ( Model, Msg
    , init, update, subscriptions, view
    , onPropsChanged
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view
@docs onPropsChanged

-}

import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Document exposing (Document)
import Html exposing (Html)
import Json.Decode
import Pages.Contacts
import Pages.Contacts.Create
import Pages.Dashboard
import Pages.Error404
import Pages.Error500
import Pages.Login
import Pages.Organizations
import Pages.Organizations.Create
import Pages.Reports
import Pages.Users
import Pages.Users.Create
import Shared.PageData exposing (PageData)



-- MODEL


type Model
    = Model_Login Pages.Login.Model
    | Model_Dashboard Pages.Dashboard.Model
    | Model_Organizations Pages.Organizations.Model
    | Model_Organizations_Create Pages.Organizations.Create.Model
    | Model_Contacts_Create Pages.Contacts.Create.Model
    | Model_Users_Create Pages.Users.Create.Model
    | Model_Contacts Pages.Contacts.Model
    | Model_Users Pages.Users.Model
    | Model_Reports Pages.Reports.Model
    | Model_Error404 Pages.Error404.Model
    | Model_Error500 Pages.Error500.Model


init : Context -> PageData Json.Decode.Value -> ( Model, Effect Msg )
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

        "Organizations/Create" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.Create.decoder
                , init = Pages.Organizations.Create.init
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
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

        "Contacts/Create" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Contacts.Create.decoder
                , init = Pages.Contacts.Create.init
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
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

        "Users/Create" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Users.Create.decoder
                , init = Pages.Users.Create.init
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
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



-- UPDATE


type Msg
    = Msg_Login Pages.Login.Msg
    | Msg_Dashboard Pages.Dashboard.Msg
    | Msg_Organizations Pages.Organizations.Msg
    | Msg_Organizations_Create Pages.Organizations.Create.Msg
    | Msg_Contacts_Create Pages.Contacts.Create.Msg
    | Msg_Users_Create Pages.Users.Create.Msg
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

        ( Msg_Organizations_Create pageMsg, Model_Organizations_Create pageModel ) ->
            Pages.Organizations.Create.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Organizations_Create
                    (Effect.map Msg_Organizations_Create)

        ( Msg_Contacts pageMsg, Model_Contacts pageModel ) ->
            Pages.Contacts.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Contacts
                    (Effect.map Msg_Contacts)

        ( Msg_Contacts_Create pageMsg, Model_Contacts_Create pageModel ) ->
            Pages.Contacts.Create.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Contacts_Create
                    (Effect.map Msg_Contacts_Create)

        ( Msg_Users pageMsg, Model_Users pageModel ) ->
            Pages.Users.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Users
                    (Effect.map Msg_Users)

        ( Msg_Users_Create pageMsg, Model_Users_Create pageModel ) ->
            Pages.Users.Create.update ctx pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Users_Create
                    (Effect.map Msg_Users_Create)

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


onPropsChanged : Context -> PageData Json.Decode.Value -> Model -> ( Model, Effect Msg )
onPropsChanged ctx pageData model =
    case model of
        Model_Login pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Login.decoder
                , onPropsChanged = Pages.Login.onPropsChanged
                , toModel = Model_Login
                , toMsg = Msg_Login
                }

        Model_Dashboard pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Dashboard.decoder
                , onPropsChanged = Pages.Dashboard.onPropsChanged
                , toModel = Model_Dashboard
                , toMsg = Msg_Dashboard
                }

        Model_Organizations pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Organizations.decoder
                , onPropsChanged = Pages.Organizations.onPropsChanged
                , toModel = Model_Organizations
                , toMsg = Msg_Organizations
                }

        Model_Organizations_Create pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Organizations.Create.decoder
                , onPropsChanged = Pages.Organizations.Create.onPropsChanged
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        Model_Contacts pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Contacts.decoder
                , onPropsChanged = Pages.Contacts.onPropsChanged
                , toModel = Model_Contacts
                , toMsg = Msg_Contacts
                }

        Model_Contacts_Create pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Contacts.Create.decoder
                , onPropsChanged = Pages.Contacts.Create.onPropsChanged
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        Model_Users pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Users.decoder
                , onPropsChanged = Pages.Users.onPropsChanged
                , toModel = Model_Users
                , toMsg = Msg_Users
                }

        Model_Users_Create pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Users.Create.decoder
                , onPropsChanged = Pages.Users.Create.onPropsChanged
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        Model_Reports pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Reports.decoder
                , onPropsChanged = Pages.Reports.onPropsChanged
                , toModel = Model_Reports
                , toMsg = Msg_Reports
                }

        Model_Error404 pageModel ->
            ( model, Effect.none )

        Model_Error500 pageModel ->
            ( model, Effect.none )


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

        Model_Organizations_Create pageModel ->
            Pages.Organizations.Create.subscriptions context pageModel
                |> Sub.map Msg_Organizations_Create

        Model_Contacts pageModel ->
            Pages.Contacts.subscriptions context pageModel
                |> Sub.map Msg_Contacts

        Model_Contacts_Create pageModel ->
            Pages.Contacts.Create.subscriptions context pageModel
                |> Sub.map Msg_Contacts_Create

        Model_Users pageModel ->
            Pages.Users.subscriptions context pageModel
                |> Sub.map Msg_Users

        Model_Users_Create pageModel ->
            Pages.Users.Create.subscriptions context pageModel
                |> Sub.map Msg_Users_Create

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

        Model_Organizations_Create pageModel ->
            Pages.Organizations.Create.view context pageModel
                |> Extra.Document.map Msg_Organizations_Create

        Model_Contacts pageModel ->
            Pages.Contacts.view context pageModel
                |> Extra.Document.map Msg_Contacts

        Model_Contacts_Create pageModel ->
            Pages.Contacts.Create.view context pageModel
                |> Extra.Document.map Msg_Contacts_Create

        Model_Users pageModel ->
            Pages.Users.view context pageModel
                |> Extra.Document.map Msg_Users

        Model_Users_Create pageModel ->
            Pages.Users.Create.view context pageModel
                |> Extra.Document.map Msg_Users_Create

        Model_Reports pageModel ->
            Pages.Reports.view context pageModel
                |> Extra.Document.map Msg_Reports

        Model_Error404 pageModel ->
            Pages.Error404.view context pageModel
                |> Extra.Document.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.view context pageModel
                |> Extra.Document.map Msg_Error500



-- HELPERS


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


onPropsChangedPage :
    { context : Context
    , pageData : PageData Json.Decode.Value
    , model : model
    , decoder : Json.Decode.Decoder props
    , onPropsChanged : Context -> props -> model -> ( model, Effect msg )
    , toModel : model -> Model
    , toMsg : msg -> Msg
    }
    -> ( Model, Effect Msg )
onPropsChangedPage args =
    case Json.Decode.decodeValue args.decoder args.pageData.props of
        Ok props ->
            args.onPropsChanged args.context props args.model
                |> Tuple.mapBoth args.toModel (Effect.map args.toMsg)

        Err jsonDecodeError ->
            Pages.Error500.init args.context
                { error = jsonDecodeError
                , page = args.pageData.component
                }
                |> Tuple.mapBoth
                    Model_Error500
                    (Effect.map Msg_Error500)
