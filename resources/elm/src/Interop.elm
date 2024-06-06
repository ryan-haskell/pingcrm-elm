port module Interop exposing
    ( Flags
    , reportJsonDecodeError
    , reportNavigationError, onNavigationError
    , refreshXsrfToken, onXsrfTokenRefreshed
    )

{-|

@docs Flags

@docs reportJsonDecodeError

@docs reportNavigationError, onNavigationError

@docs refreshXsrfToken, onXsrfTokenRefreshed

-}

import Json.Decode
import Shared.PageData exposing (PageData)



-- FLAGS


type alias Flags =
    { window : { width : Float }
    , pageData : PageData Json.Decode.Value
    , xsrfToken : String
    }



-- PORTS


port reportJsonDecodeError : { page : String, error : String } -> Cmd msg


port reportNavigationError : { url : String, error : String } -> Cmd msg


port onNavigationError : ({ url : String, error : String } -> msg) -> Sub msg


port refreshXsrfToken : () -> Cmd msg


port onXsrfTokenRefreshed : (String -> msg) -> Sub msg
