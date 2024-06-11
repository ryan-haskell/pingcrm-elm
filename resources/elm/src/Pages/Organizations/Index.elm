module Pages.Organizations.Index exposing
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
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Json.Decode
import Layouts.Sidebar
import Shared
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


init : Shared.Model -> Url -> Props -> ( Model, Effect Msg )
init shared url props =
    ( { sidebar = Layouts.Sidebar.init { flash = props.flash }
      , table = Components.Table.Paginated.init url
      }
    , Effect.none
    )


onPropsChanged : Shared.Model -> Url -> Props -> Model -> ( Model, Effect Msg )
onPropsChanged shared url props model =
    ( model
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg
    | Table Components.Table.Paginated.Msg


update : Shared.Model -> Url -> Props -> Msg -> Model -> ( Model, Effect Msg )
update shared url props msg model =
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


subscriptions : Shared.Model -> Url -> Props -> Model -> Sub Msg
subscriptions shared url props model =
    Sub.batch
        [ Layouts.Sidebar.subscriptions { model = model.sidebar, toMsg = Sidebar }
        ]



-- VIEW


view : Shared.Model -> Url -> Props -> Model -> Document Msg
view shared url props model =
    Layouts.Sidebar.view
        { model = model.sidebar
        , toMsg = Sidebar
        , shared = shared
        , url = url
        , title = "Organizations"
        , user = props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Organizations" ]
            , Components.Table.Paginated.view
                { shared = shared
                , url = url
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
                { shared = shared
                , url = url
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
