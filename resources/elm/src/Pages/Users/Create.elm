module Pages.Users.Create exposing
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
import Components.CreateHeader
import Components.Form
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Http
import Extra.Json.Encode as E
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Layouts.Sidebar
import Shared.Auth exposing (Auth)
import Shared.CommonProps exposing (CommonProps)
import Shared.Flash exposing (Flash)



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , errors : Errors
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map3 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)


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



-- MODEL


type alias Model =
    { props : Props
    , sidebar : Layouts.Sidebar.Model
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


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { props = props
      , sidebar = Layouts.Sidebar.init
      , isSubmittingForm = False
      , firstName = ""
      , lastName = ""
      , email = ""
      , password = ""
      , owner = "no"
      , errors = props.errors
      }
    , Effect.none
    )


onPropsChanged : Context -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged ctx props model =
    ( { model | props = props, errors = props.errors }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | ChangedInput Field String
    | SubmittedForm
    | CreateApiResponded (Result Http.Error (CommonProps Errors))


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg ({ errors } as model) =
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

        SubmittedForm ->
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
            , Effect.post
                { url = "/users"
                , body = body
                , decoder = Shared.CommonProps.decoder errorsDecoder
                , onResponse = CreateApiResponded
                }
            )

        CreateApiResponded (Ok props) ->
            ( { model
                | props =
                    if hasAnError props.errors then
                        props |> showFormError "Could not create a new organization."

                    else
                        props
                , errors = props.errors
                , isSubmittingForm = False
              }
            , Effect.none
            )

        CreateApiResponded (Err httpError) ->
            ( { model
                | props = model.props |> showFormError (Extra.Http.toUserFriendlyMessage httpError)
                , isSubmittingForm = False
              }
            , Effect.none
            )


showFormError : String -> Props -> Props
showFormError reason props =
    { props | flash = { success = Nothing, error = Just reason } }



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Sub Msg
subscriptions ctx model =
    Sub.batch
        [ Layouts.Sidebar.subscriptions { model = model.sidebar, toMsg = Sidebar }
        ]



-- VIEW


view : Context -> Model -> Document Msg
view ctx model =
    Layouts.Sidebar.view
        { model = model.sidebar
        , flash = model.props.flash
        , toMsg = Sidebar
        , context = ctx
        , title = "Create User"
        , user = model.props.auth.user
        , content =
            [ Components.CreateHeader.view
                { label = "Users"
                , url = "/users"
                }
            , viewCreateForm model
            ]
        , overlays = []
        }



-- CREATE FORM


viewCreateForm : Model -> Html Msg
viewCreateForm model =
    Components.Form.create
        { onSubmit = SubmittedForm
        , button = "Create User"
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
