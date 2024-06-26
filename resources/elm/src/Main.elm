module Main exposing (main)

import Effect exposing (Effect)
import Extra.Http
import Inertia
import Inertia.Effect
import Interop
import Json.Decode
import Pages
import Shared
import Url exposing (Url)


type alias Model =
    Inertia.Model Pages.Model Shared.Model


type alias Msg =
    Inertia.Msg Pages.Msg Shared.Msg


main : Inertia.Program Model Msg
main =
    Inertia.program
        { shared =
            { init = Shared.init
            , update = Shared.update
            , subscriptions = Shared.subscriptions
            , onNavigationError = Shared.onNavigationError
            }
        , page =
            { init = Pages.init
            , update = Pages.update
            , subscriptions = Pages.subscriptions
            , view = Pages.view
            , onPropsChanged = Pages.onPropsChanged
            }
        , interop =
            { decoder = Interop.decoder
            , onRefreshXsrfToken = Interop.onRefreshXsrfToken
            , onXsrfTokenRefreshed = Interop.onXsrfTokenRefreshed
            }
        , effect =
            { fromCustomEffectToCmd = fromCustomEffectToCmd
            , fromShared = Effect.mapCustomEffect
            , fromPage = Effect.mapCustomEffect
            }
        }



-- PERFORMING CUSTOM EFFECTS


fromCustomEffectToCmd :
    { shared : Shared.Model
    , url : Url
    , fromSharedMsg : Shared.Msg -> msg
    }
    -> Effect.CustomEffect msg
    -> Cmd msg
fromCustomEffectToCmd props customEffect =
    case customEffect of
        Effect.ReportJsonDecodeError data ->
            Interop.onReportJsonDecodeError
                { component = data.component
                , error = Json.Decode.errorToString data.error
                }

        Effect.ReportNavigationError data ->
            Interop.onReportNavigationError
                { url = Url.toString data.url
                , error = Extra.Http.toUserFriendlyMessage data.error
                }
