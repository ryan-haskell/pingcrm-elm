module Shared.CommonProps exposing (CommonProps, decoder)

import Json.Decode
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)


type alias CommonProps errors =
    { auth : Auth
    , flash : Flash
    , errors : errors
    }


decoder : Json.Decode.Decoder errors -> Json.Decode.Decoder (CommonProps errors)
decoder errorsDecoder =
    Json.Decode.map3 CommonProps
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)
