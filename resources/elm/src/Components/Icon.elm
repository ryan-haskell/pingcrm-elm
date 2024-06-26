module Components.Icon exposing
    ( arrowDown
    , check
    , chevronDown
    , chevronRight
    , close
    , closeCircle
    , contacts
    , dashboard
    , hamburger
    , organizations
    , reports
    , trash
    )

import Html.Attributes as Attr
import Svg exposing (..)
import Svg.Attributes exposing (..)


dashboard : Svg msg
dashboard =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        , class "mr-2 w-4 h-4"
        , Attr.style "fill" "currentColor"
        ]
        [ Svg.path
            [ d "M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm-5.6-4.29a9.95 9.95 0 0 1 11.2 0 8 8 0 1 0-11.2 0zm6.12-7.64l3.02-3.02 1.41 1.41-3.02 3.02a2 2 0 1 1-1.41-1.41z"
            ]
            []
        ]


organizations : Svg msg
organizations =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , width "100"
        , height "100"
        , viewBox "0 0 100 100"
        , class "mr-2 w-4 h-4"
        , Attr.style "fill" "currentColor"
        ]
        [ Svg.path
            [ fillRule "evenodd"
            , d "M7 0h86v100H57.108V88.418H42.892V100H7V0zm9 64h11v15H16V64zm57 0h11v15H73V64zm-19 0h11v15H54V64zm-19 0h11v15H35V64zM16 37h11v15H16V37zm57 0h11v15H73V37zm-19 0h11v15H54V37zm-19 0h11v15H35V37zM16 11h11v15H16V11zm57 0h11v15H73V11zm-19 0h11v15H54V11zm-19 0h11v15H35V11z"
            ]
            []
        ]


contacts : Svg msg
contacts =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        , class "mr-2 w-4 h-4"
        , Attr.style "fill" "currentColor"
        ]
        [ Svg.path
            [ d "M7 8a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm0 1c2.15 0 4.2.4 6.1 1.09L12 16h-1.25L10 20H4l-.75-4H2L.9 10.09A17.93 17.93 0 0 1 7 9zm8.31.17c1.32.18 2.59.48 3.8.92L18 16h-1.25L16 20h-3.96l.37-2h1.25l1.65-8.83zM13 0a4 4 0 1 1-1.33 7.76 5.96 5.96 0 0 0 0-7.52C12.1.1 12.53 0 13 0z" ]
            []
        ]


reports : Svg msg
reports =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        , class "mr-2 w-4 h-4"
        , Attr.style "fill" "currentColor"
        ]
        [ Svg.path
            [ d "M4 16H0V6h20v10h-4v4H4v-4zm2-4v6h8v-6H6zM4 0h12v5H4V0zM2 8v2h2V8H2zm4 0v2h2V8H6z" ]
            []
        ]


hamburger : Svg msg
hamburger =
    svg
        [ class "w-6 h-6 fill-white"
        , xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        ]
        [ Svg.path
            [ d "M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" ]
            []
        ]


chevronDown : Svg msg
chevronDown =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        , class "w-5 h-5 fill-gray-700 group-hover:fill-indigo-600 focus:fill-indigo-600"
        ]
        [ Svg.path
            [ d "M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" ]
            []
        ]


close : Svg msg
close =
    svg
        [ class "block w-2 h-2 fill-green-800 group-hover:fill-white"
        , xmlSpace "http://www.w3.org/2000/svg"
        , width "235.908"
        , height "235.908"
        , viewBox "278.046 126.846 235.908 235.908"
        ]
        [ Svg.path
            [ d
                "M506.784 134.017c-9.56-9.56-25.06-9.56-34.62 0L396 210.18l-76.164-76.164c-9.56-9.56-25.06-9.56-34.62 0-9.56 9.56-9.56 25.06 0 34.62L361.38 244.8l-76.164 76.165c-9.56 9.56-9.56 25.06 0 34.62 9.56 9.56 25.06 9.56 34.62 0L396 279.42l76.164 76.165c9.56 9.56 25.06 9.56 34.62 0 9.56-9.56 9.56-25.06 0-34.62L430.62 244.8l76.164-76.163c9.56-9.56 9.56-25.06 0-34.62z"
            ]
            []
        ]


check : Svg msg
check =
    svg
        [ class "shrink-0 ml-4 mr-2 w-4 h-4 fill-white"
        , xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        ]
        [ polygon [ points "0 11 2 9 7 14 18 3 20 5 7 18" ] []
        ]


closeCircle : Svg msg
closeCircle =
    svg
        [ class "shrink-0 ml-4 mr-2 w-4 h-4 fill-white"
        , xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        ]
        [ Svg.path
            [ d
                "M2.93 17.07A10 10 0 1 1 17.07 2.93 10 10 0 0 1 2.93 17.07zm1.41-1.41A8 8 0 1 0 15.66 4.34 8 8 0 0 0 4.34 15.66zm9.9-8.49L11.41 10l2.83 2.83-1.41 1.41L10 11.41l-2.83 2.83-1.41-1.41L8.59 10 5.76 7.17l1.41-1.41L10 8.59l2.83-2.83 1.41 1.41z"
            ]
            []
        ]


arrowDown : Svg msg
arrowDown =
    svg
        [ class "w-2 h-2 fill-gray-700 md:ml-2"
        , xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 961.243 599.998"
        ]
        [ Svg.path [ d "M239.998 239.999L0 0h961.243L721.246 240c-131.999 132-240.28 240-240.624 239.999-.345-.001-108.625-108.001-240.624-240z" ] []
        ]


chevronRight : Svg msg
chevronRight =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        , class "block w-6 h-6 fill-gray-400"
        ]
        [ polygon
            [ points
                "12.95 10.707 13.657 10 8 4.343 6.586 5.757 10.828 10 6.586 14.243 8 15.657 12.95 10.707"
            ]
            []
        ]


trash : Svg msg
trash =
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , viewBox "0 0 20 20"
        , class "shrink-0 mr-2 w-4 h-4 fill-yellow-800"
        ]
        [ Svg.path [ d "M6 2l2-2h4l2 2h4v2H2V2h4zM3 6h14l-1 14H4L3 6zm5 2v10h1V8H8zm3 0v10h1V8h-1z" ] []
        ]
