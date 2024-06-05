module Components.Table exposing
    ( Model, init
    , Msg, update
    , view, viewOverlay
    , Column
    )

{-|

@docs Model, init
@docs Msg, update
@docs view, viewOverlay

@docs Column

-}

import Components.Dropdown
import Components.Icon
import Context exposing (Context)
import Effect exposing (Effect)
import Extra.Url
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, style)
import Html.Events
import Url.Builder



-- MODEL


type Model
    = Model
        { search : String
        , trashed : String
        , isFilterDropdownOpen : Bool
        }


init : Context -> Model
init { url } =
    Model
        { search = Extra.Url.getQueryParameter "search" url |> Maybe.withDefault ""
        , trashed = Extra.Url.getQueryParameter "trashed" url |> Maybe.withDefault ""
        , isFilterDropdownOpen = False
        }



-- UPDATE


type Msg
    = ChangedSearchFilter String String
    | ChangedTrashFilter String String
    | ClickedReset String
    | OpenedFilterDropdown
    | DismissedFilterDropdownMenu


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

        returnFilterChanged : String -> Model -> ( model, Effect msg )
        returnFilterChanged baseUrl newModel =
            ( toModel newModel
            , Effect.pushUrl (toFilterUrl baseUrl newModel)
            )
    in
    case msg of
        ChangedSearchFilter baseUrl value ->
            Model { model | search = value }
                |> returnFilterChanged baseUrl

        ChangedTrashFilter baseUrl value ->
            Model { model | trashed = value }
                |> returnFilterChanged baseUrl

        ClickedReset baseUrl ->
            return
                ( Model { model | search = "", trashed = "" }
                , Effect.pushUrl (Url.Builder.absolute [ baseUrl ] [])
                )

        OpenedFilterDropdown ->
            return
                ( Model { model | isFilterDropdownOpen = True }
                , Effect.none
                )

        DismissedFilterDropdownMenu ->
            return
                ( Model { model | isFilterDropdownOpen = False }
                , Effect.none
                )


isBlank : String -> Bool
isBlank str =
    String.isEmpty (String.trim str)


toFilterUrl : String -> Model -> String
toFilterUrl baseUrl (Model model) =
    Url.Builder.absolute [ baseUrl ] (toFilterQueryParameters (Model model))


toFilterQueryParameters : Model -> List Url.Builder.QueryParameter
toFilterQueryParameters (Model model) =
    List.concat
        [ if isBlank model.search then
            []

          else
            [ Url.Builder.string "search" model.search ]
        , if isBlank model.trashed then
            []

          else
            [ Url.Builder.string "trashed" model.trashed ]
        ]



-- VIEW


view :
    { context : Context
    , model : Model
    , toMsg : Msg -> msg
    , name : String
    , baseUrl : String
    , toId : data -> Int
    , columns : List (Column data)
    , rows : List data
    , lastPage : Int
    }
    -> Html msg
view props =
    div []
        [ viewTableFilters props
        , viewTableData props
        , viewTableFooter props
        ]


type alias Props data msg =
    { context : Context
    , model : Model
    , toMsg : Msg -> msg
    , name : String
    , baseUrl : String
    , toId : data -> Int
    , columns : List (Column data)
    , rows : List data
    , lastPage : Int
    }


type alias Column data =
    { name : String
    , toValue : data -> String
    }


viewTableFilters : Props data msg -> Html msg
viewTableFilters props =
    let
        (Model model) =
            props.model
    in
    div [ class "flex items-center justify-between mb-6" ]
        [ div [ class "flex items-center mr-4 w-full max-w-md" ]
            [ div [ class "flex w-full bg-white rounded shadow" ]
                [ button
                    [ Attr.type_ "button"
                    , class "focus:z-10 px-4 hover:bg-gray-100 border-r focus:border-white rounded-l focus:ring md:px-6"
                    , Html.Events.onClick (props.toMsg OpenedFilterDropdown)
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
                    , Html.Events.onInput (ChangedSearchFilter props.baseUrl >> props.toMsg)
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
        , a
            [ class "btn-indigo"
            , href (Url.Builder.absolute [ props.baseUrl, "create" ] [])
            ]
            [ span [] [ text "Create" ]
            , text " "
            , span [ class "hidden md:inline" ] [ text props.name ]
            ]
        ]


viewTableData : Props data msg -> Html msg
viewTableData props =
    if List.isEmpty props.rows then
        p [ class "py-3" ]
            [ text "No results found for this search. "
            , button
                [ class "underline hover:text-gray-700 focus:text-indigo-500"
                , Html.Events.onClick (props.toMsg (ClickedReset props.baseUrl))
                ]
                [ text "Reset filters" ]
            ]

    else
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
            Url.Builder.absolute [ props.baseUrl, String.fromInt (props.toId data), "edit" ] []

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


viewTableFooter : Props data msg -> Html msg
viewTableFooter props =
    let
        currentPage : Int
        currentPage =
            Extra.Url.getQueryParameter "page" props.context.url
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 1

        toPageFilterUrl : Int -> String
        toPageFilterUrl page =
            Url.Builder.absolute [ props.baseUrl ]
                (toFilterQueryParameters props.model
                    ++ [ Url.Builder.string "page" (String.fromInt page)
                       ]
                )

        viewPreviousLink : Html msg
        viewPreviousLink =
            viewLink
                { label = "« Previous"
                , isDisabled = currentPage == 1
                , url = toPageFilterUrl (currentPage - 1)
                }

        viewNextLink : Html msg
        viewNextLink =
            viewLink
                { label = "Next »"
                , isDisabled = currentPage == props.lastPage
                , url = toPageFilterUrl (currentPage + 1)
                }

        viewPageNumberLink : Int -> Html msg
        viewPageNumberLink page =
            a
                [ class "mb-1 mr-1 px-4 py-3 focus:text-indigo-500 text-sm leading-4 hover:bg-white border focus:border-indigo-500 rounded"
                , Attr.classList [ ( "bg-white", currentPage == page ) ]
                , href (toPageFilterUrl page)
                ]
                [ text (String.fromInt page) ]

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
    if props.lastPage == 1 then
        text ""

    else
        div [ class "mt-6" ]
            [ div [ class "flex flex-wrap -mb-1" ]
                (List.concat
                    [ [ viewPreviousLink ]
                    , List.range 1 props.lastPage |> List.map viewPageNumberLink
                    , [ viewNextLink ]
                    ]
                )
            ]


viewOverlay :
    { context : Context
    , model : Model
    , toMsg : Msg -> msg
    , baseUrl : String
    }
    -> Html msg
viewOverlay props =
    let
        (Model model) =
            props.model

        viewFilterDropdown : Html msg
        viewFilterDropdown =
            Components.Dropdown.view
                { anchor = Components.Dropdown.TopLeft
                , offset =
                    if props.context.isMobile then
                        ( 16, 265 )

                    else
                        ( 272, 224 )
                , onDismiss = props.toMsg DismissedFilterDropdownMenu
                , content =
                    div
                        [ class "mt-2 px-4 py-6 w-screen bg-white rounded shadow-xl"
                        , Attr.style "max-width" "300px"
                        ]
                        [ label [ class "block text-gray-700" ] [ text "Trashed:" ]
                        , select
                            [ class "form-select mt-1 w-full"
                            , Html.Events.onInput (ChangedTrashFilter props.baseUrl >> props.toMsg)
                            ]
                            [ option [] []
                            , option [ Attr.value "with", Attr.selected (model.trashed == "with") ] [ text "With Trashed" ]
                            , option [ Attr.value "only", Attr.selected (model.trashed == "only") ] [ text "Only Trashed" ]
                            ]
                        ]
                }
    in
    if model.isFilterDropdownOpen then
        viewFilterDropdown

    else
        text ""
