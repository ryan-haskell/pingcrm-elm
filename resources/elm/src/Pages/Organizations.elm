module Pages.Organizations exposing
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
import Components.Dropdown
import Components.Icon
import Components.Table.Paginated
import Context exposing (Context)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Json.Decode
import Layouts.Sidebar
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)
import Url exposing (Url)
import Url.Builder



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , organizations : List Organization
    , lastPage : Int
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map4 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "organizations" (Json.Decode.field "data" (Json.Decode.list organizationDecoder)))
        (Json.Decode.at [ "organizations", "last_page" ] Json.Decode.int)



-- Organization


type alias Organization =
    { id : Int
    , name : String
    , city : Maybe String
    , phone : Maybe String
    , deletedAt : Maybe String
    }


organizationDecoder : Json.Decode.Decoder Organization
organizationDecoder =
    Json.Decode.map5 Organization
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "city" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "phone" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "deleted_at" (Json.Decode.maybe Json.Decode.string))



-- MODEL


type alias Model =
    { table : Components.Table.Paginated.Model
    , sidebar : Layouts.Sidebar.Model
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
        , title = "Organizations"
        , user = props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Organizations" ]
            , Components.Table.Paginated.view
                { context = ctx
                , model = model.table
                , toMsg = Table
                , name = "Organization"
                , baseUrl = "organizations"
                , toId = .id
                , columns = columns
                , rows = props.organizations
                , lastPage = props.lastPage
                }
            ]
        , overlays =
            [ Components.Table.Paginated.viewOverlay
                { context = ctx
                , model = model.table
                , toMsg = Table
                , baseUrl = "organizations"
                }
            ]
        }


columns : List (Components.Table.Paginated.Column Organization)
columns =
    [ { name = "Name", toValue = .name }
    , { name = "City", toValue = .city >> Maybe.withDefault "" }
    , { name = "Phone", toValue = .phone >> Maybe.withDefault "" }
    ]
