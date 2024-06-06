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
import Components.Table
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Url
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
    { props : Props
    , table : Components.Table.Model
    , sidebar : Layouts.Sidebar.Model
    }


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { props = props
      , sidebar = Layouts.Sidebar.init { flash = props.flash }
      , table = Components.Table.init ctx
      }
    , Effect.none
    )


onPropsChanged : Context -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged ctx props model =
    ( { model | props = props }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | Table Components.Table.Msg


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg model =
    case msg of
        Sidebar sidebarMsg ->
            Layouts.Sidebar.update
                { msg = sidebarMsg
                , model = model.sidebar
                , toModel = \sidebar -> { model | sidebar = sidebar }
                , toMsg = Sidebar
                }

        Table tableMsg ->
            Components.Table.update
                { msg = tableMsg
                , model = model.table
                , toModel = \table -> { model | table = table }
                , toMsg = Table
                }


subscriptions : Context -> Model -> Sub Msg
subscriptions ctx model =
    Sub.batch
        [ Layouts.Sidebar.subscriptions { model = model.sidebar, toMsg = Sidebar }
        ]



-- VIEW


view : Context -> Model -> Document Msg
view ctx model =
    Layouts.Sidebar.view
        { model = model.sidebar
        , flash = model.props.flash
        , toMsg = Sidebar
        , context = ctx
        , title = "Organizations"
        , user = model.props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Organizations" ]
            , Components.Table.view
                { context = ctx
                , model = model.table
                , toMsg = Table
                , name = "Organization"
                , baseUrl = "organizations"
                , toId = .id
                , columns = columns
                , rows = model.props.organizations
                , lastPage = model.props.lastPage
                }
            ]
        , overlays =
            [ Components.Table.viewOverlay
                { context = ctx
                , model = model.table
                , toMsg = Table
                , baseUrl = "organizations"
                }
            ]
        }


columns : List (Components.Table.Column Organization)
columns =
    [ { name = "Name", toValue = .name }
    , { name = "City", toValue = .city >> Maybe.withDefault "" }
    , { name = "Phone", toValue = .phone >> Maybe.withDefault "" }
    ]
