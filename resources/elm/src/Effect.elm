module Effect exposing
    ( Effect(..)
    , none, batch
    , sendMsg
    , get, post, put, delete
    , pushUrl, replaceUrl, back, forward
    , reportJsonDecodeError
    , reportNavigationError
    , map
    )

{-|

@docs Effect

@docs none, batch
@docs sendMsg
@docs get, post, put, delete
@docs pushUrl, replaceUrl, back, forward

@docs reportJsonDecodeError
@docs reportNavigationError

@docs map

-}

import Http
import Inertia.Effect
import Json.Decode
import Json.Encode
import Url exposing (Url)


type Effect msg
    = ReportJsonDecodeError
        { component : String
        , error : Json.Decode.Error
        }
    | ReportNavigationError
        { url : Url
        , error : Http.Error
        }
    | Inertia (Inertia.Effect.Effect msg)
    | Batch (List (Effect msg))



-- BASICS


none : Effect msg
none =
    Inertia Inertia.Effect.none


batch : List (Effect msg) -> Effect msg
batch effects =
    Batch effects



-- MESSAGES


sendMsg : msg -> Effect msg
sendMsg msg =
    Inertia (Inertia.Effect.sendMsg msg)



-- URL NAVIGATION


pushUrl : String -> Effect msg
pushUrl url =
    Inertia (Inertia.Effect.pushUrl url)


replaceUrl : String -> Effect msg
replaceUrl url =
    Inertia (Inertia.Effect.replaceUrl url)


back : Int -> Effect msg
back int =
    Inertia (Inertia.Effect.back int)


forward : Int -> Effect msg
forward int =
    Inertia (Inertia.Effect.forward int)



-- HTTP


get :
    { url : String
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
get options =
    Inertia (Inertia.Effect.get options)


post :
    { url : String
    , body : Json.Encode.Value
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
post options =
    Inertia (Inertia.Effect.post options)


put :
    { url : String
    , body : Json.Encode.Value
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
put options =
    Inertia (Inertia.Effect.put options)


delete :
    { url : String
    , decoder : Json.Decode.Decoder props
    , onResponse : Result Http.Error props -> msg
    }
    -> Effect msg
delete options =
    Inertia (Inertia.Effect.delete options)



-- CUSTOM


reportJsonDecodeError : { component : String, error : Json.Decode.Error } -> Effect msg
reportJsonDecodeError props =
    ReportJsonDecodeError props


reportNavigationError : { url : Url, error : Http.Error } -> Effect msg
reportNavigationError props =
    ReportNavigationError props



-- MAPPING


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        Batch effects ->
            Batch (List.map (map fn) effects)

        ReportJsonDecodeError props ->
            ReportJsonDecodeError props

        ReportNavigationError props ->
            ReportNavigationError props

        Inertia inertiaEffect ->
            Inertia (Inertia.Effect.map fn inertiaEffect)
