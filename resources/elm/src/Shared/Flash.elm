module Shared.Flash exposing (Flash, decoder)

import Json.Decode


type alias Flash =
    { success : Maybe String
    , error : Maybe String
    }


decoder : Json.Decode.Decoder Flash
decoder =
    Json.Decode.map2 Flash
        (Json.Decode.field "success" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "error" (Json.Decode.maybe Json.Decode.string))
