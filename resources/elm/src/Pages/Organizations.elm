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
            , viewTableFilters model
            , viewTable model
            , viewTableFooter ctx model
            ]
        }


viewTableFilters : Model -> Html Msg
viewTableFilters model =
    div
        [ class "flex items-center justify-between mb-6" ]
        [ div
            [ class "flex items-center mr-4 w-full max-w-md" ]
            [ div
                [ class "flex w-full bg-white rounded shadow" ]
                [ button
                    [ Attr.type_ "button"
                    , class
                        "focus:z-10 px-4 hover:bg-gray-100 border-r focus:border-white rounded-l focus:ring md:px-6"
                    ]
                    [ div
                        [ class "flex items-baseline" ]
                        [ span
                            [ class "hidden text-gray-700 md:inline" ]
                            [ text "Filter" ]
                        , Components.Icon.arrowDown
                        ]
                    ]
                , input
                    [ class
                        "relative px-6 py-3 w-full rounded-r focus:shadow-outline"
                    , Attr.autocomplete False
                    , Attr.type_ "text"
                    , Attr.name "search"
                    , Attr.placeholder "Search…"
                    ]
                    []
                ]
            , button
                [ class
                    "ml-3 text-gray-500 hover:text-gray-700 focus:text-indigo-500 text-sm"
                , Attr.type_ "button"
                ]
                [ text "Reset" ]
            ]
        , a
            [ class "btn-indigo", href "/organizations/create" ]
            [ span [] [ text "Create" ]
            , text " "
            , span [ class "hidden md:inline" ] [ text "Organization" ]
            ]
        ]


viewTable : Model -> Html Msg
viewTable model =
    div
        [ class "bg-white rounded-md shadow overflow-x-auto" ]
        [ table
            [ class "w-full whitespace-nowrap" ]
            [ thead []
                [ tr
                    [ class "text-left font-bold" ]
                    [ th [ class "pb-4 pt-6 px-6" ] [ text "Name" ]
                    , th [ class "pb-4 pt-6 px-6" ] [ text "City" ]
                    , th [ class "pb-4 pt-6 px-6", Attr.colspan 2 ] [ text "Phone" ]
                    ]
                ]
            , tbody [] (List.map viewTableRow model.props.organizations)
            ]
        ]


viewTableRow : Organization -> Html Msg
viewTableRow org =
    let
        editUrl : String
        editUrl =
            "/organizations/" ++ String.fromInt org.id ++ "/edit"
    in
    tr [ class "hover:bg-gray-100 focus-within:bg-gray-100" ]
        [ td [ class "border-t" ]
            [ a
                [ class "flex items-center px-6 py-4 focus:text-indigo-500"
                , href editUrl
                ]
                [ text org.name ]
            ]
        , td [ class "border-t" ]
            [ a
                [ class "flex items-center px-6 py-4"
                , Attr.tabindex -1
                , href editUrl
                ]
                [ text (org.city |> Maybe.withDefault "") ]
            ]
        , td [ class "border-t" ]
            [ a
                [ class "flex items-center px-6 py-4"
                , Attr.tabindex -1
                , href editUrl
                ]
                [ text (org.phone |> Maybe.withDefault "") ]
            ]
        , td [ class "w-px border-t" ]
            [ a
                [ class "flex items-center px-4"
                , Attr.tabindex -1
                , href editUrl
                ]
                [ Components.Icon.chevronRight ]
            ]
        ]


viewTableFooter : Context -> Model -> Html Msg
viewTableFooter { url } model =
    let
        currentPage : Int
        currentPage =
            Extra.Url.getQueryParameter "page" url
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 1

        viewPreviousLink : Html Msg
        viewPreviousLink =
            viewLink
                { label = "« Previous"
                , isDisabled = currentPage == 1
                , url = "/organizations?page=" ++ String.fromInt (currentPage - 1)
                }

        viewNextLink : Html Msg
        viewNextLink =
            viewLink
                { label = "Next »"
                , isDisabled = currentPage == model.props.lastPage
                , url = "/organizations?page=" ++ String.fromInt (currentPage + 1)
                }

        viewPageNumberLink : String -> Html Msg
        viewPageNumberLink num =
            a
                [ class "mb-1 mr-1 px-4 py-3 focus:text-indigo-500 text-sm leading-4 hover:bg-white border focus:border-indigo-500 rounded"
                , Attr.classList
                    [ ( "bg-white", String.fromInt currentPage == num )
                    ]
                , href ("/organizations?page=" ++ num)
                ]
                [ text num ]

        viewLink : { label : String, isDisabled : Bool, url : String } -> Html Msg
        viewLink props =
            if props.isDisabled then
                div [ class "mb-1 mr-1 px-4 py-3 text-gray-400 text-sm leading-4 border rounded" ] [ text props.label ]

            else
                a
                    [ class "mb-1 mr-1 px-4 py-3 focus:text-indigo-500 text-sm leading-4 hover:bg-white border focus:border-indigo-500 rounded"
                    , href props.url
                    ]
                    [ text props.label ]
    in
    div [ class "mt-6" ]
        [ div [ class "flex flex-wrap -mb-1" ]
            [ viewPreviousLink
            , viewPageNumberLink "1"
            , viewPageNumberLink "2"
            , viewPageNumberLink "3"
            , viewPageNumberLink "4"
            , viewPageNumberLink "5"
            , viewPageNumberLink "6"
            , viewPageNumberLink "7"
            , viewPageNumberLink "8"
            , viewPageNumberLink "9"
            , viewPageNumberLink "10"
            , viewNextLink
            ]
        ]
