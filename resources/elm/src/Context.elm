module Context exposing (Context)

import Layouts.Sidebar
import Url exposing (Url)


type alias Context =
    { url : Url
    , sidebar : Layouts.Sidebar.Model
    , isMobile : Bool
    }
