module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Matrix exposing (Location, Matrix, loc, mapWithLocation, matrix, row)
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
    { grid = matrix 12 16 (\_ -> False)
    , selectedColumn = 0
    , speedMs = 200
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


type alias Model =
    { grid : Matrix Bool
    , selectedColumn : Int
    , speedMs : Int
    }



-- UPDATE


type Msg
    = ToggleSelect Location
    | Tick Time.Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleSelect location ->
            let
                newValue =
                    not (Maybe.withDefault False (Matrix.get location model.grid))
            in
                ( { model
                    | grid = Matrix.set location newValue model.grid
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
    let
        mapCell selectedColumn location selected =
            let
                row =
                    Matrix.row location

                col =
                    Matrix.col location

                classes =
                    if selected || selectedColumn == col then
                        "cell selected"
                    else if col % 4 == 0 then
                        "cell accent"
                    else
                        "cell"
            in
                div [ (class classes), (onClick (ToggleSelect location)) ] []
    in
        grid
            -- transform cells to html
            |> Matrix.mapWithLocation (mapCell selectedColumn)
            -- create list of lists (rows)
            |> Matrix.toList
            -- convert rows to divs
            |> List.map (\row -> div [ (class "row") ] row)



-- subscriptions


subscriptions : Model -> Sub.Sub Msg
subscriptions model =
    (Time.every ((toFloat model.speedMs) * Time.millisecond) Tick)
