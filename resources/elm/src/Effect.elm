module Effect exposing
    ( Effect
    , none, batch
    , sendMsg, sendDelayedMsg
    , get, post, delete
    , reportJsonDecodeError
    , pushUrl
    , map
    , switch
    )

{-|

@docs Effect
@docs none, batch

@docs sendMsg, sendDelayedMsg

@docs get, post, delete

@docs reportJsonDecodeError

@docs pushUrl

@docs map
@docs switch

-}

import Extra.Http
import Http
import Json.Decode
import Json.Encode


type Effect msg
    = None
    | Batch (List (Effect msg))
    | InertiaHttp (Extra.Http.Request msg)
    | SendMsg msg
    | SendDelayedMsg Float msg
    | ReportJsonDecodeError { page : String, error : Json.Decode.Error }
    | PushUrl String



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


sendDelayedMsg : { delay : Float, msg : msg } -> Effect msg
sendDelayedMsg { delay, msg } =
    SendDelayedMsg delay msg



-- URL NAVIGATION


pushUrl : String -> Effect msg
pushUrl url =
    PushUrl url



-- CONSOLE


reportJsonDecodeError :
    { page : String
    , error : Json.Decode.Error
    }
    -> Effect msg
reportJsonDecodeError props =
    ReportJsonDecodeError props



-- HTTP


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
    InertiaHttp
        { method = "DELETE"
        , url = options.url
        , body = Http.emptyBody
        , decoder = decoder
        , onFailure = onFailure
        }


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
    InertiaHttp
        { method = "GET"
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

        SendDelayedMsg delay msg ->
            SendDelayedMsg delay (fn msg)

        InertiaHttp req ->
            InertiaHttp (Extra.Http.map fn req)

        ReportJsonDecodeError msg ->
            ReportJsonDecodeError msg

        PushUrl url ->
            PushUrl url


{-| An experimental way to support `Main.toCmd` functionality without
exposing the variants for the Effect type.

Keeps `Effect.none` vs `Effect.None` usage clear, and prevents
exposing internals of module like `InertiaHttp` which is too clunky
that it shouldn't be called.

> Looked cute, might delete later!

-}
switch :
    { onNone : value
    , onBatch : List (Effect msg) -> value
    , onInertiaHttp : Extra.Http.Request msg -> value
    , onSendMsg : msg -> value
    , onSendDelayedMsg : Float -> msg -> value
    , onReportJsonDecodeError : { page : String, error : Json.Decode.Error } -> value
    , onPushUrl : String -> value
    }
    -> Effect msg
    -> value
switch handlers effect =
    case effect of
        None ->
            handlers.onNone

        Batch effects ->
            handlers.onBatch effects

        SendMsg msg ->
            handlers.onSendMsg msg

        SendDelayedMsg delay msg ->
            handlers.onSendDelayedMsg delay msg

        InertiaHttp req ->
            handlers.onInertiaHttp req

        ReportJsonDecodeError msg ->
            handlers.onReportJsonDecodeError msg

        PushUrl url ->
            handlers.onPushUrl url
