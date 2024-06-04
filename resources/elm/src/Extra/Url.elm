module Extra.Url exposing (getQueryParameter)

import Url exposing (Url)


getQueryParameter : String -> Url -> Maybe String
getQueryParameter key url =
    case url.query of
        Nothing ->
            Nothing

        Just query ->
            query
                |> String.split "&"
                |> List.filterMap
                    (\segment ->
                        case String.split "=" segment of
                            k :: v :: [] ->
                                if Url.percentDecode k == Just key then
                                    Url.percentDecode v

                                else
                                    Nothing

                            k :: _ ->
                                if Url.percentDecode k == Just key then
                                    Just ""

                                else
                                    Nothing

                            _ ->
                                Nothing
                    )
                |> List.head
