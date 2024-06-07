module Main exposing (main)

import Effect exposing (Effect)
import Extra.Http
import Inertia.Effect
import Inertia.Program exposing (Program)
import Interop
import Json.Decode
import Pages
import Shared
import Url exposing (Url)


main : Program Pages.Model Shared.Model Pages.Msg Shared.Msg
main =
    Inertia.Program.new
        { shared =
            { init = Shared.init
            , update = Shared.update
            , subscriptions = Shared.subscriptions
            , onNavigationError = Shared.onNavigationError
            , effectToCmd = effectToCmd
            }
        , page =
            { init = Pages.init
            , update = Pages.update
            , subscriptions = Pages.subscriptions
            , view = Pages.view
            , onPropsChanged = Pages.onPropsChanged
            , effectToCmd = effectToCmd
            }
        , interop =
            { decoder = Interop.decoder
            , fallback = Interop.fallback
            , onRefreshXsrfToken = Interop.onRefreshXsrfToken
            , onXsrfTokenRefreshed = Interop.onXsrfTokenRefreshed
            }
        }



-- PERFORMING EFFECTS


type alias Msg =
    Inertia.Program.Msg Pages.Msg Shared.Msg


effectToCmd :
    { fromInertiaEffect : Inertia.Effect.Effect Msg -> Cmd Msg
    , fromSharedMsg : Shared.Msg -> Msg
    , shared : Shared.Model
    }
    -> (someMsg -> Msg)
    -> Effect someMsg
    -> Cmd Msg
effectToCmd props toMsg effect =
    effect
        |> Effect.map toMsg
        |> toCmd props


toCmd :
    { fromInertiaEffect : Inertia.Effect.Effect Msg -> Cmd Msg
    , fromSharedMsg : Shared.Msg -> Msg
    , shared : Shared.Model
    }
    -> Effect Msg
    -> Cmd Msg
toCmd props effect =
    case effect of
        Effect.Batch effects ->
            Cmd.batch (List.map (toCmd props) effects)

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

        Effect.Inertia inertiaEffect ->
            props.fromInertiaEffect inertiaEffect
