module Pages.Contacts.Create exposing
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
import Shared
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)
import Url exposing (Url)



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , errors : Errors
    , organizations : List Organization
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map4 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)
        (Json.Decode.field "organizations" (Json.Decode.list organizationDecoder))


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


init : Shared.Model -> Url -> Props -> ( Model, Effect Msg )
init shared url props =
    ( { sidebar = Layouts.Sidebar.init { flash = props.flash }
      , isSubmittingForm = False
      , firstName = ""
      , lastName = ""
      , organizationId = ""
      , email = ""
      , phone = ""
      , address = ""
      , city = ""
      , region = ""
      , country = ""
      , postalCode = ""
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
    | SubmittedForm
    | CreateApiResponded (Result Http.Error Props)


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

        SubmittedForm ->
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
            , Effect.post
                { url = "/contacts"
                , body = Http.jsonBody body
                , decoder = decoder
                , onResponse = CreateApiResponded
                }
            )

        CreateApiResponded (Ok res) ->
            ( { model | isSubmittingForm = False }
            , Effect.none
            )

        CreateApiResponded (Err httpError) ->
            ( { model
                | sidebar = Layouts.Sidebar.withFlashHttpError httpError model.sidebar
                , isSubmittingForm = False
              }
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
        , title = "Create Contact"
        , user = props.auth.user
        , content =
            [ Components.Header.view
                { label = "Contacts"
                , url = "/contacts"
                , content = "Create"
                }
            , viewCreateForm props model
            ]
        , overlays = []
        }



-- CREATE FORM


viewCreateForm : Props -> Model -> Html Msg
viewCreateForm props model =
    Components.Form.create
        { onSubmit = SubmittedForm
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
