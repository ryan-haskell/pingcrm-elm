module Components.Flash exposing
    ( viewDismissableError
    , viewError
    , viewSuccess
    )

import Components.Icon
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events


viewSuccess : { message : String } -> Html msg
viewSuccess props =
    div [ class "flex items-center justify-between mb-8 max-w-3xl bg-green-500 rounded" ]
        [ div [ class "flex items-center" ]
            [ Components.Icon.check
            , div
                [ class "py-4 text-white text-sm font-medium" ]
                [ text props.message ]
            ]
        ]


viewError : { message : String } -> Html msg
viewError props =
    div [ class "flex items-center justify-between mb-8 max-w-3xl bg-red-500 rounded" ]
        [ div [ class "flex items-center" ]
            [ Components.Icon.closeCircle
            , div [ class "py-4 text-white text-sm font-medium" ]
                [ text props.message
                ]
            ]
        ]


viewDismissableError : { message : String, onDismiss : msg } -> Html msg
viewDismissableError props =
    div [ class "flex items-center justify-between mb-8 max-w-3xl bg-red-500 rounded" ]
        [ div [ class "flex items-center" ]
            [ Components.Icon.closeCircle
            , div [ class "py-4 text-white text-sm font-medium" ]
                [ text props.message
                ]
            ]
        , button
            [ type_ "button"
            , class "group mr-2 p-2"
            , Html.Events.onClick props.onDismiss
            ]
            [ span [ class "text-red-800 group-hover:text-white" ] [ Components.Icon.close ]
            ]
        ]
