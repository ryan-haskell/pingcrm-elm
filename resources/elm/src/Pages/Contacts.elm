module Pages.Contacts exposing
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
import Components.Table
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
    { props : Props
    , sidebar : Layouts.Sidebar.Model
    , table : Components.Table.Model
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
        , title = "Contacts"
        , user = model.props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Contacts" ]
            , Components.Table.view
                { context = ctx
                , model = model.table
                , toMsg = Table
                , name = "Contact"
                , baseUrl = "contacts"
                , toId = .id
                , columns = columns
                , rows = model.props.contacts
                , lastPage = model.props.lastPage
                }
            ]
        , overlays =
            [ Components.Table.viewOverlay
                { context = ctx
                , model = model.table
                , toMsg = Table
                , baseUrl = "contacts"
                }
            ]
        }


columns : List (Components.Table.Column Contact)
columns =
    [ { name = "Name", toValue = .name }
    , { name = "Organization", toValue = .organization >> Maybe.withDefault "" }
    , { name = "City", toValue = .city >> Maybe.withDefault "" }
    , { name = "Phone", toValue = .phone >> Maybe.withDefault "" }
    ]
