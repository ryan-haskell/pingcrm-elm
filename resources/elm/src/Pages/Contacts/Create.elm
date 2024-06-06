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
    { props : Props
    , sidebar : Layouts.Sidebar.Model
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
    ( { props = props
      , sidebar = Layouts.Sidebar.init
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
update ctx msg ({ errors, props } as model) =
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
                , body = body
                , decoder = Shared.CommonProps.decoder errorsDecoder
                , onResponse = CreateApiResponded
                }
            )

        CreateApiResponded (Ok common) ->
            let
                newProps : Props
                newProps =
                    { props | flash = common.flash, errors = common.errors }
            in
            ( { model
                | props =
                    if hasAnError newProps.errors then
                        newProps |> showFormError "Could not create a new contact."

                    else
                        newProps
                , errors = common.errors
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
        , title = "Create Contact"
        , user = model.props.auth.user
        , content =
            [ Components.CreateHeader.view
                { label = "Contacts"
                , url = "/contacts"
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
        , button = "Create Contact"
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
                            model.props.organizations
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
