module Pages.Dashboard.Index exposing
    ( Props, decoder
    , Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Props, decoder
@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Domain.Auth exposing (Auth)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)
import Json.Decode



-- PROPS


type alias Props =
    { auth : Auth
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map Props
        (Json.Decode.field "auth" Domain.Auth.decoder)



-- MODEL


type alias Model =
    { props : Props
    }


init : Props -> ( Model, Cmd Msg )
init props =
    ( { props = props
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "px-4 py-8 md:flex-1 md:p-12 md:overflow-y-auto"
        , attribute "scroll-region" ""
            |> Debug.log "NOTE: Is scroll-region an Inertia thing?"
        ]
        [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Dashboard" ]
        , p [ class "mb-8 leading-normal" ]
            [ text
                ("Hey, ${user}! Welcome to Ping CRM, a demo app designed to help illustrate how "
                    |> String.replace "${user}" model.props.auth.user.first_name
                )
            , a
                [ class "text-indigo-500 hover:text-orange-600 underline"
                , href "https://inertiajs.com"
                ]
                [ text "Inertia.js" ]
            , text " works."
            ]
        ]
