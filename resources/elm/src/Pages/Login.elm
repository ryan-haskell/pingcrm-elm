module Pages.Login exposing
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
import Components.Logo
import Context exposing (Context)
import Domain.Auth exposing (Auth)
import Effect exposing (Effect)
import Extra.Http
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Http
import Inertia.PageData exposing (PageData)
import Json.Decode
import Json.Encode



-- PROPS


type alias Props =
    {}


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.succeed Props



-- MODEL


type alias Model =
    { email : String
    , password : String
    , remember : Bool
    , emailError : Maybe String
    , formError : Maybe Http.Error
    }


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { email = "johndoe@example.com"
      , password = "secret"
      , remember = True
      , emailError = Nothing
      , formError = Nothing
      }
    , Effect.none
    )


onPropsChanged : Context -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged ctx props model =
    ( model
    , Effect.none
    )



-- UPDATE


type Msg
    = EmailChanged String
    | PasswordChanged String
    | RememberChanged Bool
    | FormSubmitted
    | ApiResponded (Result Http.Error LoginResponse)


type alias LoginResponse =
    { emailError : Maybe String
    }


loginResponseDecoder : Json.Decode.Decoder LoginResponse
loginResponseDecoder =
    Json.Decode.map LoginResponse
        (Json.Decode.maybe (Json.Decode.at [ "errors", "email" ] Json.Decode.string))


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg model =
    case msg of
        EmailChanged value ->
            ( { model | email = value, emailError = Nothing }
            , Effect.none
            )

        PasswordChanged value ->
            ( { model | password = value, emailError = Nothing }
            , Effect.none
            )

        RememberChanged bool ->
            ( { model | remember = bool }
            , Effect.none
            )

        FormSubmitted ->
            let
                form : Json.Encode.Value
                form =
                    Json.Encode.object
                        [ ( "email", Json.Encode.string model.email )
                        , ( "password", Json.Encode.string model.password )
                        , ( "remember", Json.Encode.bool model.remember )
                        ]
            in
            ( { model | formError = Nothing }
            , Effect.post
                { url = "/login"
                , body = form
                , decoder = loginResponseDecoder
                , onResponse = ApiResponded
                }
            )

        ApiResponded (Ok response) ->
            ( { model | emailError = response.emailError }
            , Effect.none
            )

        ApiResponded (Err httpError) ->
            ( { model | formError = Just httpError }
            , Effect.none
            )


subscriptions : Context -> Model -> Sub Msg
subscriptions ctx model =
    Sub.none



-- VIEW


view : Context -> Model -> Document Msg
view ctx model =
    { title = "Login - Ping CRM"
    , body =
        [ div [ class "flex items-center justify-center p-6 min-h-screen bg-indigo-800" ]
            [ div [ class "w-full max-w-md" ]
                [ Components.Logo.viewBig
                , form
                    [ Html.Events.onSubmit FormSubmitted
                    , class "mt-8 bg-white rounded-lg shadow-xl overflow-hidden"
                    ]
                    [ div [ class "px-10 py-12" ]
                        [ h1 [ class "text-center text-3xl font-bold" ]
                            [ text "Welcome Back!" ]
                        , div [ class "mt-6 mx-auto w-24 border-b-2" ] []
                        , div [ class "mt-10" ]
                            [ label
                                [ class "form-label"
                                , Attr.for "emailField"
                                ]
                                [ text "Email:" ]
                            , input
                                [ Attr.id "emailField"
                                , class "form-input"
                                , Attr.classList [ ( "error", model.emailError /= Nothing ) ]
                                , Attr.autofocus True
                                , attribute "autocapitalize" "none"
                                , Attr.type_ "email"
                                , Html.Events.onInput EmailChanged
                                , Attr.value model.email
                                ]
                                []
                            , viewMaybeError model.emailError
                            ]
                        , div [ class "mt-6" ]
                            [ label
                                [ class "form-label"
                                , Attr.for "passwordField"
                                ]
                                [ text "Password:" ]
                            , input
                                [ Attr.id "passwordField"
                                , class "form-input"
                                , Attr.type_ "password"
                                , Html.Events.onInput PasswordChanged
                                , Attr.value model.password
                                ]
                                []
                            ]
                        , label
                            [ class "flex items-center mt-6 select-none"
                            , Attr.for "remember"
                            ]
                            [ input
                                [ Attr.id "remember"
                                , class "mr-1"
                                , Attr.type_ "checkbox"
                                , Attr.checked model.remember
                                , Html.Events.onCheck RememberChanged
                                ]
                                []
                            , span [ class "text-sm" ] [ text "Remember Me" ]
                            ]
                        ]
                    , div [ class "flex px-10 py-4 bg-gray-100 border-t border-gray-100" ]
                        [ model.formError
                            |> Maybe.map Extra.Http.toUserFriendlyMessage
                            |> viewMaybeError
                        , button
                            [ class "flex items-center btn-indigo ml-auto"
                            , Attr.type_ "submit"
                            ]
                            [ text "Login" ]
                        ]
                    ]
                ]
            ]
        ]
    }


viewMaybeError : Maybe String -> Html msg
viewMaybeError maybe =
    case maybe of
        Just reason ->
            div [ class "form-error" ] [ text reason ]

        Nothing ->
            text ""
