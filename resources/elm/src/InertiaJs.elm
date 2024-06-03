module InertiaJs exposing (PageData)

import Json.Decode


type alias PageData =
    { component : String
    , props : Json.Decode.Value
    , url : String
    , version : String
    }
