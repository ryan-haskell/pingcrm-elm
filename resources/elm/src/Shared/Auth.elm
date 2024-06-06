module Shared.Auth exposing
    ( Auth, decoder
    , User, Account
    )

{-|

@docs Auth, decoder
@docs User, Account

-}

import Json.Decode


type alias Auth =
    { user : User
    }


decoder : Json.Decode.Decoder Auth
decoder =
    Json.Decode.map Auth
        (Json.Decode.field "user" userDecoder)



-- User


type alias User =
    { id : Int
    , email : String
    , first_name : String
    , last_name : String
    , owner : Bool
    , account : Account
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map6 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.field "first_name" Json.Decode.string)
        (Json.Decode.field "last_name" Json.Decode.string)
        (Json.Decode.field "owner" Json.Decode.bool)
        (Json.Decode.field "account" accountDecoder)



-- ACCOUNT


type alias Account =
    { id : Int
    , name : String
    }


accountDecoder : Json.Decode.Decoder Account
accountDecoder =
    Json.Decode.map2 Account
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
