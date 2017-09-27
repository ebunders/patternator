module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Time


-- component import example
-- APP


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


model : Model
model =
    { grid = (List.repeat 12 (List.repeat 16 False))
    , selectedColumn = 0
    , speedMs = 200
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


type alias Model =
    { grid : List (List Bool)
    , selectedColumn : Int
    , speedMs : Int
    }



-- UPDATE


type Msg
    = ToggleSelect Int Int
    | Tick Time.Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleSelect row col ->
            ( { model
                | grid = (mapGrid row col model.grid)
              }
            , Cmd.none
            )

        Tick t ->
            ( { model | selectedColumn = (model.selectedColumn + 1) % 16 }, Cmd.none )



-- todo these functions are too similar.


mapGrid : Int -> Int -> List (List Bool) -> List (List Bool)
mapGrid rowNr colNr grid =
    List.indexedMap
        (\i v ->
            if i == rowNr then
                mapRow colNr v
            else
                v
        )
        grid


mapRow : Int -> List Bool -> List Bool
mapRow colNr row =
    List.indexedMap
        (\i v ->
            if i == colNr then
                not v
            else
                v
        )
        row



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Patternator" ]
        , div [ (class "grid") ] (rendergrid model)
        , hr [] []
        ]


rendergrid : Model -> List (Html Msg)
rendergrid { grid, selectedColumn } =
    List.indexedMap (\i l -> (renderLine selectedColumn i l)) grid


renderLine : Int -> Int -> List Bool -> Html Msg
renderLine selectedColumn index line =
    div [ (class "row") ] (List.indexedMap (renderCell selectedColumn index) line)



-- div [ (class "row") ] [ text "foo bar" ]


renderCell : Int -> Int -> Int -> Bool -> Html Msg
renderCell selectedColumn rowIndex colIndex selected =
    let
        classes =
            if selected || selectedColumn == colIndex then
                "cell selected"
            else if colIndex % 4 == 0 then
                "cell accent"
            else
                "cell"
    in
        div [ (class classes), (onClick (ToggleSelect rowIndex colIndex)) ] []



-- subscriptions


subscriptions : Model -> Sub.Sub Msg
subscriptions model =
    (Time.every ((toFloat model.speedMs) * Time.millisecond) Tick)
