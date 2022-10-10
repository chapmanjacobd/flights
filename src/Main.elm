module Main exposing (Airport, Model, Msg(..), config, init, main, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Attribute, Html, button, div, h1, input, span, text)
import Html.Attributes as Attributes exposing (class, placeholder, src, style)
import Html.Events exposing (onClick, onInput)
import HttpExtra
import Json.Decode as Decode exposing (Decoder, decodeString, float, int, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import List.Extra exposing (unique)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http
import Route exposing (Route)
import SearchData exposing (..)
import Selectize
import Table
import Url exposing (Url)
import Url.Builder

apiUrl : String
apiUrl =
    "http://localhost:3006"



-- "https://unli.xyz/neighbourhoods/api"


airports : WebData (List Airport)
airports =
    RemoteData.NotAsked



-- [ Airport
--     "UZ"
--     "SKD"
--     "TAS"
--     260
--     "Samarkand"
--     26
--     "Tashkent"
--     ""
-- ]


dollarColumn : String -> (data -> Int) -> Table.Column data msg
dollarColumn name toDollars =
    Table.customColumn
        { name = name
        , viewData = \data -> viewDollars (toDollars data)
        , sorter = Table.increasingOrDecreasingBy toDollars
        }


viewDollars : Int -> String
viewDollars dollars =
    "$" ++ String.fromInt dollars


kiwilinkColumn : String -> (data -> String) -> Table.Column data msg
kiwilinkColumn name tokiwilinks =
    Table.veryCustomColumn
        { name = name
        , viewData = \data -> viewkiwilinks (tokiwilinks data)
        , sorter = Table.decreasingBy tokiwilinks
        }


viewkiwilinks : String -> Table.HtmlDetails msg
viewkiwilinks kiwilinks =
    Table.HtmlDetails []
        [ span [ style "color" "white" ]
            [ Html.a [ Attributes.href kiwilinks, Attributes.target "_blank" ] [ text "Check price" ]
            ]
        ]


flagColumn : String -> (data -> String) -> Table.Column data msg
flagColumn name toflags =
    Table.veryCustomColumn
        { name = name
        , viewData = \data -> viewflags (toflags data)
        , sorter = Table.decreasingOrIncreasingBy toflags
        }


viewflags : String -> Table.HtmlDetails msg
viewflags flags =
    Table.HtmlDetails []
        [ Html.img
            [ src "static/blank.gif", class ("flag flag-" ++ String.toLower flags) ]
            []
        ]


config : Table.Config Airport Msg
config =
    Table.config
        { toId = .cityFrom
        , toMsg = SetTableState
        , columns =
            [ flagColumn "Flag" .uFrom
            , Table.stringColumn "From" .flyFrom
            , Table.stringColumn "To" .flyTo
            , Table.intColumn "Distance" .distance
            , Table.stringColumn "City From" .cityFrom
            , dollarColumn "Lowest Price" .price
            , Table.stringColumn "City To" .cityTo
            , kiwilinkColumn "Kiwi" (\rec -> rec.kiwiLink ++ rec.flyFrom ++ "&to=" ++ rec.flyTo)
            ]
        }


airportDecoder : Decoder (List Airport)
airportDecoder =
    Decode.list airportPatternDecoder


airportPatternDecoder : Decoder Airport
airportPatternDecoder =
    Decode.succeed Airport
        |> optional "uFrom" string ""
        |> optional "flyFrom" string ""
        |> optional "flyTo" string ""
        |> required "distance" int
        |> optional "cityFrom" string ""
        |> required "price" int
        |> optional "cityTo" string ""
        |> hardcoded "https://www.kiwi.com/deep?from="


searchDecoder : Decoder (List Search)
searchDecoder =
    Decode.list searchPatternDecoder


searchPatternDecoder : Decoder Search
searchPatternDecoder =
    Decode.succeed Search
        |> required "id" int
        |> optional "name" string ""
        |> optional "displayname" string ""



-- toLabel : Search -> String
-- toLabel search =
--     search.displayname


searchCategories : List (Selectize.Entry Search)
searchCategories =
    List.concat
        [ [ Selectize.divider "Cities" ]
        , searchData |> List.map Selectize.entry
        ]


type alias Airport =
    { uFrom : String
    , flyFrom : String
    , flyTo : String
    , distance : Int
    , cityFrom : String
    , price : Int
    , cityTo : String
    , kiwiLink : String
    }


type alias Flags =
    { basePath : String }



-- MODEL


type alias Model =
    { tableState : Table.State
    , tableQuery : String
    , textfieldSelection : Maybe Search
    , textfieldMenu : Selectize.State Search
    , airport : WebData (List Airport)
    , searchData : WebData (List Search)
    , key : Nav.Key
    , route : Route
    , flags : Flags
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init ({ basePath } as flags) url navKey =
    let
        model =
            { airport = NotAsked
            , flags = flags
            , key = navKey
            , route = Route.fromUrl basePath url
            , searchData = NotAsked
            , tableState = Table.initialSort ""
            , tableQuery = ""
            , textfieldSelection = Nothing
            , textfieldMenu =
                Selectize.closed
                    "textfield-menu"
                    .displayname
                    searchCategories
            }
    in
    changeRouteTo (Route.fromUrl basePath url) model navKey


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }


changeRouteTo : Route -> Model -> Nav.Key -> ( Model, Cmd Msg )
changeRouteTo route model navKey =
    case route of
        Route.NotFound ->
            ( model, Cmd.none )

        Route.Root ->
            ( model, Route.replaceUrl navKey Route.Root )

        Route.ToAirport airportid ->
            ( { model
                | airport = Loading
                , tableState = Table.initialSort ""
                , tableQuery = ""
              }
            , RemoteData.Http.get (apiUrl ++ "/getFlightRoutes?k=" ++ airportid) AirportResponse airportDecoder
            )


type Msg
    = SetTableQuery String
    | SetTableState Table.State
    | TextfieldMenuMsg (Selectize.Msg Search)
    | SelectTextfieldAirport (Maybe Search)
    | SearchResponse (WebData (List Search))
    | AirportResponse (WebData (List Airport))
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest


webDataToList wd =
    RemoteData.toMaybe wd |> Maybe.withDefault []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ flags } as model) =
    let
        defaultSearch =
            ( { model
                | textfieldMenu =
                    Selectize.closed
                        "textfield-menu"
                        .displayname
                        searchCategories
              }
            , Cmd.none
            )
    in
    case msg of
        SearchResponse ((RemoteData.Success items) as data) ->
            ( { model
                | textfieldMenu =
                    Selectize.refresh
                        model.textfieldMenu
                        "textfield-menu"
                        .displayname
                        (List.concat
                            [ [ Selectize.divider "Cities" ]
                            , webDataToList data |> List.map Selectize.entry
                            ]
                        )
              }
            , Cmd.none
            )

        SearchResponse (RemoteData.NotAsked as data) ->
            defaultSearch

        SearchResponse (RemoteData.Loading as data) ->
            defaultSearch

        SearchResponse ((RemoteData.Failure _) as data) ->
            defaultSearch

        -- AirportResponse data ->
        --     ( { model | airport = data }, Cmd.none )
        AirportResponse data ->
            update
                (ClickedLink
                    (Browser.Internal
                        (Url.fromString
                            ("http://localhost:8000/"
                                ++ Url.Builder.relative
                                    [ "toAirport", String.fromInt (Maybe.map .id model.textfieldSelection |> Maybe.withDefault 0) ]
                                    []
                            )
                            |> Maybe.withDefault { protocol = Url.Https, host = "unli.xyz", port_ = Just 443, path = "/flights/", query = Nothing, fragment = Nothing }
                        )
                    )
                )
                { model | airport = data }

        SetTableQuery newQuery ->
            ( { model | tableQuery = newQuery }
            , Cmd.none
            )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            )

        ChangedUrl url ->
            ( { model
                | route = Route.fromUrl flags.basePath url
              }
            , Cmd.none
            )

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        SelectTextfieldAirport newSelection ->
            case newSelection of
                Nothing ->
                    ( { model
                        | textfieldSelection = newSelection
                      }
                    , RemoteData.Http.get (apiUrl ++ "/searchOrigin?input=" ++ model.textfieldMenu.query) SearchResponse searchDecoder
                    )

                _ ->
                    ( { model
                        | textfieldSelection = newSelection
                        , airport = Loading
                        , tableState = Table.initialSort ""
                        , tableQuery = ""
                      }
                    , RemoteData.Http.get (apiUrl ++ "/getFlightRoutes?k=" ++ String.fromInt (newSelection |> Maybe.map .id |> Maybe.withDefault 0)) AirportResponse airportDecoder
                    )

        TextfieldMenuMsg selectizeMsg ->
            let
                ( newMenu, menuCmd, maybeMsg ) =
                    Selectize.update SelectTextfieldAirport
                        model.textfieldSelection
                        model.textfieldMenu
                        selectizeMsg

                newModel =
                    { model | textfieldMenu = newMenu }

                cmd =
                    menuCmd |> Cmd.map TextfieldMenuMsg
            in
            case maybeMsg of
                Just nextMsg ->
                    update nextMsg newModel
                        |> andDo cmd

                Nothing ->
                    ( newModel, cmd )


andDo : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
andDo cmd ( model, cmds ) =
    ( model
    , Cmd.batch [ cmd, cmds ]
    )



---- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


airportTitle : String
airportTitle =
    "te"


view : Model -> Document Msg
view model =
    let
        tableState =
            model.tableState

        tableQuery =
            model.tableQuery

        lowerQuery =
            String.toLower tableQuery

        -- viewPage page toMsg pageConfig =
        --     let
        --         { title, body } =
        --             Page.view page pageConfig
        --     in
        --     { title = title
        --     , body = List.map (Html.map toMsg) body
        --     }
    in
    -- case model of
    -- NotFound _ ->
    --     Route.view Route.Other NotFound.view
    -- Start start ->
    --     viewPage Page.Home GotHomeMsg (Home.view home)
    -- Profile airport profile ->
    --     viewPage (Page.Profile airport) GotProfileMsg (Profile.view profile)
    { title = airportTitle ++ "UNLI Flights"
    , body =
        [ Html.div
            []
            [ Html.div
                [ style "display" "flex"
                , style "flex-flow" "column"
                ]
                [ Html.div
                    [ style "display" "block" ]
                    [ Html.div
                        [ Attributes.class "caption" ]
                        [ Html.text "See all flights to an airport: " ]
                    , Html.div
                        [ style "width" "30rem" ]
                        [ Selectize.view
                            viewConfigTextfield
                            model.textfieldSelection
                            model.textfieldMenu
                            |> Html.map TextfieldMenuMsg
                        ]
                    ]
                ]
            , Html.div
                []
                [ case model.airport of
                    Loading ->
                        text "Loading airport data, please stand by..."

                    Success airport ->
                        let
                            acceptableAirport =
                                List.filter (String.contains lowerQuery << String.toLower << .cityFrom) airport
                        in
                        div []
                            [ h1 [] [ text ("Flights to " ++ (airport |> List.map .cityTo |> unique |> String.join " and ")) ]
                            , text "Filter by City: "
                            , input [ onInput SetTableQuery ] []
                            , Table.view config tableState acceptableAirport
                            ]

                    Failure error ->
                        text ("Oh noes, airport loading failed with error: " ++ HttpExtra.errorToString error)

                    NotAsked ->
                        div []
                            [ Html.h3 [] [ text "Please select a city" ]
                            , div []
                                [ Html.br [] []
                                , text "Hello there!"
                                , Html.br [] []
                                , Html.br [] []
                                , text "This website will help you search backwards with historical flight prices and routes."
                                , Html.br [] []
                                , text "It's useful for if you are unsure whether a flight is a good price, or if you want to route a 3+ destination trip in a cheap way."
                                , Html.br [] []
                                , Html.br [] []
                                , text "I've used this data when planning my own trips and confirming whether or not a deal is a good price."
                                , Html.br [] []
                                , text "But know that the data is not 100% accurate, especially for tickets that cost more than $800."
                                ]
                            ]
                ]
            ]
        ]
    }



---- CONFIGURATION


viewConfigTextfield : Selectize.ViewConfig Search
viewConfigTextfield =
    viewConfig textfieldSelector


viewConfig : Selectize.Input Search -> Selectize.ViewConfig Search
viewConfig selector =
    let
        entryFunction : Search -> Bool -> Bool -> Selectize.HtmlDetails Never
        entryFunction tree mouseFocused keyboardFocused =
            { attributes =
                [ Attributes.class "selectize__item"
                , Attributes.classList
                    [ ( "selectize__item--mouse-selected"
                      , mouseFocused
                      )
                    , ( "selectize__item--key-selected"
                      , keyboardFocused
                      )
                    ]
                ]
            , children =
                [ Html.text tree.displayname ]
            }
    in
    Selectize.viewConfig
        { container = []
        , menu =
            [ Attributes.class "selectize__menu" ]
        , ul =
            [ Attributes.class "selectize__list" ]
        , entry =
            entryFunction
        , divider =
            \title ->
                { attributes =
                    [ Attributes.class "selectize__divider" ]
                , children =
                    [ Html.text title ]
                }
        , input = selector
        }


textfieldSelector : Selectize.Input Search
textfieldSelector =
    Selectize.autocomplete <|
        { attrs =
            \sthSelected open ->
                [ Attributes.class "selectize__textfield"
                , Attributes.classList
                    [ ( "selectize__textfield--selection", sthSelected )
                    , ( "selectize__textfield--no-selection", not sthSelected )
                    , ( "selectize__textfield--menu-open", open )
                    ]
                ]
        , toggleButton = toggleButton
        , clearButton = clearButton
        , placeholder = "Select a City"
        }


toggleButton : Maybe (Bool -> Html Never)
toggleButton =
    Just <|
        \open ->
            Html.div
                [ Attributes.class "selectize__menu-toggle"
                , Attributes.classList
                    [ ( "selectize__menu-toggle--menu-open", open ) ]
                ]
                [ Html.i
                    [ Attributes.class "material-icons"
                    , Attributes.class "selectize__icon"
                    ]
                    [ if open then
                        Html.text "arrow_drop_up"

                      else
                        Html.text "arrow_drop_down"
                    ]
                ]


clearButton : Maybe (Html Never)
clearButton =
    Just <|
        Html.div
            [ Attributes.class "selectize__menu-toggle" ]
            [ Html.i
                [ Attributes.class "material-icons"
                , Attributes.class "selectize__icon"
                ]
                [ Html.text "clear" ]
            ]
