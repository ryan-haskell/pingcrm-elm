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

import Components.CreateHeader
import Browser exposing (Document)
import Components.Form
import Context exposing (Context)
import Domain.Auth exposing (Auth)
import Domain.Flash exposing (Flash)
import Effect exposing (Effect)
import Extra.Http
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Layouts.Sidebar



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , errors : Errors
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map3 Props
        (Json.Decode.field "auth" Domain.Auth.decoder)
        (Json.Decode.field "flash" Domain.Flash.decoder)
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
    { props : Props
    , sidebar : Layouts.Sidebar.Model
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
    ( { props = props
      , sidebar = Layouts.Sidebar.init
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
    ( { model | props = props, errors = props.errors }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | ChangedInput Field String
    | SubmittedForm
    | CreateApiResponded (Result Http.Error Props)


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
                        [ ( "name", toStringOrNull model.name )
                        , ( "email", toStringOrNull model.email )
                        , ( "phone", toStringOrNull model.phone )
                        , ( "address", toStringOrNull model.address )
                        , ( "city", toStringOrNull model.city )
                        , ( "region", toStringOrNull model.region )
                        , ( "country", toStringOrNull model.country )
                        , ( "postal_code", toStringOrNull model.postalCode )
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


toStringOrNull : String -> Json.Encode.Value
toStringOrNull str =
    if String.isEmpty (String.trim str) then
        Json.Encode.null

    else
        Json.Encode.string str



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
        , title = "Create Organization"
        , user = model.props.auth.user
        , content =
            [ Components.CreateHeader.view
                { label = "Organizations"
                , url = "/organizations"
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
        , button = "Create Organization"
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
