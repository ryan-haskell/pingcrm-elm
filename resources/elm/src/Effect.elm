module Effect exposing
    ( Effect(..)
    , none, batch
    , sendMsg, sendDelayedMsg
    , sendSidebarMsg
    , showProblem
    , post, delete
    , reportJsonDecodeError
    , map
    )

{-|

@docs Effect
@docs none, batch

@docs sendMsg, sendDelayedMsg

@docs sendSidebarMsg
@docs showProblem

@docs post, delete

@docs reportJsonDecodeError

@docs map

-}

import Http
import Json.Decode
import Json.Encode
import Layouts.Sidebar.Msg


type Effect msg
    = None
    | Batch (List (Effect msg))
    | InertiaHttp (HttpRequest msg)
    | SendMsg msg
    | SendDelayedMsg Float msg
    | SendSidebarMsg Layouts.Sidebar.Msg.Msg
    | ShowProblem { message : String, details : Maybe String }
    | ReportJsonDecodeError { page : String, error : Json.Decode.Error }



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



-- CONSOLE


reportJsonDecodeError :
    { page : String
    , error : Json.Decode.Error
    }
    -> Effect msg
reportJsonDecodeError props =
    ReportJsonDecodeError props



-- SIDEBAR


sendSidebarMsg : Layouts.Sidebar.Msg.Msg -> Effect msg
sendSidebarMsg sidebarMsg =
    SendSidebarMsg sidebarMsg



-- COMMUNICATING ERRORS


showProblem : { message : String, details : Maybe String } -> Effect msg
showProblem problem =
    ShowProblem problem



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

        ShowProblem problem ->
            ShowProblem problem

        SendSidebarMsg msg ->
            SendSidebarMsg msg

        InertiaHttp req ->
            InertiaHttp (mapHttpRequest fn req)

        ReportJsonDecodeError msg ->
            ReportJsonDecodeError msg


mapHttpRequest : (a -> b) -> HttpRequest a -> HttpRequest b
mapHttpRequest fn req =
    { method = req.method
    , url = req.url
    , body = req.body
    , decoder = Json.Decode.map fn req.decoder
    , onFailure = fn << req.onFailure
    }
