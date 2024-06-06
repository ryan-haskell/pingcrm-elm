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
import Json.Encode
import Pages.Contacts
import Pages.Contacts.Create
import Pages.Dashboard
import Pages.Error404
import Pages.Error500
import Pages.Login
import Pages.Organizations
import Pages.Organizations.Create
import Pages.Organizations.Edit
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
    | Model_Organizations_Edit Pages.Organizations.Edit.Model
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

        "Organizations/Edit" ->
            initPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.Edit.decoder
                , init = Pages.Organizations.Edit.init
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
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
    | Msg_Organizations_Edit Pages.Organizations.Edit.Msg
    | Msg_Contacts_Create Pages.Contacts.Create.Msg
    | Msg_Users_Create Pages.Users.Create.Msg
    | Msg_Contacts Pages.Contacts.Msg
    | Msg_Users Pages.Users.Msg
    | Msg_Reports Pages.Reports.Msg
    | Msg_Error404 Pages.Error404.Msg
    | Msg_Error500 Pages.Error500.Msg


update : Context -> PageData Json.Decode.Value -> Msg -> Model -> ( Model, Effect Msg )
update ctx pageData msg model =
    case ( msg, model ) of
        ( Msg_Login pageMsg, Model_Login pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Login.decoder
                , update = Pages.Login.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Login
                , toMsg = Msg_Login
                }

        ( Msg_Dashboard pageMsg, Model_Dashboard pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Dashboard.decoder
                , update = Pages.Dashboard.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Dashboard
                , toMsg = Msg_Dashboard
                }

        ( Msg_Organizations pageMsg, Model_Organizations pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Organizations.decoder
                , update = Pages.Organizations.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Organizations
                , toMsg = Msg_Organizations
                }

        ( Msg_Organizations_Create pageMsg, Model_Organizations_Create pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Organizations.Create.decoder
                , update = Pages.Organizations.Create.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        ( Msg_Organizations_Edit pageMsg, Model_Organizations_Edit pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Organizations.Edit.decoder
                , update = Pages.Organizations.Edit.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        ( Msg_Contacts pageMsg, Model_Contacts pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Contacts.decoder
                , update = Pages.Contacts.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Contacts
                , toMsg = Msg_Contacts
                }

        ( Msg_Contacts_Create pageMsg, Model_Contacts_Create pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Contacts.Create.decoder
                , update = Pages.Contacts.Create.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        ( Msg_Users pageMsg, Model_Users pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Users.decoder
                , update = Pages.Users.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Users
                , toMsg = Msg_Users
                }

        ( Msg_Users_Create pageMsg, Model_Users_Create pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Users.Create.decoder
                , update = Pages.Users.Create.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        ( Msg_Reports pageMsg, Model_Reports pageModel ) ->
            updatePage
                { context = ctx
                , pageData = pageData
                , decoder = Pages.Reports.decoder
                , update = Pages.Reports.update
                , msg = pageMsg
                , model = pageModel
                , toModel = Model_Reports
                , toMsg = Msg_Reports
                }

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

        Model_Organizations_Edit pageModel ->
            onPropsChangedPage
                { context = ctx
                , pageData = pageData
                , model = pageModel
                , decoder = Pages.Organizations.Edit.decoder
                , onPropsChanged = Pages.Organizations.Edit.onPropsChanged
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
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


subscriptions : Context -> PageData Json.Decode.Value -> Model -> Sub Msg
subscriptions context pageData model =
    case model of
        Model_Login pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Login.decoder
                , subscriptions = Pages.Login.subscriptions
                , model = pageModel
                , toMsg = Msg_Login
                }

        Model_Dashboard pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Dashboard.decoder
                , subscriptions = Pages.Dashboard.subscriptions
                , model = pageModel
                , toMsg = Msg_Dashboard
                }

        Model_Organizations pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.decoder
                , subscriptions = Pages.Organizations.subscriptions
                , model = pageModel
                , toMsg = Msg_Organizations
                }

        Model_Organizations_Create pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.Create.decoder
                , subscriptions = Pages.Organizations.Create.subscriptions
                , model = pageModel
                , toMsg = Msg_Organizations_Create
                }

        Model_Organizations_Edit pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.Edit.decoder
                , subscriptions = Pages.Organizations.Edit.subscriptions
                , model = pageModel
                , toMsg = Msg_Organizations_Edit
                }

        Model_Contacts pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Contacts.decoder
                , subscriptions = Pages.Contacts.subscriptions
                , model = pageModel
                , toMsg = Msg_Contacts
                }

        Model_Contacts_Create pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Contacts.Create.decoder
                , subscriptions = Pages.Contacts.Create.subscriptions
                , model = pageModel
                , toMsg = Msg_Contacts_Create
                }

        Model_Users pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Users.decoder
                , subscriptions = Pages.Users.subscriptions
                , model = pageModel
                , toMsg = Msg_Users
                }

        Model_Users_Create pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Users.Create.decoder
                , subscriptions = Pages.Users.Create.subscriptions
                , model = pageModel
                , toMsg = Msg_Users_Create
                }

        Model_Reports pageModel ->
            subscriptionsPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Reports.decoder
                , subscriptions = Pages.Reports.subscriptions
                , model = pageModel
                , toMsg = Msg_Reports
                }

        Model_Error404 pageModel ->
            Pages.Error404.subscriptions context pageModel
                |> Sub.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.subscriptions context pageModel
                |> Sub.map Msg_Error500



-- VIEW


view : Context -> PageData Json.Decode.Value -> Model -> Document Msg
view context pageData model =
    case model of
        Model_Login pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Login.decoder
                , view = Pages.Login.view
                , model = pageModel
                , toMsg = Msg_Login
                }

        Model_Dashboard pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Dashboard.decoder
                , view = Pages.Dashboard.view
                , model = pageModel
                , toMsg = Msg_Dashboard
                }

        Model_Organizations pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.decoder
                , view = Pages.Organizations.view
                , model = pageModel
                , toMsg = Msg_Organizations
                }

        Model_Organizations_Create pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.Create.decoder
                , view = Pages.Organizations.Create.view
                , model = pageModel
                , toMsg = Msg_Organizations_Create
                }

        Model_Organizations_Edit pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Organizations.Edit.decoder
                , view = Pages.Organizations.Edit.view
                , model = pageModel
                , toMsg = Msg_Organizations_Edit
                }

        Model_Contacts pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Contacts.decoder
                , view = Pages.Contacts.view
                , model = pageModel
                , toMsg = Msg_Contacts
                }

        Model_Contacts_Create pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Contacts.Create.decoder
                , view = Pages.Contacts.Create.view
                , model = pageModel
                , toMsg = Msg_Contacts_Create
                }

        Model_Users pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Users.decoder
                , view = Pages.Users.view
                , model = pageModel
                , toMsg = Msg_Users
                }

        Model_Users_Create pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Users.Create.decoder
                , view = Pages.Users.Create.view
                , model = pageModel
                , toMsg = Msg_Users_Create
                }

        Model_Reports pageModel ->
            viewPage
                { context = context
                , pageData = pageData
                , decoder = Pages.Reports.decoder
                , view = Pages.Reports.view
                , model = pageModel
                , toMsg = Msg_Reports
                }

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
    let
        _ =
            Debug.log "onPropsChanged - pages" (Json.Encode.encode 0 args.pageData.props)
    in
    case Json.Decode.decodeValue args.decoder args.pageData.props of
        Ok props ->
            args.onPropsChanged args.context props args.model
                |> Tuple.mapBoth args.toModel (Effect.map args.toMsg)

        Err jsonDecodeError ->
            Pages.Error500.init args.context
                { error = jsonDecodeError
                , page = args.pageData.component
                }
                |> Tuple.mapBoth Model_Error500 (Effect.map Msg_Error500)


updatePage :
    { context : Context
    , pageData : PageData Json.Decode.Value
    , decoder : Json.Decode.Decoder props
    , update : Context -> props -> msg -> model -> ( model, Effect msg )
    , msg : msg
    , model : model
    , toModel : model -> Model
    , toMsg : msg -> Msg
    }
    -> ( Model, Effect Msg )
updatePage args =
    case Json.Decode.decodeValue args.decoder args.pageData.props of
        Ok props ->
            args.update args.context props args.msg args.model
                |> Tuple.mapBoth args.toModel (Effect.map args.toMsg)

        Err jsonDecodeError ->
            Pages.Error500.init args.context
                { error = jsonDecodeError
                , page = args.pageData.component
                }
                |> Tuple.mapBoth Model_Error500 (Effect.map Msg_Error500)


subscriptionsPage :
    { context : Context
    , pageData : PageData Json.Decode.Value
    , decoder : Json.Decode.Decoder props
    , subscriptions : Context -> props -> model -> Sub msg
    , model : model
    , toMsg : msg -> Msg
    }
    -> Sub Msg
subscriptionsPage args =
    case Json.Decode.decodeValue args.decoder args.pageData.props of
        Ok props ->
            args.subscriptions args.context props args.model
                |> Sub.map args.toMsg

        Err jsonDecodeError ->
            Sub.none


viewPage :
    { context : Context
    , pageData : PageData Json.Decode.Value
    , decoder : Json.Decode.Decoder props
    , view : Context -> props -> model -> Document msg
    , model : model
    , toMsg : msg -> Msg
    }
    -> Document Msg
viewPage args =
    case Json.Decode.decodeValue args.decoder args.pageData.props of
        Ok props ->
            args.view args.context props args.model
                |> Extra.Document.map args.toMsg

        Err jsonDecodeError ->
            -- TODO: Is this the best thing to render here?
            -- Is it possible to get in this state?
            Extra.Document.none
