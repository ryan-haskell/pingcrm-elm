module Pages.Error404 exposing
    ( Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Browser exposing (Document)
import Components.ErrorPage
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode
import Shared
import Url exposing (Url)



-- MODEL


type alias Model =
    {}


init : Shared.Model -> Url -> ( Model, Effect Msg )
init shared url =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = DoNothing


update : Shared.Model -> Url -> Msg -> Model -> ( Model, Effect Msg )
update shared url msg model =
    case msg of
        DoNothing ->
            ( model, Effect.none )


subscriptions : Shared.Model -> Url -> Model -> Sub Msg
subscriptions shared url model =
    Sub.none



-- VIEW


view : Shared.Model -> Url -> Model -> Document Msg
view shared url model =
    { title = "404 | PingCRM"
    , body =
        Components.ErrorPage.view
            { title = "404"
            , message = url.path
            }
    }
