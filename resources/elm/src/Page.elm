module Page exposing (Model, Msg, init, onPropsChanged, subscriptions, update, view)

import Browser exposing (Document)
import Effect exposing (Effect)
import Html
import Inertia exposing (PageObject)
import Json.Decode exposing (Value)
import Page.Auth.Login
import Page.Contacts.Create
import Page.Contacts.Edit
import Page.Contacts.Index
import Page.Dashboard.Index
import Page.Organizations.Create
import Page.Organizations.Edit
import Page.Organizations.Index
import Page.Reports.Index
import Page.Users.Create
import Page.Users.Edit
import Page.Users.Index
import Page.Error404
import Page.Error500
import Shared
import Url exposing (Url)


type Model
    = Model_Auth_Login { props : Page.Auth.Login.Props, model : Page.Auth.Login.Model }
    | Model_Contacts_Create { props : Page.Contacts.Create.Props, model : Page.Contacts.Create.Model }
    | Model_Contacts_Edit { props : Page.Contacts.Edit.Props, model : Page.Contacts.Edit.Model }
    | Model_Contacts_Index { props : Page.Contacts.Index.Props, model : Page.Contacts.Index.Model }
    | Model_Dashboard_Index { props : Page.Dashboard.Index.Props, model : Page.Dashboard.Index.Model }
    | Model_Organizations_Create { props : Page.Organizations.Create.Props, model : Page.Organizations.Create.Model }
    | Model_Organizations_Edit { props : Page.Organizations.Edit.Props, model : Page.Organizations.Edit.Model }
    | Model_Organizations_Index { props : Page.Organizations.Index.Props, model : Page.Organizations.Index.Model }
    | Model_Reports_Index { props : Page.Reports.Index.Props, model : Page.Reports.Index.Model }
    | Model_Users_Create { props : Page.Users.Create.Props, model : Page.Users.Create.Model }
    | Model_Users_Edit { props : Page.Users.Edit.Props, model : Page.Users.Edit.Model }
    | Model_Users_Index { props : Page.Users.Index.Props, model : Page.Users.Index.Model }
    | Model_Error404 { model : Page.Error404.Model }
    | Model_Error500 { info : Page.Error500.Info, model : Page.Error500.Model }


type Msg
    = Msg_Auth_Login Page.Auth.Login.Msg
    | Msg_Contacts_Create Page.Contacts.Create.Msg
    | Msg_Contacts_Edit Page.Contacts.Edit.Msg
    | Msg_Contacts_Index Page.Contacts.Index.Msg
    | Msg_Dashboard_Index Page.Dashboard.Index.Msg
    | Msg_Organizations_Create Page.Organizations.Create.Msg
    | Msg_Organizations_Edit Page.Organizations.Edit.Msg
    | Msg_Organizations_Index Page.Organizations.Index.Msg
    | Msg_Reports_Index Page.Reports.Index.Msg
    | Msg_Users_Create Page.Users.Create.Msg
    | Msg_Users_Edit Page.Users.Edit.Msg
    | Msg_Users_Index Page.Users.Index.Msg
    | Msg_Error404 Page.Error404.Msg
    | Msg_Error500 Page.Error500.Msg


init : Shared.Model -> Url -> PageObject Value -> ( Model, Effect Msg )
init shared url pageObject =
    case pageObject.component of
        "Auth_Login" ->
            initForPage shared url pageObject <|
                { decoder = Page.Auth.Login.decoder
                , init = Page.Auth.Login.init
                , toModel = Model_Auth_Login
                , toMsg = Msg_Auth_Login
                }

        "Contacts_Create" ->
            initForPage shared url pageObject <|
                { decoder = Page.Contacts.Create.decoder
                , init = Page.Contacts.Create.init
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        "Contacts_Edit" ->
            initForPage shared url pageObject <|
                { decoder = Page.Contacts.Edit.decoder
                , init = Page.Contacts.Edit.init
                , toModel = Model_Contacts_Edit
                , toMsg = Msg_Contacts_Edit
                }

        "Contacts_Index" ->
            initForPage shared url pageObject <|
                { decoder = Page.Contacts.Index.decoder
                , init = Page.Contacts.Index.init
                , toModel = Model_Contacts_Index
                , toMsg = Msg_Contacts_Index
                }

        "Dashboard_Index" ->
            initForPage shared url pageObject <|
                { decoder = Page.Dashboard.Index.decoder
                , init = Page.Dashboard.Index.init
                , toModel = Model_Dashboard_Index
                , toMsg = Msg_Dashboard_Index
                }

        "Organizations_Create" ->
            initForPage shared url pageObject <|
                { decoder = Page.Organizations.Create.decoder
                , init = Page.Organizations.Create.init
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        "Organizations_Edit" ->
            initForPage shared url pageObject <|
                { decoder = Page.Organizations.Edit.decoder
                , init = Page.Organizations.Edit.init
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        "Organizations_Index" ->
            initForPage shared url pageObject <|
                { decoder = Page.Organizations.Index.decoder
                , init = Page.Organizations.Index.init
                , toModel = Model_Organizations_Index
                , toMsg = Msg_Organizations_Index
                }

        "Reports_Index" ->
            initForPage shared url pageObject <|
                { decoder = Page.Reports.Index.decoder
                , init = Page.Reports.Index.init
                , toModel = Model_Reports_Index
                , toMsg = Msg_Reports_Index
                }

        "Users_Create" ->
            initForPage shared url pageObject <|
                { decoder = Page.Users.Create.decoder
                , init = Page.Users.Create.init
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        "Users_Edit" ->
            initForPage shared url pageObject <|
                { decoder = Page.Users.Edit.decoder
                , init = Page.Users.Edit.init
                , toModel = Model_Users_Edit
                , toMsg = Msg_Users_Edit
                }

        "Users_Index" ->
            initForPage shared url pageObject <|
                { decoder = Page.Users.Index.decoder
                , init = Page.Users.Index.init
                , toModel = Model_Users_Index
                , toMsg = Msg_Users_Index
                }

        _ ->
            let
                ( pageModel, pageEffect ) =
                    Page.Error404.init shared url
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
                    Page.Auth.Login.update shared url page.props pageMsg page.model
            in
            ( Model_Auth_Login { page | model = pageModel }
            , Effect.map Msg_Auth_Login pageEffect
            )

        ( Msg_Contacts_Create pageMsg, Model_Contacts_Create page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Contacts.Create.update shared url page.props pageMsg page.model
            in
            ( Model_Contacts_Create { page | model = pageModel }
            , Effect.map Msg_Contacts_Create pageEffect
            )

        ( Msg_Contacts_Edit pageMsg, Model_Contacts_Edit page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Contacts.Edit.update shared url page.props pageMsg page.model
            in
            ( Model_Contacts_Edit { page | model = pageModel }
            , Effect.map Msg_Contacts_Edit pageEffect
            )

        ( Msg_Contacts_Index pageMsg, Model_Contacts_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Contacts.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Contacts_Index { page | model = pageModel }
            , Effect.map Msg_Contacts_Index pageEffect
            )

        ( Msg_Dashboard_Index pageMsg, Model_Dashboard_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Dashboard.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Dashboard_Index { page | model = pageModel }
            , Effect.map Msg_Dashboard_Index pageEffect
            )

        ( Msg_Organizations_Create pageMsg, Model_Organizations_Create page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Organizations.Create.update shared url page.props pageMsg page.model
            in
            ( Model_Organizations_Create { page | model = pageModel }
            , Effect.map Msg_Organizations_Create pageEffect
            )

        ( Msg_Organizations_Edit pageMsg, Model_Organizations_Edit page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Organizations.Edit.update shared url page.props pageMsg page.model
            in
            ( Model_Organizations_Edit { page | model = pageModel }
            , Effect.map Msg_Organizations_Edit pageEffect
            )

        ( Msg_Organizations_Index pageMsg, Model_Organizations_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Organizations.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Organizations_Index { page | model = pageModel }
            , Effect.map Msg_Organizations_Index pageEffect
            )

        ( Msg_Reports_Index pageMsg, Model_Reports_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Reports.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Reports_Index { page | model = pageModel }
            , Effect.map Msg_Reports_Index pageEffect
            )

        ( Msg_Users_Create pageMsg, Model_Users_Create page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Users.Create.update shared url page.props pageMsg page.model
            in
            ( Model_Users_Create { page | model = pageModel }
            , Effect.map Msg_Users_Create pageEffect
            )

        ( Msg_Users_Edit pageMsg, Model_Users_Edit page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Users.Edit.update shared url page.props pageMsg page.model
            in
            ( Model_Users_Edit { page | model = pageModel }
            , Effect.map Msg_Users_Edit pageEffect
            )

        ( Msg_Users_Index pageMsg, Model_Users_Index page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Users.Index.update shared url page.props pageMsg page.model
            in
            ( Model_Users_Index { page | model = pageModel }
            , Effect.map Msg_Users_Index pageEffect
            )

        ( Msg_Error404 pageMsg, Model_Error404 page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Error404.update shared url pageMsg page.model
            in
            ( Model_Error404 { page | model = pageModel }
            , Effect.map Msg_Error404 pageEffect
            )

        ( Msg_Error500 pageMsg, Model_Error500 page ) ->
            let
                ( pageModel, pageEffect ) =
                    Page.Error500.update shared url page.info pageMsg page.model
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
            Page.Auth.Login.subscriptions shared url page.props page.model
                |> Sub.map Msg_Auth_Login

        Model_Contacts_Create page ->
            Page.Contacts.Create.subscriptions shared url page.props page.model
                |> Sub.map Msg_Contacts_Create

        Model_Contacts_Edit page ->
            Page.Contacts.Edit.subscriptions shared url page.props page.model
                |> Sub.map Msg_Contacts_Edit

        Model_Contacts_Index page ->
            Page.Contacts.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Contacts_Index

        Model_Dashboard_Index page ->
            Page.Dashboard.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Dashboard_Index

        Model_Organizations_Create page ->
            Page.Organizations.Create.subscriptions shared url page.props page.model
                |> Sub.map Msg_Organizations_Create

        Model_Organizations_Edit page ->
            Page.Organizations.Edit.subscriptions shared url page.props page.model
                |> Sub.map Msg_Organizations_Edit

        Model_Organizations_Index page ->
            Page.Organizations.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Organizations_Index

        Model_Reports_Index page ->
            Page.Reports.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Reports_Index

        Model_Users_Create page ->
            Page.Users.Create.subscriptions shared url page.props page.model
                |> Sub.map Msg_Users_Create

        Model_Users_Edit page ->
            Page.Users.Edit.subscriptions shared url page.props page.model
                |> Sub.map Msg_Users_Edit

        Model_Users_Index page ->
            Page.Users.Index.subscriptions shared url page.props page.model
                |> Sub.map Msg_Users_Index

        Model_Error404 page ->
            Page.Error404.subscriptions shared url page.model
                |> Sub.map Msg_Error404

        Model_Error500 page ->
            Page.Error500.subscriptions shared url page.info page.model
                |> Sub.map Msg_Error500


view : Shared.Model -> Url -> PageObject Value -> Model -> Document Msg
view shared url pageObject model =
    case model of
        Model_Auth_Login page ->
            Page.Auth.Login.view shared url page.props page.model
                |> mapDocument Msg_Auth_Login

        Model_Contacts_Create page ->
            Page.Contacts.Create.view shared url page.props page.model
                |> mapDocument Msg_Contacts_Create

        Model_Contacts_Edit page ->
            Page.Contacts.Edit.view shared url page.props page.model
                |> mapDocument Msg_Contacts_Edit

        Model_Contacts_Index page ->
            Page.Contacts.Index.view shared url page.props page.model
                |> mapDocument Msg_Contacts_Index

        Model_Dashboard_Index page ->
            Page.Dashboard.Index.view shared url page.props page.model
                |> mapDocument Msg_Dashboard_Index

        Model_Organizations_Create page ->
            Page.Organizations.Create.view shared url page.props page.model
                |> mapDocument Msg_Organizations_Create

        Model_Organizations_Edit page ->
            Page.Organizations.Edit.view shared url page.props page.model
                |> mapDocument Msg_Organizations_Edit

        Model_Organizations_Index page ->
            Page.Organizations.Index.view shared url page.props page.model
                |> mapDocument Msg_Organizations_Index

        Model_Reports_Index page ->
            Page.Reports.Index.view shared url page.props page.model
                |> mapDocument Msg_Reports_Index

        Model_Users_Create page ->
            Page.Users.Create.view shared url page.props page.model
                |> mapDocument Msg_Users_Create

        Model_Users_Edit page ->
            Page.Users.Edit.view shared url page.props page.model
                |> mapDocument Msg_Users_Edit

        Model_Users_Index page ->
            Page.Users.Index.view shared url page.props page.model
                |> mapDocument Msg_Users_Index

        Model_Error404 page ->
            Page.Error404.view shared url page.model
                |> mapDocument Msg_Error404

        Model_Error500 page ->
            Page.Error500.view shared url page.info page.model
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
                { decoder = Page.Auth.Login.decoder
                , onPropsChanged = Page.Auth.Login.onPropsChanged
                , toModel = Model_Auth_Login
                , toMsg = Msg_Auth_Login
                }

        Model_Contacts_Create page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Contacts.Create.decoder
                , onPropsChanged = Page.Contacts.Create.onPropsChanged
                , toModel = Model_Contacts_Create
                , toMsg = Msg_Contacts_Create
                }

        Model_Contacts_Edit page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Contacts.Edit.decoder
                , onPropsChanged = Page.Contacts.Edit.onPropsChanged
                , toModel = Model_Contacts_Edit
                , toMsg = Msg_Contacts_Edit
                }

        Model_Contacts_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Contacts.Index.decoder
                , onPropsChanged = Page.Contacts.Index.onPropsChanged
                , toModel = Model_Contacts_Index
                , toMsg = Msg_Contacts_Index
                }

        Model_Dashboard_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Dashboard.Index.decoder
                , onPropsChanged = Page.Dashboard.Index.onPropsChanged
                , toModel = Model_Dashboard_Index
                , toMsg = Msg_Dashboard_Index
                }

        Model_Organizations_Create page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Organizations.Create.decoder
                , onPropsChanged = Page.Organizations.Create.onPropsChanged
                , toModel = Model_Organizations_Create
                , toMsg = Msg_Organizations_Create
                }

        Model_Organizations_Edit page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Organizations.Edit.decoder
                , onPropsChanged = Page.Organizations.Edit.onPropsChanged
                , toModel = Model_Organizations_Edit
                , toMsg = Msg_Organizations_Edit
                }

        Model_Organizations_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Organizations.Index.decoder
                , onPropsChanged = Page.Organizations.Index.onPropsChanged
                , toModel = Model_Organizations_Index
                , toMsg = Msg_Organizations_Index
                }

        Model_Reports_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Reports.Index.decoder
                , onPropsChanged = Page.Reports.Index.onPropsChanged
                , toModel = Model_Reports_Index
                , toMsg = Msg_Reports_Index
                }

        Model_Users_Create page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Users.Create.decoder
                , onPropsChanged = Page.Users.Create.onPropsChanged
                , toModel = Model_Users_Create
                , toMsg = Msg_Users_Create
                }

        Model_Users_Edit page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Users.Edit.decoder
                , onPropsChanged = Page.Users.Edit.onPropsChanged
                , toModel = Model_Users_Edit
                , toMsg = Msg_Users_Edit
                }

        Model_Users_Index page ->
            onPropsChangedForPage shared url pageObject page <|
                { decoder = Page.Users.Index.decoder
                , onPropsChanged = Page.Users.Index.onPropsChanged
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
                info : Page.Error500.Info
                info =
                    { pageObject = pageObject, error = jsonDecodeError }

                ( pageModel, pageEffect ) =
                    Page.Error500.init shared url info
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
                info : Page.Error500.Info
                info =
                    { pageObject = pageObject, error = jsonDecodeError }

                ( pageModel, pageEffect ) =
                    Page.Error500.init shared url info
            in
            ( Model_Error500 { info = info, model = pageModel }
            , Effect.map Msg_Error500 pageEffect
            )
