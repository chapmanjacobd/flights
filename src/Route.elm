module Route exposing (Route(..), fromUrl, replaceUrl, toString)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



-- ROUTING


type Route
    = Root
    | ToAirport String
    | NotFound



-- PUBLIC HELPERS


parser : Parser (Route -> b) b
parser =
    Parser.oneOf
        [ Parser.map Root Parser.top
        , Parser.map ToAirport (Parser.s "toAirport" </> Parser.string)
        ]


fromUrl : String -> Url -> Route
fromUrl basePath url =
    { url | path = String.replace basePath "" url.path }
        |> Parser.parse parser
        |> Maybe.withDefault NotFound


toString : Route -> String
toString route =
    case route of
        Root ->
            ""

        ToAirport airportid ->
            airportid

        NotFound ->
            "not-found"


href : Route -> Attribute msg
href targetRoute =
    Attr.href (toString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toString route)



-- parser : Parser (Route -> a) a
-- parser =
--     oneOf
--         [ Parser.map Root Parser.top
--         , Parser.map ToAirport (s "toAirport")
--         ]
-- fromUrl : Url -> Route
-- fromUrl =
-- Parser.parse routeParser >> Maybe.withDefault NotFound
-- routeParser : Parser (Route -> Route) Route
-- routeParser =
-- Parser.map parseFragment (Parser.fragment identity)
-- parseFragment : Maybe String -> Route
-- parseFragment fragment =
-- case fragment of
--     Just "home" ->
--     Home
--     Just "products" ->
--     Products
--     Just "contact" ->
--     Contact
--     _ ->
--     NotFound
