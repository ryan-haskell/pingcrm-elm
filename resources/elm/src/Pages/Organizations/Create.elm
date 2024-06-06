module Pages.Organizations.Create exposing
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
      , name = ""
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
    | SubmittedForm
    | CreateApiResponded (Result Http.Error Props)


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

        SubmittedForm ->
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
            , Effect.post
                { url = "/organizations"
                , body = body
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
        , title = "Create Organization"
        , user = props.auth.user
        , content =
            [ Components.Header.view
                { label = "Organizations"
                , url = "/organizations"
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
