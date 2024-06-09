module Main exposing (main)

import Effect exposing (Effect)
import Extra.Http
import Inertia
import Inertia.Effect
import Interop
import Json.Decode
import Page
import Shared
import Url exposing (Url)


type alias Model =
    Inertia.Model Page.Model Shared.Model


type alias Msg =
    Inertia.Msg Page.Msg Shared.Msg


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
            { init = Page.init
            , update = Page.update
            , subscriptions = Page.subscriptions
            , view = Page.view
            , onPropsChanged = Page.onPropsChanged
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
    Effect.switch customEffect
        { onReportJsonDecodeError =
            \data ->
                Interop.onReportJsonDecodeError
                    { component = data.component
                    , error = Json.Decode.errorToString data.error
                    }
        , onReportNavigationError =
            \data ->
                Interop.onReportNavigationError
                    { url = Url.toString data.url
                    , error = Extra.Http.toUserFriendlyMessage data.error
                    }
        }
