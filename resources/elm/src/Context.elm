module Context exposing (Context)

import Shared
import Url exposing (Url)


type alias Context =
    { shared : Shared.Model
    , url : Url
    }
