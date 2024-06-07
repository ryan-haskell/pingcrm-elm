module Pages.Contacts.Edit exposing
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
    , organizations : List Organization
    , contact : Contact
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map5 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)
        (Json.Decode.field "organizations" (Json.Decode.list organizationDecoder))
        (Json.Decode.field "contact" contactDecoder)


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


type alias Organization =
    { id : Int
    , name : String
    }


organizationDecoder : Json.Decode.Decoder Organization
organizationDecoder =
    Json.Decode.map2 Organization
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)


type alias Contact =
    { id : Int
    , firstName : String
    , lastName : String
    , organizationId : Maybe Int
    , email : Maybe String
    , phone : Maybe String
    , address : Maybe String
    , city : Maybe String
    , region : Maybe String
    , country : Maybe String
    , postalCode : Maybe String
    , deletedAt : Maybe String
    }


contactDecoder : Json.Decode.Decoder Contact
contactDecoder =
    Extra.Json.Decode.object Contact
        |> Extra.Json.Decode.required "id" Json.Decode.int
        |> Extra.Json.Decode.required "first_name" Json.Decode.string
        |> Extra.Json.Decode.required "last_name" Json.Decode.string
        |> Extra.Json.Decode.optional "organization_id" Json.Decode.int
        |> Extra.Json.Decode.optional "email" Json.Decode.string
        |> Extra.Json.Decode.optional "phone" Json.Decode.string
        |> Extra.Json.Decode.optional "address" Json.Decode.string
        |> Extra.Json.Decode.optional "city" Json.Decode.string
        |> Extra.Json.Decode.optional "region" Json.Decode.string
        |> Extra.Json.Decode.optional "country" Json.Decode.string
        |> Extra.Json.Decode.optional "postal_code" Json.Decode.string
        |> Extra.Json.Decode.optional "deleted_at" Json.Decode.string



-- MODEL


type alias Model =
    { sidebar : Layouts.Sidebar.Model
    , isSubmittingForm : Bool
    , firstName : String
    , lastName : String
    , organizationId : String
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
    = FirstName
    | LastName
    | OrganizationId
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
      , firstName = props.contact.firstName
      , lastName = props.contact.lastName
      , organizationId =
            props.contact.organizationId
                |> Maybe.map String.fromInt
                |> Maybe.withDefault ""
      , email = props.contact.email |> Maybe.withDefault ""
      , phone = props.contact.phone |> Maybe.withDefault ""
      , address = props.contact.address |> Maybe.withDefault ""
      , city = props.contact.city |> Maybe.withDefault ""
      , region = props.contact.region |> Maybe.withDefault ""
      , country = props.contact.country |> Maybe.withDefault ""
      , postalCode = props.contact.postalCode |> Maybe.withDefault ""
      , errors = props.errors
      }
    , Effect.none
    )


onPropsChanged : Context -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged ctx props model =
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

        ChangedInput OrganizationId value ->
            ( { model | organizationId = value }, Effect.none )

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

        ClickedUpdate ->
            let
                body : Json.Encode.Value
                body =
                    Json.Encode.object
                        [ ( "first_name", E.toStringOrNull model.firstName )
                        , ( "last_name", E.toStringOrNull model.lastName )
                        , ( "organization_id", E.toIntOrNull model.organizationId )
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
                        [ "contacts"
                        , String.fromInt props.contact.id
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
                { url = Url.Builder.absolute [ "contacts", String.fromInt props.contact.id ] []
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
                { url = Url.Builder.absolute [ "contacts", String.fromInt props.contact.id, "restore" ] []
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
        , title = toFullName props.contact
        , user = props.auth.user
        , content =
            [ Components.Header.view
                { label = "Contacts"
                , url = "/contacts"
                , content = toFullName props.contact
                }
            , Components.RestoreBanner.view
                { deletedAt = props.contact.deletedAt
                , noun = "contact"
                , onClick = ClickedRestore
                }
            , viewEditForm props model
            ]
        , overlays = []
        }


toFullName : Contact -> String
toFullName contact =
    String.join " "
        [ contact.firstName
        , contact.lastName
        ]



-- EDIT FORM


viewEditForm : Props -> Model -> Html Msg
viewEditForm props model =
    Components.Form.edit
        { onUpdate = ClickedUpdate
        , isDeleted = props.contact.deletedAt /= Nothing
        , onDelete = ClickedDelete
        , noun = "Contact"
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
            , Components.Form.select
                { isDisabled = model.isSubmittingForm
                , id = "organization"
                , label = "Organization"
                , value = model.organizationId
                , error = Nothing
                , onInput = ChangedInput OrganizationId
                , options =
                    ( "", "" )
                        :: List.map
                            (\org -> ( String.fromInt org.id, org.name ))
                            props.organizations
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
                    [ ( "", "" )
                    , ( "CA", "Canada" )
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
