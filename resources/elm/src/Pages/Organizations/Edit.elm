module Pages.Organizations.Edit exposing
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
import Context exposing (Context)
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
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)
import Url.Builder



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , errors : Errors
    , organization : Organization
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map4 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)
        (Json.Decode.field "organization" organizationDecoder)


type alias Errors =
    { name : Maybe String
    , email : Maybe String
    }


errorsDecoder : Json.Decode.Decoder Errors
errorsDecoder =
    Json.Decode.map2 Errors
        (Json.Decode.maybe (Json.Decode.field "name" Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "email" Json.Decode.string))


hasAnError : Errors -> Bool
hasAnError errors =
    List.any ((/=) Nothing)
        [ errors.name
        , errors.email
        ]


type alias Organization =
    { id : Int
    , name : String
    , address : Maybe String
    , city : Maybe String
    , country : Maybe String
    , email : Maybe String
    , phone : Maybe String
    , postalCode : Maybe String
    , region : Maybe String
    , deletedAt : Maybe String
    }


organizationDecoder : Json.Decode.Decoder Organization
organizationDecoder =
    Extra.Json.Decode.object Organization
        |> Extra.Json.Decode.required "id" Json.Decode.int
        |> Extra.Json.Decode.required "name" Json.Decode.string
        |> Extra.Json.Decode.optional "address" Json.Decode.string
        |> Extra.Json.Decode.optional "city" Json.Decode.string
        |> Extra.Json.Decode.optional "country" Json.Decode.string
        |> Extra.Json.Decode.optional "email" Json.Decode.string
        |> Extra.Json.Decode.optional "phone" Json.Decode.string
        |> Extra.Json.Decode.optional "postal_code" Json.Decode.string
        |> Extra.Json.Decode.optional "region" Json.Decode.string
        |> Extra.Json.Decode.optional "deleted_at" Json.Decode.string



-- MODEL


type alias Model =
    { sidebar : Layouts.Sidebar.Model
    , isSubmittingForm : Bool
    , name : String
    , email : String
    , phone : String
    , address : String
    , city : String
    , region : String
    , country : String
    , postalCode : String
    , errors : Errors
    }


type Field
    = Name
    | Email
    | Phone
    | Address
    | City
    | Region
    | Country
    | PostalCode


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { sidebar = Layouts.Sidebar.init { flash = props.flash }
      , isSubmittingForm = False
      , name = props.organization.name
      , email = props.organization.email |> Maybe.withDefault ""
      , phone = props.organization.phone |> Maybe.withDefault ""
      , address = props.organization.address |> Maybe.withDefault ""
      , city = props.organization.city |> Maybe.withDefault ""
      , region = props.organization.region |> Maybe.withDefault ""
      , country = props.organization.country |> Maybe.withDefault ""
      , postalCode = props.organization.postalCode |> Maybe.withDefault ""
      , errors = props.errors
      }
    , Effect.none
    )


onPropsChanged : Context -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged ctx props model =
    let
        _ =
            Debug.log "onPropsChanged - org edit" props
    in
    ( { model
        | errors = props.errors
        , sidebar = Layouts.Sidebar.withFlash props.flash model.sidebar
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | ChangedInput Field String
    | SubmittedUpdateForm
    | ClickedDelete
    | EditApiResponded (Result Http.Error Props)


update : Context -> Props -> Msg -> Model -> ( Model, Effect Msg )
update ctx props msg ({ errors } as model) =
    case msg of
        Sidebar sidebarMsg ->
            Layouts.Sidebar.update
                { msg = sidebarMsg
                , model = model.sidebar
                , toModel = \sidebar -> { model | sidebar = sidebar }
                , toMsg = Sidebar
                }

        ChangedInput Name value ->
            ( { model
                | name = value
                , errors = { errors | name = Nothing }
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

        ChangedInput Phone value ->
            ( { model | phone = value }, Effect.none )

        ChangedInput Address value ->
            ( { model | address = value }, Effect.none )

        ChangedInput City value ->
            ( { model | city = value }, Effect.none )

        ChangedInput Region value ->
            ( { model | region = value }, Effect.none )

        ChangedInput Country value ->
            ( { model | country = value }, Effect.none )

        ChangedInput PostalCode value ->
            ( { model | postalCode = value }, Effect.none )

        SubmittedUpdateForm ->
            let
                body : Json.Encode.Value
                body =
                    Json.Encode.object
                        [ ( "name", E.toStringOrNull model.name )
                        , ( "email", E.toStringOrNull model.email )
                        , ( "phone", E.toStringOrNull model.phone )
                        , ( "address", E.toStringOrNull model.address )
                        , ( "city", E.toStringOrNull model.city )
                        , ( "region", E.toStringOrNull model.region )
                        , ( "country", E.toStringOrNull model.country )
                        , ( "postal_code", E.toStringOrNull model.postalCode )
                        ]
            in
            ( { model | isSubmittingForm = True }
            , Effect.put
                { url =
                    Url.Builder.absolute
                        [ "organizations"
                        , String.fromInt props.organization.id
                        ]
                        []
                , body = body
                , decoder = decoder
                , onResponse = EditApiResponded
                }
            )

        ClickedDelete ->
            ( model
            , Effect.delete
                { url =
                    Url.Builder.absolute
                        [ "organizations"
                        , String.fromInt props.organization.id
                        ]
                        []
                , decoder = decoder
                , onResponse = EditApiResponded
                }
            )

        EditApiResponded (Ok res) ->
            ( { model | isSubmittingForm = False }
            , Effect.none
            )

        EditApiResponded (Err httpError) ->
            ( { model
                | sidebar = Layouts.Sidebar.withFlashError (Extra.Http.toUserFriendlyMessage httpError) model.sidebar
                , isSubmittingForm = False
              }
            , Effect.none
            )


showFormError : String -> Props -> Props
showFormError reason props =
    { props | flash = { success = Nothing, error = Just reason } }



-- SUBSCRIPTIONS


subscriptions : Context -> Props -> Model -> Sub Msg
subscriptions ctx props model =
    Sub.batch
        [ Layouts.Sidebar.subscriptions { model = model.sidebar, toMsg = Sidebar }
        ]



-- VIEW


view : Context -> Props -> Model -> Document Msg
view ctx props model =
    Layouts.Sidebar.view
        { model = model.sidebar
        , toMsg = Sidebar
        , context = ctx
        , title = props.organization.name
        , user = props.auth.user
        , content =
            [ Components.Header.view
                { label = "Organizations"
                , url = "/organizations"
                , content = "Edit"
                }
            , viewEditForm model
            ]
        , overlays = []
        }



-- CREATE FORM


viewEditForm : Model -> Html Msg
viewEditForm model =
    Components.Form.edit
        { onUpdate = SubmittedUpdateForm
        , onDelete = ClickedDelete
        , noun = "Organization"
        , isSubmittingForm = model.isSubmittingForm
        , inputs =
            [ Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "name"
                , label = "Name"
                , value = model.name
                , error = model.errors.name
                , onInput = ChangedInput Name
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "email"
                , label = "Email"
                , value = model.email
                , error = model.errors.email
                , onInput = ChangedInput Email
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "phone"
                , label = "Phone"
                , value = model.phone
                , error = Nothing
                , onInput = ChangedInput Phone
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "address"
                , label = "Address"
                , value = model.address
                , error = Nothing
                , onInput = ChangedInput Address
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "city"
                , label = "City"
                , value = model.city
                , error = Nothing
                , onInput = ChangedInput City
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "region"
                , label = "Province/State"
                , value = model.region
                , error = Nothing
                , onInput = ChangedInput Region
                }
            , Components.Form.select
                { isDisabled = model.isSubmittingForm
                , id = "country"
                , label = "Country"
                , value = model.country
                , error = Nothing
                , onInput = ChangedInput Country
                , options =
                    [ ( "CA", "Canada" )
                    , ( "US", "United States" )
                    ]
                }
            , Components.Form.text
                { isDisabled = model.isSubmittingForm
                , id = "postalCode"
                , label = "Postal code"
                , value = model.postalCode
                , error = Nothing
                , onInput = ChangedInput PostalCode
                }
            ]
        }
