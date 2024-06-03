module Layouts.Sidebar exposing (view)

import Components.Icon
import Components.Logo
import Html exposing (..)
import Html.Attributes as Attr exposing (attribute, class, href, type_)


view :
    { user : User user account
    , content : List (Html msg)
    }
    -> Html msg
view { user, content } =
    div [ class "md:flex md:flex-col" ]
        [ div [ class "md:flex md:flex-col md:h-screen" ]
            [ viewNavbar { user = user }
            , viewSidebarAndMainContent { content = content }
            ]
        ]


type alias User user account =
    { user
        | first_name : String
        , last_name : String
        , account : { account | name : String }
    }


viewNavbar : { user : User user account } -> Html msg
viewNavbar { user } =
    div
        [ class "md:flex md:shrink-0" ]
        [ div [ class "flex items-center justify-between px-6 py-4 bg-indigo-900 md:shrink-0 md:justify-center md:w-56" ]
            [ a
                [ class "mt-1", href "/" ]
                [ Components.Logo.view
                ]
            , button
                [ type_ "button", class "md:hidden" ]
                [ Components.Icon.hamburger
                ]
            ]
        , div [ class "md:text-md flex items-center justify-between p-4 w-full text-sm bg-white border-b md:px-12 md:py-0" ]
            [ div [ class "mr-4 mt-1" ] [ text user.account.name ]
            , button
                [ type_ "button", class "mt-1" ]
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
    { content : List (Html msg)
    }
    -> Html msg
viewSidebarAndMainContent { content } =
    div
        [ class "md:flex md:grow md:overflow-hidden" ]
        [ div
            [ class
                "hidden shrink-0 p-12 w-56 bg-indigo-800 overflow-y-auto md:block"
            ]
            [ div
                [ class "mb-4" ]
                [ a
                    [ class "group flex items-center py-3", href "/" ]
                    [ Components.Icon.dashboard
                    , div [ class "text-white" ] [ text "Dashboard" ]
                    ]
                ]
            , div
                [ class "mb-4" ]
                [ a
                    [ class "group flex items-center py-3", href "/organizations" ]
                    [ Components.Icon.organizations
                    , div
                        [ class "text-indigo-300 group-hover:text-white" ]
                        [ text "Organizations" ]
                    ]
                ]
            , div
                [ class "mb-4" ]
                [ a
                    [ class "group flex items-center py-3", href "/contacts" ]
                    [ Components.Icon.contacts
                    , div
                        [ class "text-indigo-300 group-hover:text-white" ]
                        [ text "Contacts" ]
                    ]
                ]
            , div
                [ class "mb-4" ]
                [ a
                    [ class "group flex items-center py-3", href "/reports" ]
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
