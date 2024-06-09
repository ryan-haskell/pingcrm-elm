module Effect exposing
    ( Effect
    , none, batch
    , sendMsg
    , get, post, put, delete
    , pushUrl, replaceUrl, back, forward
    , load, reload, reloadAndSkipCache
    , map
    , CustomEffect, mapCustomEffect, switch
    , reportJsonDecodeError
    , reportNavigationError
    )

{-|

@docs Effect

@docs none, batch
@docs sendMsg

@docs get, post, put, delete

@docs pushUrl, replaceUrl, back, forward
@docs load, reload, reloadAndSkipCache

@docs map

@docs CustomEffect, mapCustomEffect, switch
@docs reportJsonDecodeError
@docs reportNavigationError

-}

import Http
import Inertia.Effect
import Json.Decode
import Json.Encode
import Url exposing (Url)



-- EFFECTS


type alias Effect msg =
    Inertia.Effect.Effect (CustomEffect msg) msg


none : Effect msg
none =
    Inertia.Effect.none


batch : List (Effect msg) -> Effect msg
batch =
    Inertia.Effect.batch


sendMsg : msg -> Effect msg
sendMsg =
    Inertia.Effect.sendMsg



-- HTTP


get :
    { url : String
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
get =
    Inertia.Effect.get


post :
    { url : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
post =
    Inertia.Effect.post


put :
    { url : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
put =
    Inertia.Effect.put


patch :
    { url : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
patch =
    Inertia.Effect.patch


delete :
    { url : String
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
delete =
    Inertia.Effect.delete


request :
    { method : String
    , url : String
    , body : Http.Body
    , decoder : Json.Decode.Decoder msg
    , onFailure : Http.Error -> msg
    , headers : List Http.Header
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Effect msg
request =
    Inertia.Effect.request



-- URL NAVIGATION


pushUrl : String -> Effect msg
pushUrl =
    Inertia.Effect.pushUrl


replaceUrl : String -> Effect msg
replaceUrl =
    Inertia.Effect.replaceUrl


back : Int -> Effect msg
back =
    Inertia.Effect.back


forward : Int -> Effect msg
forward =
    Inertia.Effect.forward


load : String -> Effect msg
load =
    Inertia.Effect.load


reload : Effect msg
reload =
    Inertia.Effect.reload


reloadAndSkipCache : Effect msg
reloadAndSkipCache =
    Inertia.Effect.reloadAndSkipCache



-- TRANSFORM


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    Inertia.Effect.map (mapCustomEffect fn) fn effect



-- CUSTOM EFFECTS


type CustomEffect msg
    = ReportJsonDecodeError { component : String, error : Json.Decode.Error }
    | ReportNavigationError { url : Url, error : Http.Error }


mapCustomEffect : (a -> b) -> CustomEffect a -> CustomEffect b
mapCustomEffect fn customEffect =
    case customEffect of
        ReportJsonDecodeError data ->
            ReportJsonDecodeError data

        ReportNavigationError data ->
            ReportNavigationError data


reportJsonDecodeError : { component : String, error : Json.Decode.Error } -> Effect msg
reportJsonDecodeError props =
    Inertia.Effect.custom (ReportJsonDecodeError props)


reportNavigationError : { url : Url, error : Http.Error } -> Effect msg
reportNavigationError props =
    Inertia.Effect.custom (ReportNavigationError props)


switch :
    CustomEffect msg
    ->
        { onReportJsonDecodeError : { component : String, error : Json.Decode.Error } -> value
        , onReportNavigationError : { url : Url, error : Http.Error } -> value
        }
    -> value
switch effect handlers =
    case effect of
        ReportJsonDecodeError props ->
            handlers.onReportJsonDecodeError props

        ReportNavigationError props ->
            handlers.onReportNavigationError props
