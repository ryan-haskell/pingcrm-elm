module Layouts.Sidebar exposing (Model, Msg, init, update, view)

import Browser exposing (Document)
import Components.Dropdown
import Components.Icon
import Components.Logo
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href, type_)
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Layouts.Sidebar.Msg exposing (..)



-- MODEL


type Model
    = Model
        { dropdown : DropdownState
        , problem : Maybe Problem
        }


type DropdownState
    = Closed
    | ShowingUserDropdown
    | ShowingHamburgerMenuDropdown


type alias Problem =
    { message : String
    , details : Maybe String
    }


init : Model
init =
    Model
        { dropdown = Closed
        , problem = Nothing
        }



-- UPDATE


{-| This prevents circular dependencies caused by Effect.sendSidebarMsg
-}
type alias Msg =
    Layouts.Sidebar.Msg.Msg


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

        ClickedLogout ->
            return
                ( Model model
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
            -- TODO: Handle logout errors
            return
                ( Model model
                , Effect.none
                )

        ShowProblem { durationInMs, problem } ->
            case durationInMs of
                Nothing ->
                    return
                        ( Model { model | problem = Just problem }
                        , Effect.none
                        )

                Just ms ->
                    if ms <= 0 then
                        return
                            ( Model model, Effect.none )

                    else
                        return
                            ( Model model
                            , Effect.sendDelayedMsg
                                { delay = ms
                                , msg = DismissProblem
                                }
                            )

        DismissProblem ->
            return ( Model { model | problem = Nothing }, Effect.none )



-- VIEW


view :
    { model : Model
    , toMsg : Msg -> msg
    , title : String
    , user : User user account
    , content : List (Html msg)
    }
    -> Document msg
view props =
    let
        (Model model) =
            props.model
    in
    { title = props.title
    , body =
        [ div [ class "md:flex md:flex-col" ]
            [ div [ class "md:flex md:flex-col md:h-screen" ]
                [ viewNavbar props
                , viewSidebarAndMainContent props
                ]
            ]
        , case model.dropdown of
            Closed ->
                text ""

            ShowingUserDropdown ->
                Components.Dropdown.view
                    { anchor = Components.Dropdown.TopRight
                    , offset = ( -48, 44 )
                    , content = viewUserDropdownMenu props
                    , onDismiss = props.toMsg ClickedDismissDropdown
                    }

            ShowingHamburgerMenuDropdown ->
                Components.Dropdown.view
                    { anchor = Components.Dropdown.TopRight
                    , offset = ( -24, 44 )
                    , content = viewMobileNavMenu
                    , onDismiss = props.toMsg ClickedDismissDropdown
                    }
        ]
    }


viewMobileNavMenu : Html msg
viewMobileNavMenu =
    div [ class "mt-2 px-8 py-4 bg-indigo-800 rounded shadow-lg" ]
        [ div [ class "mb-4" ]
            [ a [ class "group flex items-center py-3", href "/" ]
                [ Components.Icon.dashboard
                , div [ class "text-white" ] [ text "Dashboard" ]
                ]
            ]
        , div [ class "mb-4" ]
            [ a [ class "group flex items-center py-3", href "/organizations" ]
                [ Components.Icon.organizations
                , div [ class "text-indigo-300 group-hover:text-white" ]
                    [ text "Organizations" ]
                ]
            ]
        , div [ class "mb-4" ]
            [ a [ class "group flex items-center py-3", href "/contacts" ]
                [ Components.Icon.contacts
                , div [ class "text-indigo-300 group-hover:text-white" ]
                    [ text "Contacts" ]
                ]
            ]
        , div [ class "mb-4" ]
            [ a [ class "group flex items-center py-3", href "/reports" ]
                [ Components.Icon.reports
                , div [ class "text-indigo-300 group-hover:text-white" ]
                    [ text "Reports" ]
                ]
            ]
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


type alias User user account =
    { user
        | first_name : String
        , last_name : String
        , account : { account | name : String }
    }


viewNavbar :
    { props
        | user : User user account
        , toMsg : Msg -> msg
    }
    -> Html msg
viewNavbar { user, toMsg } =
    div
        [ class "md:flex md:shrink-0" ]
        [ div [ class "flex items-center justify-between px-6 py-4 bg-indigo-900 md:shrink-0 md:justify-center md:w-56" ]
            [ a [ class "mt-1", href "/" ]
                [ Components.Logo.view
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
    }
    -> Html msg
viewSidebarAndMainContent { content } =
    div
        [ class "md:flex md:grow md:overflow-hidden" ]
        [ div [ class "hidden shrink-0 p-12 w-56 bg-indigo-800 overflow-y-auto md:block" ]
            [ div [ class "mb-4" ]
                [ a [ class "group flex items-center py-3", href "/" ]
                    [ Components.Icon.dashboard
                    , div [ class "text-white" ] [ text "Dashboard" ]
                    ]
                ]
            , div [ class "mb-4" ]
                [ a [ class "group flex items-center py-3", href "/organizations" ]
                    [ Components.Icon.organizations
                    , div
                        [ class "text-indigo-300 group-hover:text-white" ]
                        [ text "Organizations" ]
                    ]
                ]
            , div [ class "mb-4" ]
                [ a [ class "group flex items-center py-3", href "/contacts" ]
                    [ Components.Icon.contacts
                    , div
                        [ class "text-indigo-300 group-hover:text-white" ]
                        [ text "Contacts" ]
                    ]
                ]
            , div [ class "mb-4" ]
                [ a [ class "group flex items-center py-3", href "/reports" ]
                    [ Components.Icon.reports
                    , div
                        [ class "text-indigo-300 group-hover:text-white" ]
                        [ text "Reports" ]
                    ]
                ]
            ]
        , div
            [ class "px-4 py-8 md:flex-1 md:p-12 md:overflow-y-auto"
            , attribute "scroll-region" ""
            ]
            content
        ]
