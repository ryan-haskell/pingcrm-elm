module Context exposing (Context)

import Url exposing (Url)


type alias Context =
    { url : Url
    , isMobile : Bool
    }
