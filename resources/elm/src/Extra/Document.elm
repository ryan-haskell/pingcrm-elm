module Extra.Document exposing (Document, map, none)

import Browser
import Html


type alias Document msg =
    Browser.Document msg


none : Document msg
none =
    { title = ""
    , body = []
    }


map : (a -> b) -> Document a -> Document b
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }
