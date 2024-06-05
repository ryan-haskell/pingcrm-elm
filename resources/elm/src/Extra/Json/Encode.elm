module Extra.Json.Encode exposing (toIntOrNull, toStringOrNull)

import Json.Encode


toStringOrNull : String -> Json.Encode.Value
toStringOrNull str =
    if String.isEmpty (String.trim str) then
        Json.Encode.null

    else
        Json.Encode.string str


toIntOrNull : String -> Json.Encode.Value
toIntOrNull str =
    case String.toInt str of
        Just int ->
            Json.Encode.int int

        Nothing ->
            Json.Encode.null
