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
import Json.Decode
import Url exposing (Url)


type alias Model =
    { isMobile : Bool
    }


type Msg
    = NavigationError { url : Url, error : Http.Error }
    | Resize Int Int


init : Result Json.Decode.Error Flags -> Url -> ( Model, Effect Msg )
init flagsResult url =
    case flagsResult of
        Ok flags ->
            ( { isMobile = flags.window.width < 740 }
            , Effect.none
            )

        Err jsonDecodeError ->
            ( { isMobile = False }
            , Effect.reportJsonDecodeError
                { component = "Flags"
                , error = jsonDecodeError
                }
            )


update : Url -> Msg -> Model -> ( Model, Effect Msg )
update url msg model =
    case msg of
        NavigationError info ->
            case info.error of
                Http.BadStatus 409 ->
                    -- There's a new app version, refresh automatically for user
                    -- during page navigation
                    ( model
                    , Effect.load (Url.toString info.url)
                    )

                _ ->
                    ( model
                    , Effect.reportNavigationError info
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
