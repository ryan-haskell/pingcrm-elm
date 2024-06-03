module Flags exposing (Flags)

import InertiaJs.PageData exposing (PageData)
import Json.Decode


type alias Flags =
    { pageData : PageData
    }
