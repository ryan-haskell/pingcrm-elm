module Flags exposing (Flags)

import Inertia.PageData exposing (PageData)
import Json.Decode


type alias Flags =
    { pageData : PageData Json.Decode.Value
    , xsrfToken : String
    }
