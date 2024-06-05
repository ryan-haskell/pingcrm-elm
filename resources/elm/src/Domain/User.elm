module Domain.User exposing (User, decoder)

import Json.Decode


type alias User =
    { id : Int
    , name : String
    , email : String
    , owner : Bool
    , deleted_at : Maybe String
    }


decoder : Json.Decode.Decoder User
decoder =
    Json.Decode.map5 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.field "owner" Json.Decode.bool)
        (Json.Decode.field "deleted_at" (Json.Decode.maybe Json.Decode.string))
