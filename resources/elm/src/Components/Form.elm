module Components.Form exposing
    ( create
    , text, password
    , select
    , button
    )

{-|

@docs create

@docs text, password
@docs select
@docs button

-}

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events


create :
    { onSubmit : msg
    , isSubmittingForm : Bool
    , button : String
    , inputs : List (Html msg)
    }
    -> Html msg
create props =
    div [ class "max-w-3xl bg-white rounded-md shadow overflow-hidden" ]
        [ Html.form [ Html.Events.onSubmit props.onSubmit ]
            [ div [ class "flex flex-wrap -mb-8 -mr-6 p-8" ] props.inputs
            , div [ class "flex items-center justify-end px-8 py-4 bg-gray-50 border-t border-gray-100" ]
                [ button
                    { label = props.button
                    , isDisabled = props.isSubmittingForm
                    }
                ]
            ]
        ]



-- FIELDS


text :
    { value : String
    , error : Maybe String
    , id : String
    , onInput : String -> msg
    , label : String
    , isDisabled : Bool
    }
    -> Html msg
text props =
    input "text" props


password :
    { value : String
    , error : Maybe String
    , id : String
    , onInput : String -> msg
    , label : String
    , isDisabled : Bool
    }
    -> Html msg
password props =
    input "password" props


input :
    String
    ->
        { value : String
        , error : Maybe String
        , id : String
        , onInput : String -> msg
        , label : String
        , isDisabled : Bool
        }
    -> Html msg
input inputType props =
    div [ class "pb-8 pr-6 w-full lg:w-1/2" ]
        [ viewLabel props
        , Html.input
            [ Attr.id props.id
            , class "form-input"
            , Attr.type_ inputType
            , Attr.classList [ ( "error", props.error /= Nothing ) ]
            , Attr.value props.value
            , Html.Events.onInput props.onInput
            , Attr.disabled props.isDisabled
            ]
            []
        , viewError props.error
        ]


select :
    { value : String
    , error : Maybe String
    , id : String
    , onInput : String -> msg
    , label : String
    , options : List ( String, String )
    , isDisabled : Bool
    }
    -> Html msg
select props =
    let
        viewOption : ( String, String ) -> Html msg
        viewOption ( value_, label_ ) =
            option
                [ Attr.value value_
                , Attr.selected (value_ == props.value)
                ]
                [ Html.text label_ ]
    in
    div [ class "pb-8 pr-6 w-full lg:w-1/2" ]
        [ viewLabel props
        , Html.select
            [ Attr.id props.id
            , class "form-select"
            , Attr.classList [ ( "error", props.error /= Nothing ) ]
            , Html.Events.onInput props.onInput
            , Attr.disabled props.isDisabled
            ]
            (List.map viewOption props.options)
        , viewError props.error
        ]


button : { label : String, isDisabled : Bool } -> Html msg
button props =
    Html.button
        [ class "flex items-center btn-indigo"
        , Attr.type_ "submit"
        , Attr.disabled props.isDisabled
        ]
        [ if props.isDisabled then
            div [ class "btn-spinner mr-2" ] []

          else
            Html.text ""
        , Html.text props.label
        ]


viewLabel : { props | id : String, label : String } -> Html msg
viewLabel props =
    label [ class "form-label", Attr.for props.id ]
        [ Html.text (props.label ++ ":") ]


viewError : Maybe String -> Html msg
viewError maybeError =
    case maybeError of
        Just error ->
            div [ class "form-error" ] [ Html.text error ]

        Nothing ->
            Html.text ""