module HttpExtra exposing (errorToString)

import Http exposing (Error(..))
import Json.Decode as Json


errorToString : Http.Error -> String
errorToString err =
    case err of
        Timeout ->
            "Timeout exceeded"

        NetworkError ->
            "Network error"

        BadStatus resp ->
            "Bad status" ++ String.fromInt resp

        BadBody text ->
            "Unexpected response from api: " ++ text

        BadUrl url ->
            "Malformed url: " ++ url
