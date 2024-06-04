module Domain.Organization exposing (Organization, decoder)

import Json.Decode


type alias Organization =
    { id : Int
    , name : String
    , city : Maybe String
    , phone : Maybe String
    , deletedAt : Maybe String
    }


decoder : Json.Decode.Decoder Organization
decoder =
    Json.Decode.map5 Organization
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "city" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "phone" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "deleted_at" (Json.Decode.maybe Json.Decode.string))
