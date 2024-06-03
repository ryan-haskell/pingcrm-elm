module Pages.Error500 exposing
    ( Props
    , Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Props
@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Browser exposing (Document)
import Html exposing (Html)
import Json.Decode



-- PROPS


type alias Props =
    { page : String
    , error : Json.Decode.Error
    }



-- MODEL


type alias Model =
    { props : Props
    }


init : Props -> ( Model, Cmd Msg )
init props =
    ( { props = props
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoNothing ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view { props } =
    { title = "500"
    , body =
        [ Html.div []
            [ Html.h1 []
                [ Html.text ("500: Unexpected props for '" ++ props.page ++ "'.")
                ]
            , Html.pre []
                [ Html.text (Json.Decode.errorToString props.error)
                ]
            ]
        ]
    }
