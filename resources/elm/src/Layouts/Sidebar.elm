module Layouts.Sidebar exposing
    ( Model, Msg
    , init, update, subscriptions, view
    , withFlash, withFlashHttpError
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

@docs withFlash, withFlashHttpError

-}

import Browser exposing (Document)
import Browser.Events
import Components.Dropdown
import Components.Flash
import Components.Icon
import Components.Logo
import Effect exposing (Effect)
import Extra.Http
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href, type_)
import Html.Events
import Http
import Interop
import Json.Decode
import Json.Encode
import Shared
import Shared.Flash exposing (Flash)
import Url exposing (Url)



-- MODEL


type Model
    = Model Internals


type alias Internals =
    { dropdown : DropdownState
    , flash : Flash
    }


type DropdownState
    = Closed
    | ShowingUserDropdown
    | ShowingHamburgerMenuDropdown


type alias Problem =
    { message : String
    , details : Maybe String
    }


init : { flash : Flash } -> Model
init props =
    Model
        { dropdown = Closed
        , flash = props.flash
        }



-- UPDATE


type Msg
    = ClickedHamburgerMenu
    | ClickedUserDropdown
    | ClickedDismissDropdown
    | ClickedLogout
    | LogoutResponded (Result Http.Error ())
    | DismissedFlash
    | PressedEsc
    | NavigationError { url : String, error : String }


update :
    { msg : Msg
    , model : Model
    , toModel : Model -> model
    , toMsg : Msg -> msg
    }
    -> ( model, Effect msg )
update ({ msg, toModel, toMsg } as args) =
    let
        (Model model) =
            args.model

        return : ( Model, Effect Msg ) -> ( model, Effect msg )
        return tuple =
            Tuple.mapBoth toModel (Effect.map toMsg) tuple
    in
    case msg of
        ClickedHamburgerMenu ->
            return
                ( Model { model | dropdown = ShowingHamburgerMenuDropdown }
                , Effect.none
                )

        ClickedUserDropdown ->
            return
                ( Model { model | dropdown = ShowingUserDropdown }
                , Effect.none
                )

        ClickedDismissDropdown ->
            return
                ( Model { model | dropdown = Closed }
                , Effect.none
                )

        PressedEsc ->
            return
                ( Model { model | dropdown = Closed }
                , Effect.none
                )

        ClickedLogout ->
            return
                ( Model { model | dropdown = Closed }
                , Effect.delete
                    { url = "/logout"
                    , decoder = Json.Decode.succeed ()
                    , onResponse = LogoutResponded
                    }
                )

        LogoutResponded (Ok props) ->
            return
                ( Model model
                , Effect.none
                )

        LogoutResponded (Err httpError) ->
            return
                ( Model
                    { model
                        | flash =
                            { error = Just (Extra.Http.toUserFriendlyMessage httpError)
                            , success = Nothing
                            }
                    }
                , Effect.none
                )

        DismissedFlash ->
            return
                ( Model { model | flash = { error = Nothing, success = Nothing } }
                , Effect.none
                )

        NavigationError { url, error } ->
            return
                ( Model { model | flash = { error = Just error, success = Nothing } }
                , Effect.none
                )



-- SUBSCRIPTIONS


subscriptions : { model : Model, toMsg : Msg -> msg } -> Sub msg
subscriptions props =
    Sub.batch
        [ Browser.Events.onKeyDown onEscDecoder
        , Interop.onNavigationError NavigationError
        ]
        |> Sub.map props.toMsg


onEscDecoder : Json.Decode.Decoder Msg
onEscDecoder =
    Json.Decode.field "key" Json.Decode.string
        |> Json.Decode.andThen
            (\key ->
                if key == "Escape" then
                    Json.Decode.succeed PressedEsc

                else
                    Json.Decode.fail "Other key pressed"
            )



-- VIEW


view :
    { model : Model
    , toMsg : Msg -> msg
    , shared : Shared.Model
    , url : Url
    , title : String
    , user :
        { user
            | first_name : String
            , last_name : String
            , account : { account | name : String }
        }
    , content : List (Html msg)
    , overlays : List (Html msg)
    }
    -> Document msg
view props =
    let
        (Model model) =
            props.model
    in
    { title = props.title ++ " - Ping CRM"
    , body =
        [ div [ class "md:flex md:flex-col" ]
            [ div [ class "md:flex md:flex-col md:h-screen" ]
                [ viewNavbar props
                , viewSidebarAndMainContent props props.model
                ]
            ]
        , viewSidebarDropdowns props props.model
        , div [ class "overlays" ] props.overlays
        ]
    }


viewSidebarDropdowns :
    { props
        | toMsg : Msg -> msg
        , shared : Shared.Model
        , url : Url
    }
    -> Model
    -> Html msg
viewSidebarDropdowns props (Model model) =
    case model.dropdown of
        Closed ->
            text ""

        ShowingUserDropdown ->
            Components.Dropdown.view
                { anchor = Components.Dropdown.TopRight
                , offset =
                    if props.shared.isMobile then
                        ( -16, 104 )

                    else
                        ( -48, 44 )
                , content = viewUserDropdownMenu props
                , onDismiss = props.toMsg ClickedDismissDropdown
                }

        ShowingHamburgerMenuDropdown ->
            Components.Dropdown.view
                { anchor = Components.Dropdown.TopRight
                , offset = ( -24, 44 )
                , content = viewMobileNavMenu props
                , onDismiss = props.toMsg ClickedDismissDropdown
                }


viewMobileNavMenu : { props | url : Url } -> Html msg
viewMobileNavMenu { url } =
    div [ class "mt-2 px-8 py-4 bg-indigo-800 rounded shadow-lg" ] (viewSidebarLinks url)


viewSidebarLinks : Url -> List (Html msg)
viewSidebarLinks url =
    [ viewLink
        { label = "Dashboard"
        , url = "/"
        , icon = Components.Icon.dashboard
        , isActive = "/" == url.path
        }
    , viewLink
        { label = "Organizations"
        , url = "/organizations"
        , icon = Components.Icon.organizations
        , isActive = String.startsWith "/organizations" url.path
        }
    , viewLink
        { label = "Contacts"
        , url = "/contacts"
        , icon = Components.Icon.contacts
        , isActive = String.startsWith "/contacts" url.path
        }
    , viewLink
        { label = "Reports"
        , url = "/reports"
        , icon = Components.Icon.reports
        , isActive = String.startsWith "/reports" url.path
        }
    ]


viewUserDropdownMenu : { props | toMsg : Msg -> msg } -> Html msg
viewUserDropdownMenu props =
    div [ class "mt-2 py-2 text-sm bg-white rounded shadow-xl" ]
        [ a
            [ class "block px-6 py-2 hover:text-white hover:bg-indigo-500"
            , href "/users/1/edit"
            ]
            [ text "My Profile" ]
        , a
            [ class "block px-6 py-2 hover:text-white hover:bg-indigo-500"
            , href "/users"
            ]
            [ text "Manage Users" ]
        , button
            [ class "block px-6 py-2 w-full text-left hover:text-white hover:bg-indigo-500"
            , Html.Events.onClick (props.toMsg ClickedLogout)
            ]
            [ text "Logout" ]
        ]


viewNavbar :
    { props
        | user :
            { user
                | first_name : String
                , last_name : String
                , account : { account | name : String }
            }
        , toMsg : Msg -> msg
    }
    -> Html msg
viewNavbar { user, toMsg } =
    div
        [ class "md:flex md:shrink-0" ]
        [ div [ class "flex items-center justify-between px-6 py-4 bg-indigo-900 md:shrink-0 md:justify-center md:w-56" ]
            [ a [ class "mt-1", href "/" ]
                [ Components.Logo.viewSmall
                ]
            , button
                [ type_ "button"
                , class "md:hidden"
                , Html.Events.onClick (toMsg ClickedHamburgerMenu)
                ]
                [ Components.Icon.hamburger
                ]
            ]
        , div [ class "md:text-md flex items-center justify-between p-4 w-full text-sm bg-white border-b md:px-12 md:py-0" ]
            [ div [ class "mr-4 mt-1" ] [ text user.account.name ]
            , button
                [ type_ "button"
                , class "mt-1"
                , Html.Events.onClick (toMsg ClickedUserDropdown)
                ]
                [ div [ class "group flex items-center cursor-pointer select-none" ]
                    [ div [ class "mr-1 text-gray-700 group-hover:text-indigo-600 focus:text-indigo-600 whitespace-nowrap" ]
                        [ span [] [ text user.first_name ]
                        , span [] [ text " " ]
                        , span [ class "hidden md:inline" ] [ text user.last_name ]
                        ]
                    , Components.Icon.chevronDown
                    ]
                ]
            ]
        ]


viewSidebarAndMainContent :
    { props
        | content : List (Html msg)
        , url : Url
        , toMsg : Msg -> msg
    }
    -> Model
    -> Html msg
viewSidebarAndMainContent { content, url, toMsg } (Model model) =
    div [ class "md:flex md:grow md:overflow-hidden" ]
        [ div [ class "hidden shrink-0 p-12 w-56 bg-indigo-800 overflow-y-auto md:block" ]
            (viewSidebarLinks url)
        , div
            [ class "px-4 py-8 md:flex-1 md:p-12 md:overflow-y-auto"
            , Attr.id "scroll-region"
            ]
            (case model.flash.error of
                Just message ->
                    Components.Flash.viewError
                        { message = message
                        , onDismiss = toMsg DismissedFlash
                        }
                        :: content

                Nothing ->
                    case model.flash.success of
                        Just message ->
                            Components.Flash.viewSuccess
                                { message = message
                                , onDismiss = toMsg DismissedFlash
                                }
                                :: content

                        Nothing ->
                            content
            )
        ]


dismissDropdown : Model -> Model
dismissDropdown (Model model) =
    Model { model | dropdown = Closed }


viewLink :
    { label : String
    , url : String
    , icon : Html msg
    , isActive : Bool
    }
    -> Html msg
viewLink props =
    div [ class "mb-4" ]
        [ a [ class "group flex items-center py-3", href props.url ]
            [ span
                [ Attr.classList
                    [ ( "text-white", props.isActive )
                    , ( "text-indigo-400", not props.isActive )
                    , ( "group-hover:text-white", not props.isActive )
                    ]
                ]
                [ props.icon ]
            , div
                [ Attr.classList
                    [ ( "text-white", props.isActive )
                    , ( "text-indigo-300", not props.isActive )
                    , ( "group-hover:text-white", not props.isActive )
                    ]
                ]
                [ text props.label ]
            ]
        ]



-- FLASH MESSAGES


withFlash : Flash -> Model -> Model
withFlash flash (Model model) =
    Model { model | flash = flash }


withFlashHttpError : Http.Error -> Model -> Model
withFlashHttpError httpError (Model model) =
    Model
        { model
            | flash =
                { success = Nothing
                , error = Just (Extra.Http.toUserFriendlyMessage httpError)
                }
        }
