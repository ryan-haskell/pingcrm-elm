module Pages.Organizations exposing
    ( Props, decoder
    , Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Props, decoder
@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Browser exposing (Document)
import Components.Icon
import Components.Table
import Context exposing (Context)
import Domain.Auth exposing (Auth)
import Domain.Flash exposing (Flash)
import Domain.Organization exposing (Organization)
import Effect exposing (Effect)
import Extra.Url
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href)
import Html.Events
import Json.Decode
import Layouts.Sidebar
import Url exposing (Url)



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
        (Json.Decode.field "auth" Domain.Auth.decoder)
        (Json.Decode.field "flash" Domain.Flash.decoder)
        (Json.Decode.field "organizations" (Json.Decode.field "data" (Json.Decode.list Domain.Organization.decoder)))
        (Json.Decode.at [ "organizations", "last_page" ] Json.Decode.int)



-- MODEL


type alias Model =
    { props : Props
    }


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { props = props
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Sidebar Layouts.Sidebar.Msg


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg model =
    case msg of
        Sidebar sidebarMsg ->
            ( model, Effect.sendSidebarMsg sidebarMsg )


subscriptions : Context -> Model -> Sub Msg
subscriptions ctx model =
    Sub.none



-- VIEW


view : Context -> Model -> Document Msg
view ctx model =
    Layouts.Sidebar.view
        { model = ctx.sidebar
        , flash = model.props.flash
        , toMsg = Sidebar
        , url = ctx.url
        , title = "Organizations"
        , user = model.props.auth.user
        , content =
            [ h1 [ class "mb-8 text-3xl font-bold" ] [ text "Organizations" ]
            , Components.Table.view
                { context = ctx
                , name = "Organization"
                , baseUrl = "/organizations"
                , toId = .id
                , columns = columns
                , rows = model.props.organizations
                , lastPage = model.props.lastPage
                }
            ]
        }


columns : List (Components.Table.Column Organization)
columns =
    [ { name = "Name", toValue = .name }
    , { name = "City", toValue = .city >> Maybe.withDefault "" }
    , { name = "Phone", toValue = .phone >> Maybe.withDefault "" }
    ]
