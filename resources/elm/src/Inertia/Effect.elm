module Inertia.Effect exposing
    ( Effect(..)
    , none, batch
    , sendMsg
    , get, post, put, delete
    , pushUrl, replaceUrl, back, forward
    , map
    )

{-|

@docs Effect
@docs none, batch

@docs sendMsg

@docs get, post, put, delete

@docs pushUrl, replaceUrl, back, forward

@docs map

-}

import Extra.Http
import Http
import Json.Decode
import Json.Encode
import Url exposing (Url)


type Effect msg
    = None
    | Batch (List (Effect msg))
    | Http (Extra.Http.Request msg)
    | SendMsg msg
    | PushUrl String
    | ReplaceUrl String
    | Back Int
    | Forward Int



-- BASICS


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch effects =
    Batch effects



-- MESSAGES


sendMsg : msg -> Effect msg
sendMsg msg =
    SendMsg msg



-- URL NAVIGATION


pushUrl : String -> Effect msg
pushUrl url =
    PushUrl url


replaceUrl : String -> Effect msg
replaceUrl url =
    ReplaceUrl url


back : Int -> Effect msg
back int =
    Back int


forward : Int -> Effect msg
forward int =
    Forward int



-- HTTP


{-| Feels like this is only useful if you want to get data without changing the URL.

Prefer `Effect.pushUrl` instead, which does normal inertia things!

-}
get :
    { url : String
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
get options =
    let
        decoder : Json.Decode.Decoder msg
        decoder =
            options.decoder
                |> Json.Decode.map (\props -> options.onResponse (Ok props))

        onFailure : Http.Error -> msg
        onFailure httpError =
            options.onResponse (Err httpError)
    in
    Http
        { method = "GET"
        , url = options.url
        , body = Http.emptyBody
        , decoder = decoder
        , onFailure = onFailure
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
    Http
        { method = "POST"
        , url = options.url
        , body = Http.jsonBody options.body
        , decoder = decoder
        , onFailure = onFailure
        }


put :
    { url : String
    , body : Json.Encode.Value
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
put options =
    let
        decoder : Json.Decode.Decoder msg
        decoder =
            options.decoder
                |> Json.Decode.map (\props -> options.onResponse (Ok props))

        onFailure : Http.Error -> msg
        onFailure httpError =
            options.onResponse (Err httpError)
    in
    Http
        { method = "PUT"
        , url = options.url
        , body = Http.jsonBody options.body
        , decoder = decoder
        , onFailure = onFailure
        }


delete :
    { url : String
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
delete options =
    let
        decoder : Json.Decode.Decoder msg
        decoder =
            options.decoder
                |> Json.Decode.map (\props -> options.onResponse (Ok props))

        onFailure : Http.Error -> msg
        onFailure httpError =
            options.onResponse (Err httpError)
    in
    Http
        { method = "DELETE"
        , url = options.url
        , body = Http.emptyBody
        , decoder = decoder
        , onFailure = onFailure
        }



-- MAP


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        None ->
            None

        Batch effects ->
            Batch (List.map (map fn) effects)

        SendMsg msg ->
            SendMsg (fn msg)

        Http req ->
            Http (Extra.Http.map fn req)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        Back int ->
            Back int

        Forward int ->
            Forward int
