module Page.Contacts.Index exposing
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
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)
import Json.Decode
import Layouts.Sidebar
import Shared
import Shared.Auth exposing (Auth)
import Shared.Flash exposing (Flash)
import Url exposing (Url)



-- PROPS


type alias Props =
    { auth : Auth
    , flash : Flash
    , contacts : List Contact
    , lastPage : Int
    }


decoder : Json.Decode.Decoder Props
decoder =
    Json.Decode.map4 Props
        (Json.Decode.field "auth" Shared.Auth.decoder)
        (Json.Decode.field "flash" Shared.Flash.decoder)
        (Json.Decode.field "contacts" (Json.Decode.field "data" (Json.Decode.list contactDecoder)))
        (Json.Decode.at [ "contacts", "last_page" ] Json.Decode.int)


type alias Contact =
    { id : Int
    , name : String
    , organization : Maybe String
    , city : Maybe String
    , phone : Maybe String
    , deletedAt : Maybe String
    }


contactDecoder : Json.Decode.Decoder Contact
contactDecoder =
    Json.Decode.map6 Contact
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "organization" (Json.Decode.maybe (Json.Decode.field "name" Json.Decode.string)))
        (Json.Decode.field "city" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "phone" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "deleted_at" (Json.Decode.maybe Json.Decode.string))



-- MODEL


type alias Model =
    { sidebar : Layouts.Sidebar.Model
    , table : Components.Table.Paginated.Model
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
        , title = "Contacts"
        , user = props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Contacts" ]
            , Components.Table.Paginated.view
                { shared = shared
                , url = url
                , model = model.table
                , toMsg = Table
                , name = "Contact"
                , baseUrl = "contacts"
                , toId = .id
                , columns = columns
                , rows = props.contacts
                , lastPage = props.lastPage
                }
            ]
        , overlays =
            [ Components.Table.Paginated.viewOverlay
                { shared = shared
                , url = url
                , model = model.table
                , toMsg = Table
                , baseUrl = "contacts"
                }
            ]
        }


columns : List (Components.Table.Paginated.Column Contact)
columns =
    [ { name = "Name", toValue = .name }
    , { name = "Organization", toValue = .organization >> Maybe.withDefault "" }
    , { name = "City", toValue = .city >> Maybe.withDefault "" }
    , { name = "Phone", toValue = .phone >> Maybe.withDefault "" }
    ]
