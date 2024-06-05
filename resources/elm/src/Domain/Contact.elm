module Domain.Contact exposing (Contact, decoder)

import Json.Decode


type alias Contact =
    { id : Int
    , name : String
    , organization : Maybe String
    , city : Maybe String
    , phone : Maybe String
    , deletedAt : Maybe String
    }


decoder : Json.Decode.Decoder Contact
decoder =
    Json.Decode.map6 Contact
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "organization" (Json.Decode.maybe (Json.Decode.field "name" Json.Decode.string)))
        (Json.Decode.field "city" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "phone" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "deleted_at" (Json.Decode.maybe Json.Decode.string))
