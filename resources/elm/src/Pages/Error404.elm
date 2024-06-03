module Pages.Error404 exposing
    ( Props
    , Model, Msg
    , init, subscriptions, update, view
    )

{-|

@docs Props
@docs Model, Msg
@docs init, subscriptions, update, view

-}

import Html exposing (Html)
import Json.Decode



-- PROPS


type alias Props =
    { page : String
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


view : Model -> Html msg
view { props } =
    Html.div []
        [ Html.h1 []
            [ Html.text ("404: No handler for '" ++ props.page ++ "'.")
            ]
        ]
