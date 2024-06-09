module Components.Table exposing (Column, view)

{-|

@docs Column, view

-}

import Components.Icon
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, style)
import Html.Events
import Shared
import Url exposing (Url)
import Url.Builder


type alias Column data =
    { name : String
    , toValue : data -> String
    }


type alias Props data =
    { baseUrl : String
    , toId : data -> Int
    , rows : List data
    , columns : List (Column data)
    , noResultsLabel : String
    }


view : Props data -> Html msg
view props =
    div [ class "bg-white rounded-md shadow overflow-x-auto" ]
        [ table
            [ class "w-full whitespace-nowrap" ]
            [ thead [] [ viewTableHeaderRow props ]
            , tbody []
                (if List.isEmpty props.rows then
                    [ tr [] <|
                        List.concat
                            [ [ td [ class "border-t" ]
                                    [ span [ class "flex items-center px-6 py-4 focus:text-indigo-500" ] [ text props.noResultsLabel ] ]
                              ]
                            , List.repeat
                                (List.length props.columns - 1)
                                (td [ class "border-t" ] [])
                            ]
                    ]

                 else
                    List.map (viewTableBodyRow props) props.rows
                )
            ]
        ]


viewTableHeaderRow : Props data -> Html msg
viewTableHeaderRow props =
    let
        lastColumnIndex : Int
        lastColumnIndex =
            List.length props.columns - 1

        viewCell : Int -> String -> Html msg
        viewCell index name =
            th
                [ class "pb-4 pt-6 px-6"
                , Attr.colspan
                    (if index == lastColumnIndex then
                        2

                     else
                        1
                    )
                ]
                [ text name ]
    in
    tr [ class "text-left font-bold" ]
        (List.indexedMap viewCell (List.map .name props.columns))


viewTableBodyRow : Props data -> data -> Html msg
viewTableBodyRow props data =
    let
        editUrl : String
        editUrl =
            Url.Builder.absolute
                [ props.baseUrl
                , String.fromInt (props.toId data)
                , "edit"
                ]
                []

        viewCell : Int -> (data -> String) -> Html msg
        viewCell index toValue =
            if index == 0 then
                viewFirstCell toValue

            else
                viewOtherCell toValue

        viewFirstCell : (data -> String) -> Html msg
        viewFirstCell toValue =
            td [ class "border-t" ]
                [ a
                    [ class "flex items-center px-6 py-4 focus:text-indigo-500"
                    , href editUrl
                    ]
                    [ text (toValue data) ]
                ]

        viewOtherCell : (data -> String) -> Html msg
        viewOtherCell toValue =
            td [ class "border-t" ]
                [ a
                    [ class "flex items-center px-6 py-4"
                    , Attr.tabindex -1
                    , href editUrl
                    ]
                    [ text (toValue data) ]
                ]

        viewLastCell : Html msg
        viewLastCell =
            td [ class "w-px border-t" ]
                [ a
                    [ class "flex items-center px-4"
                    , Attr.tabindex -1
                    , href editUrl
                    ]
                    [ Components.Icon.chevronRight ]
                ]
    in
    tr [ class "hover:bg-gray-100 focus-within:bg-gray-100" ]
        ((props.columns
            |> List.map .toValue
            |> List.indexedMap viewCell
         )
            ++ [ viewLastCell
               ]
        )
