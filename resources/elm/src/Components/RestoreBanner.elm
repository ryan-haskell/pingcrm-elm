module Components.RestoreBanner exposing (view)

import Components.Icon
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href)
import Html.Events


view :
    { deletedAt : Maybe String
    , noun : String
    , onClick : msg
    }
    -> Html msg
view props =
    case props.deletedAt of
        Nothing ->
            text ""

        Just _ ->
            div [ class "flex items-center justify-between p-4 max-w-3xl bg-yellow-400 rounded mb-6" ]
                [ div [ class "flex items-center" ]
                    [ Components.Icon.trash
                    , div [ class "text-yellow-800 text-sm font-medium" ]
                        [ text
                            ("This ${noun} has been deleted."
                                |> String.replace "${noun}" props.noun
                            )
                        ]
                    ]
                , button
                    [ class "text-yellow-800 hover:underline text-sm"
                    , Attr.tabindex -1
                    , Attr.type_ "button"
                    , Html.Events.onClick props.onClick
                    ]
                    [ text "Restore" ]
                ]
