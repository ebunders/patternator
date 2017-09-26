module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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
    { grid = (List.repeat 12 (List.repeat 16 False)) }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


type alias Model =
    { grid : List (List Bool) }


type alias Note =
    { pitch : Maybe Int
    , velocity : Maybe Int
    }



-- UPDATE


type Msg
    = ToggleSelect Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleSelect row col ->
            ( { model
                | grid = (mapGrid row col model.grid)
              }
            , Cmd.none
            )



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
        , div [ (class "grid") ] (rendergrid model.grid)
        ]


rendergrid : List (List Bool) -> List (Html Msg)
rendergrid grid =
    List.indexedMap (\i l -> (renderLine i l)) grid


renderLine : Int -> List Bool -> Html Msg
renderLine index line =
    div [ (class "row") ] (List.indexedMap (renderCell index) line)



-- div [ (class "row") ] [ text "foo bar" ]


renderCell : Int -> Int -> Bool -> Html Msg
renderCell rowIndex colIndex selected =
    let
        classes =
            if selected then
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
    Sub.none
