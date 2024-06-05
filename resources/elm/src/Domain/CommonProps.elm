module Domain.CommonProps exposing (CommonProps, decoder)

import Domain.Auth exposing (Auth)
import Domain.Flash exposing (Flash)
import Json.Decode


type alias CommonProps errors =
    { auth : Auth
    , flash : Flash
    , errors : errors
    }


decoder : Json.Decode.Decoder errors -> Json.Decode.Decoder (CommonProps errors)
decoder errorsDecoder =
    Json.Decode.map3 CommonProps
        (Json.Decode.field "auth" Domain.Auth.decoder)
        (Json.Decode.field "flash" Domain.Flash.decoder)
        (Json.Decode.field "errors" errorsDecoder)
