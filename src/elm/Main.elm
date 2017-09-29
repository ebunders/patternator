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
    , running = False
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


type alias Model =
    { grid : Matrix Bool
    , selectedColumn : Int
    , speedMs : Int
    , running : Bool
    }



-- UPDATE


type Msg
    = ToggleSelect Location
    | ToggleTransport
    | Rewind
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

        ToggleTransport ->
            ( { model | running = not model.running }, Cmd.none )

        Rewind ->
            ( { model | selectedColumn = 0 }, Cmd.none )



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Patternator" ]
        , div [ (class "grid") ] (rendergrid model)
        , div [ (class "button controls") ] (renderControls model.running)
        ]


renderControls : Bool -> List (Html Msg)
renderControls running =
    let
        classes =
            if running then
                "fa fa-pause"
            else
                "fa fa-play"
    in
        [ i [ class classes, onClick ToggleTransport ] [ text "" ]
        , i [ class "fa fa-fast-backward", onClick Rewind ] [ text "" ]
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
    if model.running then
        (Time.every ((toFloat model.speedMs) * Time.millisecond) Tick)
    else
        Sub.none
