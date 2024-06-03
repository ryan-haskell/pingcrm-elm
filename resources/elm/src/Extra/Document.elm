module Extra.Document exposing (Document, map)

import Browser
import Html


type alias Document msg =
    Browser.Document msg


map : (a -> b) -> Document a -> Document b
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }
