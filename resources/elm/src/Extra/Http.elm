module Extra.Http exposing
    ( Request
    , map
    , toUserFriendlyMessage
    )

import Http
import Json.Decode


type alias Request msg =
    { method : String
    , url : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder msg
    , onFailure : Http.Error -> msg
    }


map : (a -> b) -> Request a -> Request b
map fn req =
    { method = req.method
    , url = req.url
    , body = req.body
    , decoder = Json.Decode.map fn req.decoder
    , onFailure = fn << req.onFailure
    }


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage error =
    case error of
        Http.BadBody body ->
            "Got an unexpected response."

        Http.NetworkError ->
            "Could not connect to server."

        Http.Timeout ->
            "Request timed out."

        Http.BadStatus 409 ->
            "New update is available, please refresh."

        Http.BadStatus 419 ->
            "Session has expired, please refresh."

        Http.BadStatus code ->
            "Unexpected status: " ++ String.fromInt code

        Http.BadUrl url ->
            "Unexpected URL"
