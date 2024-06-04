module Components.Table exposing
    ( Props
    , Model, init
    , Msg, update
    , view
    , Column
    )

{-|

@docs Props

@docs Model, init
@docs Msg, update
@docs view

@docs Column

-}

import Components.Icon
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Url
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, style)
import Html.Events



-- PROPS


type alias Props data msg =
    { context : Context
    , name : String
    , baseUrl : String
    , toId : data -> Int
    , columns : List (Column data)
    , rows : List data
    , lastPage : Int
    , toMsg : Msg -> msg
    }


type alias Column data =
    { name : String, toValue : data -> String }



-- MODEL


type Model
    = Model
        { search : String
        }


init : Model
init =
    Model { search = "" }



-- UPDATE


type Msg
    = ChangedSearch String
    | ClickedReset String
    | OpenedFilterDropdown


update :
    { msg : Msg
    , model : Model
    , toModel : Model -> model
    , toMsg : Msg -> msg
    , onSearchChanged : String -> msg
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
        ChangedSearch search ->
            ( Model { model | search = search }
                |> toModel
            , args.onSearchChanged search
                |> Effect.sendMsg
            )

        ClickedReset baseUrl ->
            return
                ( Model model
                , Effect.pushUrl baseUrl
                )

        OpenedFilterDropdown ->
            -- TODO
            return
                ( Model model
                , Effect.none
                )



-- VIEW


view : Props data msg -> Model -> Html msg
view props model =
    div []
        [ viewTableFilters props model
        , viewTableData props
        , viewTableFooter props
        ]


viewTableFilters : Props data msg -> Model -> Html msg
viewTableFilters props (Model model) =
    div [ class "flex items-center justify-between mb-6" ]
        [ div [ class "flex items-center mr-4 w-full max-w-md" ]
            [ div [ class "flex w-full bg-white rounded shadow" ]
                [ button
                    [ Attr.type_ "button"
                    , class "focus:z-10 px-4 hover:bg-gray-100 border-r focus:border-white rounded-l focus:ring md:px-6"
                    ]
                    [ div [ class "flex items-baseline" ]
                        [ span [ class "hidden text-gray-700 md:inline" ]
                            [ text "Filter" ]
                        , Components.Icon.arrowDown
                        ]
                    ]
                , input
                    [ class "relative px-6 py-3 w-full rounded-r focus:shadow-outline"
                    , Attr.autocomplete False
                    , Attr.type_ "text"
                    , Attr.name "search"
                    , Attr.placeholder "Search…"
                    , Html.Events.onInput (ChangedSearch >> props.toMsg)
                    , Attr.value model.search
                    ]
                    []
                ]
            , button
                [ class "ml-3 text-gray-500 hover:text-gray-700 focus:text-indigo-500 text-sm"
                , Attr.type_ "button"
                , Html.Events.onClick (props.toMsg (ClickedReset props.baseUrl))
                ]
                [ text "Reset" ]
            ]
        , a [ class "btn-indigo", href (props.baseUrl ++ "/create") ]
            [ span [] [ text "Create" ]
            , text " "
            , span [ class "hidden md:inline" ] [ text props.name ]
            ]
        ]


viewTableData : Props data msg -> Html msg
viewTableData props =
    div [ class "bg-white rounded-md shadow overflow-x-auto" ]
        [ table
            [ class "w-full whitespace-nowrap" ]
            [ thead [] [ viewTableHeaderRow props ]
            , tbody [] (List.map (viewTableBodyRow props) props.rows)
            ]
        ]


viewTableHeaderRow : Props data msg -> Html msg
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


viewTableBodyRow : Props data msg -> data -> Html msg
viewTableBodyRow props data =
    let
        editUrl : String
        editUrl =
            props.baseUrl ++ "/" ++ String.fromInt (props.toId data) ++ "/edit"

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
    in
    tr [ class "hover:bg-gray-100 focus-within:bg-gray-100" ]
        ((props.columns
            |> List.map .toValue
            |> List.indexedMap viewCell
         )
            ++ [ td [ class "w-px border-t" ]
                    [ a
                        [ class "flex items-center px-4"
                        , Attr.tabindex -1
                        , href editUrl
                        ]
                        [ Components.Icon.chevronRight ]
                    ]
               ]
        )


viewTableFooter : Props data msg -> Html msg
viewTableFooter props =
    let
        currentPage : Int
        currentPage =
            Extra.Url.getQueryParameter "page" props.context.url
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 1

        viewPreviousLink : Html msg
        viewPreviousLink =
            viewLink
                { label = "« Previous"
                , isDisabled = currentPage == 1
                , url = props.baseUrl ++ "?page=" ++ String.fromInt (currentPage - 1)
                }

        viewNextLink : Html msg
        viewNextLink =
            viewLink
                { label = "Next »"
                , isDisabled = currentPage == props.lastPage
                , url = props.baseUrl ++ "?page=" ++ String.fromInt (currentPage + 1)
                }

        viewPageNumberLink : Int -> Html msg
        viewPageNumberLink num =
            a
                [ class "mb-1 mr-1 px-4 py-3 focus:text-indigo-500 text-sm leading-4 hover:bg-white border focus:border-indigo-500 rounded"
                , Attr.classList [ ( "bg-white", currentPage == num ) ]
                , href (props.baseUrl ++ "?page=" ++ String.fromInt num)
                ]
                [ text (String.fromInt num) ]

        viewLink :
            { label : String
            , isDisabled : Bool
            , url : String
            }
            -> Html msg
        viewLink link =
            if link.isDisabled then
                div [ class "mb-1 mr-1 px-4 py-3 text-gray-400 text-sm leading-4 border rounded" ] [ text link.label ]

            else
                a
                    [ class "mb-1 mr-1 px-4 py-3 focus:text-indigo-500 text-sm leading-4 hover:bg-white border focus:border-indigo-500 rounded"
                    , href link.url
                    ]
                    [ text link.label ]
    in
    div [ class "mt-6" ]
        [ div [ class "flex flex-wrap -mb-1" ]
            (List.concat
                [ [ viewPreviousLink ]
                , List.range 1 10 |> List.map viewPageNumberLink
                , [ viewNextLink ]
                ]
            )
        ]
