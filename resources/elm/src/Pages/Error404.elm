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

import Browser exposing (Document)
import Context exposing (Context)
import Effect exposing (Effect)
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


init : Context -> Props -> ( Model, Effect Msg )
init ctx props =
    ( { props = props
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = DoNothing


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update ctx msg model =
    case msg of
        DoNothing ->
            ( model, Effect.none )


subscriptions : Context -> Model -> Sub Msg
subscriptions ctx model =
    Sub.none



-- VIEW


view : Context -> Model -> Document Msg
view ctx { props } =
    { title = "404"
    , body =
        [ Html.h1 []
            [ Html.text ("404: No handler for '" ++ props.page ++ "'.")
            ]
        ]
    }
