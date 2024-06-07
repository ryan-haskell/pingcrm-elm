port module Interop exposing
    ( Flags, decoder
    , onRefreshXsrfToken, onXsrfTokenRefreshed
    , onReportJsonDecodeError
    , onReportNavigationError, onNavigationError
    )

{-|

@docs Flags, decoder

@docs onRefreshXsrfToken, onXsrfTokenRefreshed

@docs onReportJsonDecodeError
@docs onReportNavigationError, onNavigationError

-}

import Json.Decode



-- FLAGS


type alias Flags =
    { window : WindowSize
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "window" windowSizeDecoder)


type alias WindowSize =
    { width : Float
    , height : Float
    }


windowSizeDecoder : Json.Decode.Decoder WindowSize
windowSizeDecoder =
    Json.Decode.map2 WindowSize
        (Json.Decode.field "width" Json.Decode.float)
        (Json.Decode.field "height" Json.Decode.float)



-- PORTS


port onRefreshXsrfToken : () -> Cmd msg


port onXsrfTokenRefreshed : (String -> msg) -> Sub msg


port onReportJsonDecodeError : { component : String, error : String } -> Cmd msg


port onReportNavigationError : { url : String, error : String } -> Cmd msg


port onNavigationError : ({ url : String, error : String } -> msg) -> Sub msg
