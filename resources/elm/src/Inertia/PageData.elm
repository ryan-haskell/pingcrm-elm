module Inertia.PageData exposing
    ( PageData
    , decoder
    )

import Json.Decode


type alias PageData =
    { component : String
    , props : Json.Decode.Value
    , url : String
    , version : String
    }


decoder : Json.Decode.Decoder PageData
decoder =
    Json.Decode.map4 PageData
        (Json.Decode.field "component" Json.Decode.string)
        (Json.Decode.field "props" Json.Decode.value)
        (Json.Decode.field "url" Json.Decode.string)
        (Json.Decode.field "version" Json.Decode.string)
