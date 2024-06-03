module Domain.Auth exposing (Auth, decoder)

import Domain.User exposing (User)
import Json.Decode


type alias Auth =
    { user : User
    }


decoder : Json.Decode.Decoder Auth
decoder =
    Json.Decode.map Auth
        (Json.Decode.field "user" Domain.User.decoder)
