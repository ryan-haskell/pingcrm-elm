module Pages exposing (Model, Msg, init, onPropsChanged, subscriptions, update, view)

import Browser exposing (Document)
import Effect exposing (Effect)
import Html
import Inertia exposing (PageObject)
import Json.Decode exposing (Value)
import Pages.Auth.Login
import Pages.Contacts.Create
import Pages.Contacts.Edit
import Pages.Contacts.Index
import Pages.Dashboard.Index
import Pages.Organizations.Create
import Pages.Organizations.Edit
import Pages.Organizations.Index
import Pages.Reports.Index
import Pages.Users.Create
import Pages.Users.Edit
import Pages.Users.Index
import Pages.Error404
import Pages.Error500
import Shared
import Url exposing (Url)


type Model
    = Model_Auth_Login { props : Pages.Auth.Login.Props, model : Pages.Auth.Login.Model }
    | Model_Contacts_Create { props : Pages.Contacts.Create.Props, model : Pages.Contacts.Create.Model }
    | Model_Contacts_Edit { props : Pages.Contacts.Edit.Props, model : Pages.Contacts.Edit.Model }
    | Model_Contacts_Index { props : Pages.Contacts.Index.Props, model : Pages.Contacts.Index.Model }
    | Model_Dashboard_Index { props : Pages.Dashboard.Index.Props, model : Pages.Dashboard.Index.Model }
    | Model_Organizations_Create { props : Pages.Organizations.Create.Props, model : Pages.Organizations.Create.Model }
    | Model_Organizations_Edit { props : Pages.Organizations.Edit.Props, model : Pages.Organizations.Edit.Model }
    | Model_Organizations_Index { props : Pages.Organizations.Index.Props, model : Pages.Organizations.Index.Model }
    | Model_Reports_Index { props : Pages.Reports.Index.Props, model : Pages.Reports.Index.Model }
    | Model_Users_Create { props : Pages.Users.Create.Props, model : Pages.Users.Create.Model }
    | Model_Users_Edit { props : Pages.Users.Edit.Props, model : Pages.Users.Edit.Model }
    | Model_Users_Index { props : Pages.Users.Index.Props, model : Pages.Users.Index.Model }
    | Model_Error404 { model : Pages.Error404.Model }
    | Model_Error500 { info : Pages.Error500.Info, model : Pages.Error500.Model }


type Msg
    = Msg_Auth_Login Pages.Auth.Login.Msg
    | Msg_Contacts_Create Pages.Contacts.Create.Msg
    | Msg_Contacts_Edit Pages.Contacts.Edit.Msg
    | Msg_Contacts_Index Pages.Contacts.Index.Msg
    | Msg_Dashboard_Index Pages.Dashboard.Index.Msg
    | Msg_Organizations_Create Pages.Organizations.Create.Msg
    | Msg_Organizations_Edit Pages.Organizations.Edit.Msg
    | Msg_Organizations_Index Pages.Organizations.Index.Msg
    | Msg_Reports_Index Pages.Reports.Index.Msg
    | Msg_Users_Create Pages.Users.Create.Msg
    | Msg_Users_Edit Pages.Users.Edit.Msg
    | Msg_Users_Index Pages.Users.Index.Msg
    | Msg_Error404 Pages.Error404.Msg
    | Msg_Error500 Pages.Error500.Msg


init : Shared.Model -> Url -> PageObject Value -> ( Model, Effect Msg )
init shared url pageObject =
    case pageObject.component of
        "Auth/Login" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Auth.Login.decoder
                , init = Pages.Auth.Login.init
                , toModel = Model_Auth_Login
                , toMsg = Msg_Auth_Login
                }

        "Contacts/Create" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Contacts.Create.decoder
                , init = Pages.Contacts.Create.init
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        "Contacts/Edit" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Contacts.Edit.decoder
                , init = Pages.Contacts.Edit.init
                , toModel = Model_Contacts_Edit
                , toMsg = Msg_Contacts_Edit
                }

        "Contacts/Index" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Contacts.Index.decoder
                , init = Pages.Contacts.Index.init
                , toModel = Model_Contacts_Index
                , toMsg = Msg_Contacts_Index
                }

        "Dashboard/Index" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Dashboard.Index.decoder
                , init = Pages.Dashboard.Index.init
                , toModel = Model_Dashboard_Index
                , toMsg = Msg_Dashboard_Index
                }

        "Organizations/Create" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Organizations.Create.decoder
                , init = Pages.Organizations.Create.init
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        "Organizations/Edit" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Organizations.Edit.decoder
                , init = Pages.Organizations.Edit.init
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        "Organizations/Index" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Organizations.Index.decoder
                , init = Pages.Organizations.Index.init
                , toModel = Model_Organizations_Index
                , toMsg = Msg_Organizations_Index
                }

        "Reports/Index" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Reports.Index.decoder
                , init = Pages.Reports.Index.init
                , toModel = Model_Reports_Index
                , toMsg = Msg_Reports_Index
                }

        "Users/Create" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Users.Create.decoder
                , init = Pages.Users.Create.init
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        "Users/Edit" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Users.Edit.decoder
                , init = Pages.Users.Edit.init
                , toModel = Model_Users_Edit
                , toMsg = Msg_Users_Edit
                }

        "Users/Index" ->
            initForPage shared url pageObject <|
                { decoder = Pages.Users.Index.decoder
                , init = Pages.Users.Index.init
                , toModel = Model_Users_Index
                , toMsg = Msg_Users_Index
                }

        _ ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Error404.init shared url
            in
            ( Model_Error404 { model = pageModel }
            , Effect.map Msg_Error404 pageEffect
            )


update : Shared.Model -> Url -> PageObject Value -> Msg -> Model -> ( Model, Effect Msg )
update shared url pageObject msg model =
    case ( msg, model ) of
        ( Msg_Auth_Login pageMsg, Model_Auth_Login page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Auth.Login.update shared url page.props pageMsg page.model
            in
            ( Model_Auth_Login { page | model = pageModel }
            , Effect.map Msg_Auth_Login pageEffect
            )

        ( Msg_Contacts_Create pageMsg, Model_Contacts_Create page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Contacts.Create.update shared url page.props pageMsg page.model
            in
            ( Model_Contacts_Create { page | model = pageModel }
            , Effect.map Msg_Contacts_Create pageEffect
            )

        ( Msg_Contacts_Edit pageMsg, Model_Contacts_Edit page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Contacts.Edit.update shared url page.props pageMsg page.model
            in
            ( Model_Contacts_Edit { page | model = pageModel }
            , Effect.map Msg_Contacts_Edit pageEffect
            )

        ( Msg_Contacts_Index pageMsg, Model_Contacts_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Contacts.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Contacts_Index { page | model = pageModel }
            , Effect.map Msg_Contacts_Index pageEffect
            )

        ( Msg_Dashboard_Index pageMsg, Model_Dashboard_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Dashboard.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Dashboard_Index { page | model = pageModel }
            , Effect.map Msg_Dashboard_Index pageEffect
            )

        ( Msg_Organizations_Create pageMsg, Model_Organizations_Create page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Organizations.Create.update shared url page.props pageMsg page.model
            in
            ( Model_Organizations_Create { page | model = pageModel }
            , Effect.map Msg_Organizations_Create pageEffect
            )

        ( Msg_Organizations_Edit pageMsg, Model_Organizations_Edit page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Organizations.Edit.update shared url page.props pageMsg page.model
            in
            ( Model_Organizations_Edit { page | model = pageModel }
            , Effect.map Msg_Organizations_Edit pageEffect
            )

        ( Msg_Organizations_Index pageMsg, Model_Organizations_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Organizations.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Organizations_Index { page | model = pageModel }
            , Effect.map Msg_Organizations_Index pageEffect
            )

        ( Msg_Reports_Index pageMsg, Model_Reports_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Reports.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Reports_Index { page | model = pageModel }
            , Effect.map Msg_Reports_Index pageEffect
            )

        ( Msg_Users_Create pageMsg, Model_Users_Create page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Users.Create.update shared url page.props pageMsg page.model
            in
            ( Model_Users_Create { page | model = pageModel }
            , Effect.map Msg_Users_Create pageEffect
            )

        ( Msg_Users_Edit pageMsg, Model_Users_Edit page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Users.Edit.update shared url page.props pageMsg page.model
            in
            ( Model_Users_Edit { page | model = pageModel }
            , Effect.map Msg_Users_Edit pageEffect
            )

        ( Msg_Users_Index pageMsg, Model_Users_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Users.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Users_Index { page | model = pageModel }
            , Effect.map Msg_Users_Index pageEffect
            )

        ( Msg_Error404 pageMsg, Model_Error404 page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Error404.update shared url pageMsg page.model
            in
            ( Model_Error404 { page | model = pageModel }
            , Effect.map Msg_Error404 pageEffect
            )

        ( Msg_Error500 pageMsg, Model_Error500 page ) ->
            let
                ( pageModel, pageEffect ) =
                    Pages.Error500.update shared url page.info pageMsg page.model
            in
            ( Model_Error500 { page | model = pageModel }
            , Effect.map Msg_Error500 pageEffect
            )

        _ ->
            ( model, Effect.none )


subscriptions : Shared.Model -> Url -> PageObject Value -> Model -> Sub Msg
subscriptions shared url pageObject model =
    case model of
        Model_Auth_Login page ->
            Pages.Auth.Login.subscriptions shared url page.props page.model
                |> Sub.map Msg_Auth_Login

        Model_Contacts_Create page ->
            Pages.Contacts.Create.subscriptions shared url page.props page.model
                |> Sub.map Msg_Contacts_Create

        Model_Contacts_Edit page ->
            Pages.Contacts.Edit.subscriptions shared url page.props page.model
                |> Sub.map Msg_Contacts_Edit

        Model_Contacts_Index page ->
            Pages.Contacts.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Contacts_Index

        Model_Dashboard_Index page ->
            Pages.Dashboard.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Dashboard_Index

        Model_Organizations_Create page ->
            Pages.Organizations.Create.subscriptions shared url page.props page.model
                |> Sub.map Msg_Organizations_Create

        Model_Organizations_Edit page ->
            Pages.Organizations.Edit.subscriptions shared url page.props page.model
                |> Sub.map Msg_Organizations_Edit

        Model_Organizations_Index page ->
            Pages.Organizations.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Organizations_Index

        Model_Reports_Index page ->
            Pages.Reports.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Reports_Index

        Model_Users_Create page ->
            Pages.Users.Create.subscriptions shared url page.props page.model
                |> Sub.map Msg_Users_Create

        Model_Users_Edit page ->
            Pages.Users.Edit.subscriptions shared url page.props page.model
                |> Sub.map Msg_Users_Edit

        Model_Users_Index page ->
            Pages.Users.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Users_Index

        Model_Error404 page ->
            Pages.Error404.subscriptions shared url page.model
                |> Sub.map Msg_Error404

        Model_Error500 page ->
            Pages.Error500.subscriptions shared url page.info page.model
                |> Sub.map Msg_Error500


view : Shared.Model -> Url -> PageObject Value -> Model -> Document Msg
view shared url pageObject model =
    case model of
        Model_Auth_Login page ->
            Pages.Auth.Login.view shared url page.props page.model
                |> mapDocument Msg_Auth_Login

        Model_Contacts_Create page ->
            Pages.Contacts.Create.view shared url page.props page.model
                |> mapDocument Msg_Contacts_Create

        Model_Contacts_Edit page ->
            Pages.Contacts.Edit.view shared url page.props page.model
                |> mapDocument Msg_Contacts_Edit

        Model_Contacts_Index page ->
            Pages.Contacts.Index.view shared url page.props page.model
                |> mapDocument Msg_Contacts_Index

        Model_Dashboard_Index page ->
            Pages.Dashboard.Index.view shared url page.props page.model
                |> mapDocument Msg_Dashboard_Index

        Model_Organizations_Create page ->
            Pages.Organizations.Create.view shared url page.props page.model
                |> mapDocument Msg_Organizations_Create

        Model_Organizations_Edit page ->
            Pages.Organizations.Edit.view shared url page.props page.model
                |> mapDocument Msg_Organizations_Edit

        Model_Organizations_Index page ->
            Pages.Organizations.Index.view shared url page.props page.model
                |> mapDocument Msg_Organizations_Index

        Model_Reports_Index page ->
            Pages.Reports.Index.view shared url page.props page.model
                |> mapDocument Msg_Reports_Index

        Model_Users_Create page ->
            Pages.Users.Create.view shared url page.props page.model
                |> mapDocument Msg_Users_Create

        Model_Users_Edit page ->
            Pages.Users.Edit.view shared url page.props page.model
                |> mapDocument Msg_Users_Edit

        Model_Users_Index page ->
            Pages.Users.Index.view shared url page.props page.model
                |> mapDocument Msg_Users_Index

        Model_Error404 page ->
            Pages.Error404.view shared url page.model
                |> mapDocument Msg_Error404

        Model_Error500 page ->
            Pages.Error500.view shared url page.info page.model
                |> mapDocument Msg_Error500


onPropsChanged :
    Shared.Model
    -> Url
    -> PageObject Value
    -> Model
    -> ( Model, Effect Msg )
onPropsChanged shared url pageObject model =
    case model of
        Model_Auth_Login page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Auth.Login.decoder
                , onPropsChanged = Pages.Auth.Login.onPropsChanged
                , toModel = Model_Auth_Login
                , toMsg = Msg_Auth_Login
                }

        Model_Contacts_Create page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Contacts.Create.decoder
                , onPropsChanged = Pages.Contacts.Create.onPropsChanged
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        Model_Contacts_Edit page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Contacts.Edit.decoder
                , onPropsChanged = Pages.Contacts.Edit.onPropsChanged
                , toModel = Model_Contacts_Edit
                , toMsg = Msg_Contacts_Edit
                }

        Model_Contacts_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Contacts.Index.decoder
                , onPropsChanged = Pages.Contacts.Index.onPropsChanged
                , toModel = Model_Contacts_Index
                , toMsg = Msg_Contacts_Index
                }

        Model_Dashboard_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Dashboard.Index.decoder
                , onPropsChanged = Pages.Dashboard.Index.onPropsChanged
                , toModel = Model_Dashboard_Index
                , toMsg = Msg_Dashboard_Index
                }

        Model_Organizations_Create page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Organizations.Create.decoder
                , onPropsChanged = Pages.Organizations.Create.onPropsChanged
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        Model_Organizations_Edit page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Organizations.Edit.decoder
                , onPropsChanged = Pages.Organizations.Edit.onPropsChanged
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        Model_Organizations_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Organizations.Index.decoder
                , onPropsChanged = Pages.Organizations.Index.onPropsChanged
                , toModel = Model_Organizations_Index
                , toMsg = Msg_Organizations_Index
                }

        Model_Reports_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Reports.Index.decoder
                , onPropsChanged = Pages.Reports.Index.onPropsChanged
                , toModel = Model_Reports_Index
                , toMsg = Msg_Reports_Index
                }

        Model_Users_Create page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Users.Create.decoder
                , onPropsChanged = Pages.Users.Create.onPropsChanged
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        Model_Users_Edit page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Users.Edit.decoder
                , onPropsChanged = Pages.Users.Edit.onPropsChanged
                , toModel = Model_Users_Edit
                , toMsg = Msg_Users_Edit
                }

        Model_Users_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Pages.Users.Index.decoder
                , onPropsChanged = Pages.Users.Index.onPropsChanged
                , toModel = Model_Users_Index
                , toMsg = Msg_Users_Index
                }

        Model_Error404 page ->
            ( model, Effect.none )

        Model_Error500 page ->
            ( model, Effect.none )



-- HELPERS


mapDocument : (a -> b) -> Browser.Document a -> Browser.Document b
mapDocument fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }


onPropsChangedForPage :
    Shared.Model
    -> Url
    -> PageObject Value
    -> { props : props, model : model }
    ->
        { decoder : Json.Decode.Decoder props
        , onPropsChanged : Shared.Model -> Url -> props -> model -> ( model, Effect msg )
        , toModel : { props : props, model : model } -> Model
        , toMsg : msg -> Msg
        }
    -> ( Model, Effect Msg )
onPropsChangedForPage shared url pageObject page options =
    case Json.Decode.decodeValue options.decoder pageObject.props of
        Ok props ->
            let
                ( pageModel, pageEffect ) =
                    options.onPropsChanged shared url props page.model
            in
            ( options.toModel { props = props, model = pageModel }
            , Effect.map options.toMsg pageEffect
            )

        Err jsonDecodeError ->
            let
                info : Pages.Error500.Info
                info =
                    { pageObject = pageObject, error = jsonDecodeError }

                ( pageModel, pageEffect ) =
                    Pages.Error500.init shared url info
            in
            ( Model_Error500 { info = info, model = pageModel }
            , Effect.map Msg_Error500 pageEffect
            )


initForPage :
    Shared.Model
    -> Url
    -> PageObject Value
    ->
        { decoder : Json.Decode.Decoder props
        , init : Shared.Model -> Url -> props -> ( model, Effect msg )
        , toModel : { props : props, model : model } -> Model
        , toMsg : msg -> Msg
        }
    -> ( Model, Effect Msg )
initForPage shared url pageObject options =
    case Json.Decode.decodeValue options.decoder pageObject.props of
        Ok props ->
            let
                ( pageModel, pageEffect ) =
                    options.init shared url props
            in
            ( options.toModel { props = props, model = pageModel }
            , Effect.map options.toMsg pageEffect
            )

        Err jsonDecodeError ->
            let
                info : Pages.Error500.Info
                info =
                    { pageObject = pageObject, error = jsonDecodeError }

                ( pageModel, pageEffect ) =
                    Pages.Error500.init shared url info
            in
            ( Model_Error500 { info = info, model = pageModel }
            , Effect.map Msg_Error500 pageEffect
            )
