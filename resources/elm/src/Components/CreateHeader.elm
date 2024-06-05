module Components.CreateHeader exposing (view)

import Html exposing (..)
import Html.Attributes as Attr exposing (class, href)


view : { label : String, url : String } -> Html msg
view props =
    h1 [ class "mb-8 text-3xl font-bold" ]
        [ a [ class "text-indigo-400 hover:text-indigo-600", href props.url ] [ text props.label ]
        , span [ class "text-indigo-400 font-medium" ] [ text " / " ]
        , text "Create"
        ]
