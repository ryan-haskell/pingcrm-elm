module Components.Dropdown exposing (Anchor(..), Props, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events


type alias Props msg =
    { anchor : Anchor
    , offset : ( Int, Int )
    , content : Html msg
    , onDismiss : msg
    }


type Anchor
    = TopLeft
    | TopRight


view : Props msg -> Html msg
view props =
    div [ id "dropdown" ]
        [ div
            [ style "position" "fixed"
            , style "inset" "0px"
            , style "z-index" "99998"
            , style "background" "black"
            , style "opacity" "0.2"
            , Html.Events.onClick props.onDismiss
            ]
            []
        , div
            [ style "position" "fixed"
            , style "top" "0"
            , style "left"
                (if props.anchor == TopLeft then
                    "0"

                 else
                    "unset"
                )
            , style "right"
                (if props.anchor == TopRight then
                    "0"

                 else
                    "unset"
                )
            , style "z-index" "99999"
            , style "inset" "0px 0px auto auto"
            , style "margin" "0px"
            , style "transform"
                ("translate(${x}px, ${y}px)"
                    |> String.replace "${x}" (String.fromInt (Tuple.first props.offset))
                    |> String.replace "${y}" (String.fromInt (Tuple.second props.offset))
                )
            , attribute "data-popper-placement" "bottom-end"
            ]
            [ props.content
            ]
        ]
