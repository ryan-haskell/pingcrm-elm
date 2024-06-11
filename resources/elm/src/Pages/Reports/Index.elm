module Pages.Reports.Index exposing
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
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)
import Json.Decode
import Layouts.Sidebar
import Shared
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)
import Url exposing (Url)



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map2 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)



-- MODEL


type alias Model =
    { sidebar : Layouts.Sidebar.Model
    }


init : Shared.Model -> Url -> Props -> ( Model, Effect Msg )
init shared url props =
    ( { sidebar = Layouts.Sidebar.init { flash = props.flash }
      }
    , Effect.none
    )


onPropsChanged : Shared.Model -> Url -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged shared url props model =
    ( model
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg


update : Shared.Model -> Url -> Props -> Msg -> Model -> ( Model, Effect Msg )
update shared url props msg model =
    case msg of
        Sidebar sidebarMsg ->
            Layouts.Sidebar.update
                { msg = sidebarMsg
                , model = model.sidebar
                , toModel = \sidebar -> { model | sidebar = sidebar }
                , toMsg = Sidebar
                }


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
        , title = "Reports"
        , user = props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Reports" ]
            , p [ class "mb-4 leading-normal" ]
                [ text "The \"Reports\" feature is under legal investigation at this time. "
                ]
            , p [ class "mb-4 leading-normal" ]
                [ text "Our legal team would like to notify customers that their report data was not sold to fund our separate venture, \"Hamster Yacht Incorporated\". These allegations are unverified and baseless." ]
            , p [ class "mb-8 leading-normal" ]
                [ text "However, it is true that the hamsters have been trained to drive the fleet of mini-yachts. Thank you."
                ]
            ]
        , overlays = []
        }
