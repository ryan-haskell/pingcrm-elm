module Pages.Users exposing
    ( Props, decoder
    , Model, init, onPropsChanged
    , Msg, update, subscriptions
    , view
    )

{-|

@docs Props, decoder
@docs Model, init, onPropsChanged
@docs Msg, update, subscriptions
@docs view

-}

import Browser exposing (Document)
import Components.Table.Paginated
import Context exposing (Context)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)
import Json.Decode
import Layouts.Sidebar
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , users : List User
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map3 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "users" (Json.Decode.list userDecoder))


type alias User =
    { id : Int
    , name : String
    , email : String
    , owner : Bool
    , deleted_at : Maybe String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map5 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.field "owner" Json.Decode.bool)
        (Json.Decode.field "deleted_at" (Json.Decode.maybe Json.Decode.string))



-- MODEL


type alias Model =
    { sidebar : Layouts.Sidebar.Model
    , table : Components.Table.Paginated.Model
    }


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { sidebar = Layouts.Sidebar.init { flash = props.flash }
      , table = Components.Table.Paginated.init ctx
      }
    , Effect.none
    )


onPropsChanged : Context -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged ctx props model =
    ( model
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | Table Components.Table.Paginated.Msg


update : Context -> Props -> Msg -> Model -> ( Model, Effect Msg )
update ctx props msg model =
    case msg of
        Sidebar sidebarMsg ->
            Layouts.Sidebar.update
                { msg = sidebarMsg
                , model = model.sidebar
                , toModel = \sidebar -> { model | sidebar = sidebar }
                , toMsg = Sidebar
                }

        Table tableMsg ->
            Components.Table.Paginated.update
                { msg = tableMsg
                , model = model.table
                , toModel = \table -> { model | table = table }
                , toMsg = Table
                }


subscriptions : Context -> Props -> Model -> Sub Msg
subscriptions ctx props model =
    Sub.batch
        [ Layouts.Sidebar.subscriptions { model = model.sidebar, toMsg = Sidebar }
        ]



-- VIEW


view : Context -> Props -> Model -> Document Msg
view ctx props model =
    Layouts.Sidebar.view
        { model = model.sidebar
        , toMsg = Sidebar
        , context = ctx
        , title = "Users"
        , user = props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Users" ]
            , Components.Table.Paginated.view
                { context = ctx
                , model = model.table
                , toMsg = Table
                , name = "User"
                , baseUrl = "users"
                , toId = .id
                , columns = columns
                , rows = props.users
                , lastPage = 1
                }
            ]
        , overlays =
            [ Components.Table.Paginated.viewOverlay
                { context = ctx
                , model = model.table
                , toMsg = Table
                , baseUrl = "users"
                }
            ]
        }


columns : List (Components.Table.Paginated.Column User)
columns =
    [ { name = "Name", toValue = .name }
    , { name = "Email", toValue = .email }
    , { name = "Role"
      , toValue =
            \user ->
                if user.owner then
                    "Owner"

                else
                    "User"
      }
    ]
