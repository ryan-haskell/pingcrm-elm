module Page.Error500 exposing
    ( Info
    , Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Info
@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Browser exposing (Document)
import Components.ErrorPage
import Effect exposing (Effect)
import Html exposing (Html)
import Inertia exposing (PageObject)
import Json.Decode exposing (Value)
import Shared
import Url exposing (Url)



-- PROPS


type alias Info =
    { pageObject : PageObject Value
    , error : Json.Decode.Error
    }



-- MODEL


type alias Model =
    {}


init : Shared.Model -> Url -> Info -> ( Model, Effect Msg )
init shared url info =
    ( {}
    , Effect.reportJsonDecodeError
        { component = info.pageObject.component
        , error = info.error
        }
    )



-- UPDATE


type Msg
    = DoNothing


update : Shared.Model -> Url -> Info -> Msg -> Model -> ( Model, Effect Msg )
update shared url info msg model =
    case msg of
        DoNothing ->
            ( model, Effect.none )


subscriptions : Shared.Model -> Url -> Info -> Model -> Sub Msg
subscriptions shared url info model =
    Sub.none



-- VIEW


view : Shared.Model -> Url -> Info -> Model -> Document Msg
view shared url info model =
    { title = "500"
    , body =
        Components.ErrorPage.view
            { title = "500"
            , message = "Unexpected data for '" ++ info.pageObject.component ++ "'"
            }
    }
