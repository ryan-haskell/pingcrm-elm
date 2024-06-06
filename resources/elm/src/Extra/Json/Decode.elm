module Extra.Json.Decode exposing
    ( object
    , required, optional
    )

{-|

@docs object
@docs required, optional

-}

import Json.Decode


object : value -> Json.Decode.Decoder value
object value =
    Json.Decode.succeed value


required :
    String
    -> Json.Decode.Decoder field
    -> Json.Decode.Decoder (field -> value)
    -> Json.Decode.Decoder value
required name fieldDecoder fnDecoder =
    Json.Decode.map2 (|>)
        (Json.Decode.field name fieldDecoder)
        fnDecoder


optional :
    String
    -> Json.Decode.Decoder field
    -> Json.Decode.Decoder (Maybe field -> value)
    -> Json.Decode.Decoder value
optional name fieldDecoder fnDecoder =
    Json.Decode.map2 (|>)
        (Json.Decode.maybe (Json.Decode.field name fieldDecoder))
        fnDecoder
