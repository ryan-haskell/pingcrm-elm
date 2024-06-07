module Shared exposing
    ( Model, init
    , Msg, update, subscriptions
    , onNavigationError
    )

{-|

@docs Model, init
@docs Msg, update, subscriptions

@docs onNavigationError

-}

import Browser.Events
import Effect exposing (Effect)
import Http
import Interop exposing (Flags)
import Url exposing (Url)


type alias Model =
    { isMobile : Bool
    }


type Msg
    = NavigationError { url : Url, error : Http.Error }
    | Resize Int Int


init : Flags -> Url -> ( Model, Effect Msg )
init flags url =
    ( { isMobile = flags.window.width < 740 }
    , Effect.none
    )


update : Url -> Msg -> Model -> ( Model, Effect Msg )
update url msg model =
    case msg of
        NavigationError error ->
            ( model
            , Effect.reportNavigationError error
            )

        Resize width height ->
            ( { model | isMobile = width < 740 }
            , Effect.none
            )


subscriptions : Url -> Model -> Sub Msg
subscriptions url model =
    Browser.Events.onResize Resize


onNavigationError : { url : Url, error : Http.Error } -> Msg
onNavigationError data =
    NavigationError data
