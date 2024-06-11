module Pages.Users.Edit exposing
    ( Props, decoder
    , Model, init, onPropsChanged
    , Msg, update, subscriptions
    , view
    )

{-|

@docs Props, decoder
@docs Model, init, onPropsChanged
@docs Msg, update, subscriptions
@docs view

-}

import Browser exposing (Document)
import Components.Form
import Components.Header
import Components.RestoreBanner
import Effect exposing (Effect)
import Extra.Http
import Extra.Json.Decode
import Extra.Json.Encode as E
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Layouts.Sidebar
import Shared
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)
import Url exposing (Url)
import Url.Builder



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , errors : Errors
    , user : User
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map4 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)
        (Json.Decode.field "user" userDecoder)


type alias Errors =
    { firstName : Maybe String
    , lastName : Maybe String
    , email : Maybe String
    }


errorsDecoder : Json.Decode.Decoder Errors
errorsDecoder =
    Json.Decode.map3 Errors
        (Json.Decode.maybe (Json.Decode.field "first_name" Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "last_name" Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "email" Json.Decode.string))


hasAnError : Errors -> Bool
hasAnError errors =
    List.any ((/=) Nothing)
        [ errors.firstName
        , errors.lastName
        , errors.email
        ]


type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    , email : String
    , owner : Bool
    , deletedAt : Maybe String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Extra.Json.Decode.object User
        |> Extra.Json.Decode.required "id" Json.Decode.int
        |> Extra.Json.Decode.required "first_name" Json.Decode.string
        |> Extra.Json.Decode.required "last_name" Json.Decode.string
        |> Extra.Json.Decode.required "email" Json.Decode.string
        |> Extra.Json.Decode.required "owner" Json.Decode.bool
        |> Extra.Json.Decode.optional "deleted_at" Json.Decode.string



-- MODEL


type alias Model =
    { sidebar : Layouts.Sidebar.Model
    , isSubmittingForm : Bool
    , firstName : String
    , lastName : String
    , email : String
    , password : String
    , owner : String
    , errors : Errors
    }


type Field
    = FirstName
    | LastName
    | Email
    | Password
    | Owner


init : Shared.Model -> Url -> Props -> ( Model, Effect Msg )
init shared url props =
    ( { sidebar = Layouts.Sidebar.init { flash = props.flash }
      , isSubmittingForm = False
      , firstName = props.user.firstName
      , lastName = props.user.lastName
      , email = props.user.email
      , password = ""
      , owner =
            if props.user.owner then
                "yes"

            else
                "no"
      , errors = props.errors
      }
    , Effect.none
    )


onPropsChanged : Shared.Model -> Url -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged shared url props model =
    ( { model
        | sidebar = Layouts.Sidebar.withFlash props.flash model.sidebar
        , errors = props.errors
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | ChangedInput Field String
    | ClickedUpdate
    | UpdateResponded (Result Http.Error ())
    | ClickedDelete
    | DeleteResponded (Result Http.Error ())
    | ClickedRestore
    | RestoreResponded (Result Http.Error ())


update : Shared.Model -> Url -> Props -> Msg -> Model -> ( Model, Effect Msg )
update shared url props msg ({ errors } as model) =
    case msg of
        Sidebar sidebarMsg ->
            Layouts.Sidebar.update
                { msg = sidebarMsg
                , model = model.sidebar
                , toModel = \sidebar -> { model | sidebar = sidebar }
                , toMsg = Sidebar
                }

        ChangedInput FirstName value ->
            ( { model
                | firstName = value
                , errors = { errors | firstName = Nothing }
              }
            , Effect.none
            )

        ChangedInput LastName value ->
            ( { model
                | lastName = value
                , errors = { errors | lastName = Nothing }
              }
            , Effect.none
            )

        ChangedInput Email value ->
            ( { model
                | email = value
                , errors = { errors | email = Nothing }
              }
            , Effect.none
            )

        ChangedInput Password value ->
            ( { model | password = value }, Effect.none )

        ChangedInput Owner value ->
            ( { model | owner = value }, Effect.none )

        ClickedUpdate ->
            let
                body : Json.Encode.Value
                body =
                    Json.Encode.object
                        [ ( "first_name", E.toStringOrNull model.firstName )
                        , ( "last_name", E.toStringOrNull model.lastName )
                        , ( "email", E.toStringOrNull model.email )
                        , ( "password", E.toStringOrNull model.password )
                        , ( "owner", E.toYesOrNoBool model.owner )

                        -- TODO: Photo
                        , ( "photo", Json.Encode.null )
                        ]
            in
            ( { model | isSubmittingForm = True }
            , Effect.put
                { url =
                    Url.Builder.absolute
                        [ "users"
                        , String.fromInt props.user.id
                        ]
                        []
                , body = Http.jsonBody body
                , decoder = Json.Decode.succeed ()
                , onResponse = UpdateResponded
                }
            )

        UpdateResponded (Ok ()) ->
            ( { model | isSubmittingForm = False }
            , Effect.none
            )

        UpdateResponded (Err httpError) ->
            ( { model
                | sidebar = Layouts.Sidebar.withFlashHttpError httpError model.sidebar
                , isSubmittingForm = False
              }
            , Effect.none
            )

        ClickedDelete ->
            ( model
            , Effect.delete
                { url = Url.Builder.absolute [ "users", String.fromInt props.user.id ] []
                , decoder = Json.Decode.succeed ()
                , onResponse = DeleteResponded
                }
            )

        DeleteResponded (Ok ()) ->
            ( model
            , Effect.none
            )

        DeleteResponded (Err httpError) ->
            ( { model | sidebar = Layouts.Sidebar.withFlashHttpError httpError model.sidebar }
            , Effect.none
            )

        ClickedRestore ->
            ( model
            , Effect.put
                { url = Url.Builder.absolute [ "users", String.fromInt props.user.id, "restore" ] []
                , body = Http.emptyBody
                , decoder = Json.Decode.succeed ()
                , onResponse = RestoreResponded
                }
            )

        RestoreResponded (Ok ()) ->
            ( model
            , Effect.none
            )

        RestoreResponded (Err httpError) ->
            ( { model | sidebar = Layouts.Sidebar.withFlashHttpError httpError model.sidebar }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Shared.Model -> Url -> Props -> Model -> Sub Msg
subscriptions shared url props model =
    Sub.batch
        [ Layouts.Sidebar.subscriptions { model = model.sidebar, toMsg = Sidebar }
        ]



-- VIEW


view : Shared.Model -> Url -> Props -> Model -> Document Msg
view shared url props model =
    Layouts.Sidebar.view
        { model = model.sidebar
        , toMsg = Sidebar
        , shared = shared
        , url = url
        , title = toFullName props.user
        , user = props.auth.user
        , content =
            [ Components.Header.view
                { label = "Users"
                , url = "/users"
                , content = toFullName props.user
                }
            , Components.RestoreBanner.view
                { deletedAt = props.user.deletedAt
                , noun = "user"
                , onClick = ClickedRestore
                }
            , viewEditForm props model
            ]
        , overlays = []
        }


toFullName : User -> String
toFullName user =
    String.join " "
        [ user.firstName
        , user.lastName
        ]



-- EDIT FORM


viewEditForm : Props -> Model -> Html Msg
viewEditForm props model =
    Components.Form.edit
        { onUpdate = ClickedUpdate
        , isDeleted = props.user.deletedAt /= Nothing
        , onDelete = ClickedDelete
        , noun = "User"
        , isSubmittingForm = model.isSubmittingForm
        , inputs =
            [ Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "first_name"
                , label = "First name"
                , value = model.firstName
                , error = model.errors.firstName
                , onInput = ChangedInput FirstName
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "last_name"
                , label = "Last name"
                , value = model.lastName
                , error = model.errors.lastName
                , onInput = ChangedInput LastName
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "email"
                , label = "Email"
                , value = model.email
                , error = model.errors.email
                , onInput = ChangedInput Email
                }
            , Components.Form.password
                { isDisabled = model.isSubmittingForm
                , id = "password"
                , label = "Password"
                , value = model.password
                , error = Nothing
                , onInput = ChangedInput Password
                }
            , Components.Form.select
                { isDisabled = model.isSubmittingForm
                , id = "owner"
                , label = "Owner"
                , value = model.owner
                , error = Nothing
                , onInput = ChangedInput Owner
                , options =
                    [ ( "yes", "Yes" )
                    , ( "no", "No" )
                    ]
                }
            ]
        }
