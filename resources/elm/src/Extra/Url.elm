module Extra.Url exposing (fromAbsoluteUrl, getQueryParameter)

import Url exposing (Url)


fromAbsoluteUrl : String -> Url -> Maybe Url
fromAbsoluteUrl absoluteUrl url =
    let
        baseUrl : String
        baseUrl =
            Url.toString { url | fragment = Nothing, query = Nothing, path = "" }
    in
    Url.fromString (baseUrl ++ absoluteUrl)


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
