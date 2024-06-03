module Flags exposing (Flags)

import InertiaJs exposing (PageData)
import Json.Decode


type alias Flags =
    { pageData : PageData
    }
