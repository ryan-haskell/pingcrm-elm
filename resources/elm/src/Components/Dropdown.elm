module Components.Dropdown exposing (Anchor(..), Props, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events


type alias Props msg =
    { anchor : Anchor
    , offset : ( Int, Int )
    , onDismiss : msg
    , content : Html msg
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
            , if props.anchor == TopLeft then
                style "left" "0"

              else
                classList []
            , if props.anchor == TopRight then
                style "right" "0"

              else
                classList []
            , style "z-index" "99999"
            , style "margin" "0px"
            , style "transform"
                ("translate(${x}px, ${y}px)"
                    |> String.replace "${x}" (String.fromInt (Tuple.first props.offset))
                    |> String.replace "${y}" (String.fromInt (Tuple.second props.offset))
                )
            ]
            [ props.content
            ]
        ]
