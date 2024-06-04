module Extra.Http exposing (toUserFriendlyMessage)

import Http


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage error =
    case error of
        Http.BadBody body ->
            "Got an unexpected response."

        Http.NetworkError ->
            "Could not connect to server."

        Http.Timeout ->
            "Request timed out."

        Http.BadStatus 419 ->
            "Session has expired, please refresh."

        Http.BadStatus code ->
            "Unexpected status: " ++ String.fromInt code

        Http.BadUrl url ->
            "Unexpected URL"
