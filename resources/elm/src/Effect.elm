module Effect exposing
    ( Effect(..)
    , none, batch
    , post
    , map
    )

{-|

@docs Effect
@docs none, batch

@docs post

@docs map

-}

import Http
import Json.Decode
import Json.Encode


type Effect msg
    = None
    | InertiaHttp (HttpRequest msg)
    | Batch (List (Effect msg))



-- BASICS


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch effects =
    Batch effects



-- HTTP


type alias HttpRequest msg =
    { method : String
    , url : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder msg
    , onFailure : Http.Error -> msg
    }


post :
    { url : String
    , body : Json.Encode.Value
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
post options =
    let
        decoder : Json.Decode.Decoder msg
        decoder =
            options.decoder
                |> Json.Decode.map (\props -> options.onResponse (Ok props))

        onFailure : Http.Error -> msg
        onFailure httpError =
            options.onResponse (Err httpError)
    in
    InertiaHttp
        { method = "POST"
        , url = options.url
        , body = Http.jsonBody options.body
        , decoder = decoder
        , onFailure = onFailure
        }



-- MAP


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        None ->
            None

        InertiaHttp req ->
            InertiaHttp (mapHttpRequest fn req)

        Batch effects ->
            Batch (List.map (map fn) effects)


mapHttpRequest : (a -> b) -> HttpRequest a -> HttpRequest b
mapHttpRequest fn req =
    { method = req.method
    , url = req.url
    , body = req.body
    , decoder = Json.Decode.map fn req.decoder
    , onFailure = fn << req.onFailure
    }
