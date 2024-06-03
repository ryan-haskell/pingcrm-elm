module Pages exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (Html)
import InertiaJs exposing (PageData)
import Json.Decode
import Pages.Dashboard.Index
import Pages.Error404
import Pages.Error500



-- MODEL


type Model
    = Model_Dashboard_Index Pages.Dashboard.Index.Model
    | Model_Error404 Pages.Error404.Model
    | Model_Error500 Pages.Error500.Model


init : PageData -> ( Model, Cmd Msg )
init pageData =
    case pageData.component of
        "Dashboard/Index" ->
            case Json.Decode.decodeValue Pages.Dashboard.Index.decoder pageData.props of
                Ok props ->
                    Pages.Dashboard.Index.init props
                        |> Tuple.mapBoth
                            Model_Dashboard_Index
                            (Cmd.map Msg_Dashboard_Index)

                Err jsonDecodeError ->
                    Pages.Error500.init
                        { error = jsonDecodeError
                        , page = pageData.component
                        }
                        |> Tuple.mapBoth
                            Model_Error500
                            (Cmd.map Msg_Error500)

        _ ->
            Pages.Error404.init
                { page = pageData.component
                }
                |> Tuple.mapBoth
                    Model_Error404
                    (Cmd.map Msg_Error404)



-- UPDATE


type Msg
    = Msg_Dashboard_Index Pages.Dashboard.Index.Msg
    | Msg_Error404 Pages.Error404.Msg
    | Msg_Error500 Pages.Error500.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Msg_Dashboard_Index pageMsg, Model_Dashboard_Index pageModel ) ->
            Pages.Dashboard.Index.update pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Dashboard_Index
                    (Cmd.map Msg_Dashboard_Index)

        ( Msg_Error404 pageMsg, Model_Error404 pageModel ) ->
            Pages.Error404.update pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Error404
                    (Cmd.map Msg_Error404)

        ( Msg_Error500 pageMsg, Model_Error500 pageModel ) ->
            Pages.Error500.update pageMsg pageModel
                |> Tuple.mapBoth
                    Model_Error500
                    (Cmd.map Msg_Error500)

        _ ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Model_Dashboard_Index pageModel ->
            Pages.Dashboard.Index.subscriptions pageModel
                |> Sub.map Msg_Dashboard_Index

        Model_Error404 pageModel ->
            Pages.Error404.subscriptions pageModel
                |> Sub.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.subscriptions pageModel
                |> Sub.map Msg_Error500



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Model_Dashboard_Index pageModel ->
            Pages.Dashboard.Index.view pageModel
                |> Html.map Msg_Dashboard_Index

        Model_Error404 pageModel ->
            Pages.Error404.view pageModel
                |> Html.map Msg_Error404

        Model_Error500 pageModel ->
            Pages.Error500.view pageModel
                |> Html.map Msg_Error500
