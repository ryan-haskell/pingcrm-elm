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
import Layouts.Sidebar



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
    Layouts.Sidebar.view
        { user = model.props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Dashboard" ]
            , p [ class "mb-8 leading-normal" ]
                [ text "Hey, there! Welcome to Ping CRM, a demo app designed to help illustrate how "
                , a
                    [ class "text-indigo-500 hover:text-orange-600 underline"
                    , href "https://inertiajs.com"
                    ]
                    [ text "Inertia.js" ]
                , text " works."
                ]
            ]
        }
