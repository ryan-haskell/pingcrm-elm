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
import Inertia exposing (PageObject)
import Json.Decode
import Json.Encode
import Pages.Contacts
import Pages.Contacts.Create
import Pages.Contacts.Edit
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
import Pages.Users.Edit
import Shared
import Url exposing (Url)



-- MODEL


type Model
    = Model_Login { props : Pages.Login.Props, model : Pages.Login.Model }
    | Model_Dashboard { props : Pages.Dashboard.Props, model : Pages.Dashboard.Model }
    | Model_Organizations { props : Pages.Organizations.Props, model : Pages.Organizations.Model }
    | Model_Organizations_Create { props : Pages.Organizations.Create.Props, model : Pages.Organizations.Create.Model }
    | Model_Organizations_Edit { props : Pages.Organizations.Edit.Props, model : Pages.Organizations.Edit.Model }
    | Model_Contacts { props : Pages.Contacts.Props, model : Pages.Contacts.Model }
    | Model_Contacts_Create { props : Pages.Contacts.Create.Props, model : Pages.Contacts.Create.Model }
    | Model_Contacts_Edit { props : Pages.Contacts.Edit.Props, model : Pages.Contacts.Edit.Model }
    | Model_Users { props : Pages.Users.Props, model : Pages.Users.Model }
    | Model_Users_Create { props : Pages.Users.Create.Props, model : Pages.Users.Create.Model }
    | Model_Users_Edit { props : Pages.Users.Edit.Props, model : Pages.Users.Edit.Model }
    | Model_Reports { props : Pages.Reports.Props, model : Pages.Reports.Model }
    | Model_Error404 Pages.Error404.Model
    | Model_Error500 Pages.Error500.Model


init : Shared.Model -> Url -> PageObject Json.Decode.Value -> ( Model, Effect Msg )
init shared url pageObject =
    case pageObject.component of
        "Auth/Login" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Login.decoder
                , init = Pages.Login.init
                , toModel = Model_Login
                , toMsg = Msg_Login
                }

        "Dashboard/Index" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Dashboard.decoder
                , init = Pages.Dashboard.init
                , toModel = Model_Dashboard
                , toMsg = Msg_Dashboard
                }

        "Organizations/Index" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Organizations.decoder
                , init = Pages.Organizations.init
                , toModel = Model_Organizations
                , toMsg = Msg_Organizations
                }

        "Organizations/Create" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Organizations.Create.decoder
                , init = Pages.Organizations.Create.init
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        "Organizations/Edit" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Organizations.Edit.decoder
                , init = Pages.Organizations.Edit.init
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        "Contacts/Index" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Contacts.decoder
                , init = Pages.Contacts.init
                , toModel = Model_Contacts
                , toMsg = Msg_Contacts
                }

        "Contacts/Create" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Contacts.Create.decoder
                , init = Pages.Contacts.Create.init
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        "Contacts/Edit" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Contacts.Edit.decoder
                , init = Pages.Contacts.Edit.init
                , toModel = Model_Contacts_Edit
                , toMsg = Msg_Contacts_Edit
                }

        "Users/Index" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Users.decoder
                , init = Pages.Users.init
                , toModel = Model_Users
                , toMsg = Msg_Users
                }

        "Users/Create" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Users.Create.decoder
                , init = Pages.Users.Create.init
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        "Users/Edit" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Users.Edit.decoder
                , init = Pages.Users.Edit.init
                , toModel = Model_Users_Edit
                , toMsg = Msg_Users_Edit
                }

        "Reports/Index" ->
            initPage
                { context = Context shared url
                , pageObject = pageObject
                , decoder = Pages.Reports.decoder
                , init = Pages.Reports.init
                , toModel = Model_Reports
                , toMsg = Msg_Reports
                }

        _ ->
            Pages.Error404.init (Context shared url)
                { page = pageObject.component
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
    | Msg_Contacts Pages.Contacts.Msg
    | Msg_Contacts_Create Pages.Contacts.Create.Msg
    | Msg_Contacts_Edit Pages.Contacts.Edit.Msg
    | Msg_Users Pages.Users.Msg
    | Msg_Users_Create Pages.Users.Create.Msg
    | Msg_Users_Edit Pages.Users.Edit.Msg
    | Msg_Reports Pages.Reports.Msg
    | Msg_Error404 Pages.Error404.Msg
    | Msg_Error500 Pages.Error500.Msg


update : Shared.Model -> Url -> PageObject Json.Decode.Value -> Msg -> Model -> ( Model, Effect Msg )
update shared url pageObject msg model =
    case ( msg, model ) of
        ( Msg_Login pageMsg, Model_Login page ) ->
            Pages.Login.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Login { props = page.props, model = m })
                    (Effect.map Msg_Login)

        ( Msg_Dashboard pageMsg, Model_Dashboard page ) ->
            Pages.Dashboard.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Dashboard { props = page.props, model = m })
                    (Effect.map Msg_Dashboard)

        ( Msg_Organizations pageMsg, Model_Organizations page ) ->
            Pages.Organizations.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Organizations { props = page.props, model = m })
                    (Effect.map Msg_Organizations)

        ( Msg_Organizations_Create pageMsg, Model_Organizations_Create page ) ->
            Pages.Organizations.Create.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Organizations_Create { props = page.props, model = m })
                    (Effect.map Msg_Organizations_Create)

        ( Msg_Organizations_Edit pageMsg, Model_Organizations_Edit page ) ->
            Pages.Organizations.Edit.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Organizations_Edit { props = page.props, model = m })
                    (Effect.map Msg_Organizations_Edit)

        ( Msg_Contacts pageMsg, Model_Contacts page ) ->
            Pages.Contacts.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Contacts { props = page.props, model = m })
                    (Effect.map Msg_Contacts)

        ( Msg_Contacts_Create pageMsg, Model_Contacts_Create page ) ->
            Pages.Contacts.Create.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Contacts_Create { props = page.props, model = m })
                    (Effect.map Msg_Contacts_Create)

        ( Msg_Contacts_Edit pageMsg, Model_Contacts_Edit page ) ->
            Pages.Contacts.Edit.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Contacts_Edit { props = page.props, model = m })
                    (Effect.map Msg_Contacts_Edit)

        ( Msg_Users pageMsg, Model_Users page ) ->
            Pages.Users.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Users { props = page.props, model = m })
                    (Effect.map Msg_Users)

        ( Msg_Users_Create pageMsg, Model_Users_Create page ) ->
            Pages.Users.Create.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Users_Create { props = page.props, model = m })
                    (Effect.map Msg_Users_Create)

        ( Msg_Users_Edit pageMsg, Model_Users_Edit page ) ->
            Pages.Users.Edit.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Users_Edit { props = page.props, model = m })
                    (Effect.map Msg_Users_Edit)

        ( Msg_Reports pageMsg, Model_Reports page ) ->
            Pages.Reports.update (Context shared url) page.props pageMsg page.model
                |> Tuple.mapBoth
                    (\m -> Model_Reports { props = page.props, model = m })
                    (Effect.map Msg_Reports)

        ( Msg_Error404 pageMsg, Model_Error404 pageModel ) ->
            Pages.Error404.update (Context shared url) pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Error404
                    (Effect.map Msg_Error404)

        ( Msg_Error500 pageMsg, Model_Error500 pageModel ) ->
            Pages.Error500.update (Context shared url) pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Error500
                    (Effect.map Msg_Error500)

        _ ->
            ( model
            , Effect.none
            )


onPropsChanged : Shared.Model -> Url -> PageObject Json.Decode.Value -> Model -> ( Model, Effect Msg )
onPropsChanged shared url pageObject model =
    case model of
        Model_Login page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Login.decoder
                , onPropsChanged = Pages.Login.onPropsChanged
                , toModel = Model_Login
                , toMsg = Msg_Login
                }

        Model_Dashboard page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Dashboard.decoder
                , onPropsChanged = Pages.Dashboard.onPropsChanged
                , toModel = Model_Dashboard
                , toMsg = Msg_Dashboard
                }

        Model_Organizations page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Organizations.decoder
                , onPropsChanged = Pages.Organizations.onPropsChanged
                , toModel = Model_Organizations
                , toMsg = Msg_Organizations
                }

        Model_Organizations_Create page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Organizations.Create.decoder
                , onPropsChanged = Pages.Organizations.Create.onPropsChanged
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        Model_Organizations_Edit page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Organizations.Edit.decoder
                , onPropsChanged = Pages.Organizations.Edit.onPropsChanged
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        Model_Contacts page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Contacts.decoder
                , onPropsChanged = Pages.Contacts.onPropsChanged
                , toModel = Model_Contacts
                , toMsg = Msg_Contacts
                }

        Model_Contacts_Create page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Contacts.Create.decoder
                , onPropsChanged = Pages.Contacts.Create.onPropsChanged
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        Model_Contacts_Edit page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Contacts.Edit.decoder
                , onPropsChanged = Pages.Contacts.Edit.onPropsChanged
                , toModel = Model_Contacts_Edit
                , toMsg = Msg_Contacts_Edit
                }

        Model_Users page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Users.decoder
                , onPropsChanged = Pages.Users.onPropsChanged
                , toModel = Model_Users
                , toMsg = Msg_Users
                }

        Model_Users_Create page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Users.Create.decoder
                , onPropsChanged = Pages.Users.Create.onPropsChanged
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        Model_Users_Edit page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Users.Edit.decoder
                , onPropsChanged = Pages.Users.Edit.onPropsChanged
                , toModel = Model_Users_Edit
                , toMsg = Msg_Users_Edit
                }

        Model_Reports page ->
            onPropsChangedPage
                { context = Context shared url
                , pageObject = pageObject
                , model = page.model
                , decoder = Pages.Reports.decoder
                , onPropsChanged = Pages.Reports.onPropsChanged
                , toModel = Model_Reports
                , toMsg = Msg_Reports
                }

        Model_Error404 pageModel ->
            ( model, Effect.none )

        Model_Error500 pageModel ->
            ( model, Effect.none )


subscriptions : Shared.Model -> Url -> PageObject Json.Decode.Value -> Model -> Sub Msg
subscriptions shared url pageObject model =
    case model of
        Model_Login page ->
            Pages.Login.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Login

        Model_Dashboard page ->
            Pages.Dashboard.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Dashboard

        Model_Organizations page ->
            Pages.Organizations.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Organizations

        Model_Organizations_Create page ->
            Pages.Organizations.Create.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Organizations_Create

        Model_Organizations_Edit page ->
            Pages.Organizations.Edit.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Organizations_Edit

        Model_Contacts page ->
            Pages.Contacts.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Contacts

        Model_Contacts_Create page ->
            Pages.Contacts.Create.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Contacts_Create

        Model_Contacts_Edit page ->
            Pages.Contacts.Edit.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Contacts_Edit

        Model_Users page ->
            Pages.Users.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Users

        Model_Users_Create page ->
            Pages.Users.Create.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Users_Create

        Model_Users_Edit page ->
            Pages.Users.Edit.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Users_Edit

        Model_Reports page ->
            Pages.Reports.subscriptions (Context shared url) page.props page.model
                |> Sub.map Msg_Reports

        Model_Error404 pageModel ->
            Pages.Error404.subscriptions (Context shared url) pageModel
                |> Sub.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.subscriptions (Context shared url) pageModel
                |> Sub.map Msg_Error500



-- VIEW


view : Shared.Model -> Url -> PageObject Json.Decode.Value -> Model -> Document Msg
view shared url pageObject model =
    case model of
        Model_Login page ->
            Pages.Login.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Login

        Model_Dashboard page ->
            Pages.Dashboard.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Dashboard

        Model_Organizations page ->
            Pages.Organizations.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Organizations

        Model_Organizations_Create page ->
            Pages.Organizations.Create.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Organizations_Create

        Model_Organizations_Edit page ->
            Pages.Organizations.Edit.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Organizations_Edit

        Model_Contacts page ->
            Pages.Contacts.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Contacts

        Model_Contacts_Create page ->
            Pages.Contacts.Create.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Contacts_Create

        Model_Contacts_Edit page ->
            Pages.Contacts.Edit.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Contacts_Edit

        Model_Users page ->
            Pages.Users.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Users

        Model_Users_Create page ->
            Pages.Users.Create.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Users_Create

        Model_Users_Edit page ->
            Pages.Users.Edit.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Users_Edit

        Model_Reports page ->
            Pages.Reports.view (Context shared url) page.props page.model
                |> Extra.Document.map Msg_Reports

        Model_Error404 pageModel ->
            Pages.Error404.view (Context shared url) pageModel
                |> Extra.Document.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.view (Context shared url) pageModel
                |> Extra.Document.map Msg_Error500



-- HELPERS


initPage :
    { context : Context
    , pageObject : PageObject Json.Decode.Value
    , decoder : Json.Decode.Decoder props
    , init : Context -> props -> ( pageModel, Effect pageMsg )
    , toModel : { props : props, model : pageModel } -> Model
    , toMsg : pageMsg -> Msg
    }
    -> ( Model, Effect Msg )
initPage args =
    case Json.Decode.decodeValue args.decoder args.pageObject.props of
        Ok props ->
            args.init args.context props
                |> Tuple.mapBoth
                    (\m -> args.toModel { model = m, props = props })
                    (Effect.map args.toMsg)

        Err jsonDecodeError ->
            Pages.Error500.init args.context
                { error = jsonDecodeError
                , component = args.pageObject.component
                }
                |> Tuple.mapBoth
                    Model_Error500
                    (Effect.map Msg_Error500)


onPropsChangedPage :
    { context : Context
    , pageObject : PageObject Json.Decode.Value
    , model : model
    , decoder : Json.Decode.Decoder props
    , onPropsChanged : Context -> props -> model -> ( model, Effect msg )
    , toModel : { props : props, model : model } -> Model
    , toMsg : msg -> Msg
    }
    -> ( Model, Effect Msg )
onPropsChangedPage args =
    case Json.Decode.decodeValue args.decoder args.pageObject.props of
        Ok props ->
            args.onPropsChanged args.context props args.model
                |> Tuple.mapBoth
                    (\m -> args.toModel { model = m, props = props })
                    (Effect.map args.toMsg)

        Err jsonDecodeError ->
            Pages.Error500.init args.context
                { error = jsonDecodeError
                , component = args.pageObject.component
                }
                |> Tuple.mapBoth Model_Error500 (Effect.map Msg_Error500)
