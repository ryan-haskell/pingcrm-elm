module Pages.Dashboard exposing
    ( Props, decoder
    , Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Props, decoder
@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Browser exposing (Document)
import Context exposing (Context)
import Domain.Auth exposing (Auth)
import Domain.Flash exposing (Flash)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)
import Json.Decode
import Layouts.Sidebar



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map2 Props
        (Json.Decode.field "auth" Domain.Auth.decoder)
        (Json.Decode.field "flash" Domain.Flash.decoder)



-- MODEL


type alias Model =
    { props : Props
    }


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { props = props
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg model =
    case msg of
        Sidebar sidebarMsg ->
            ( model, Effect.sendSidebarMsg sidebarMsg )


subscriptions : Context -> Model -> Sub Msg
subscriptions ctx model =
    Sub.none



-- VIEW


view : Context -> Model -> Document Msg
view ctx model =
    Layouts.Sidebar.view
        { model = ctx.sidebar
        , flash = model.props.flash
        , toMsg = Sidebar
        , url = ctx.url
        , title = "Dashboard"
        , user = model.props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Dashboard" ]
            , p [ class "mb-8 leading-normal" ]
                [ text "Hey there! Welcome to Ping CRM, a demo app designed to help illustrate how "
                , a
                    [ class "text-indigo-500 hover:text-orange-600 underline"
                    , href "https://inertiajs.com"
                    ]
                    [ text "Inertia.js" ]
                , text " works."
                ]
            ]
        }
