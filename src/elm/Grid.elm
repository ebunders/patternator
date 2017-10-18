module Grid exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Matrix exposing (Location, Matrix)


{-| This module handles grids

The module can make a data model for grids, and knows how to use the
model.

There are different kinds of grids (Drums, Bass and Melody)

     A grid is matrix where the lines are different notes to play, and

the columns are steps in time.

Grids have a certain number of columns and rows, but there is one extra
column (nr 0) that can hold a lable. So the grid needs a resolver that
can translate a row index number (they run from the bottom) into a label.
The grid has an extra row on top as well, that contains velocity information
for that step in the grid.

The rest of the grid consists of cells. Cells contain note information.
At first we only support trigger (note on).

-}
type alias Model =
    { grid : Matrix Cell
    , velocities : List Velocity
    , gridType : GridType
    , notesPerBar : Int
    , selectedStep : Int
    }


type Cell
    = On
    | Off


type Velocity
    = Soft
    | Medium
    | Strong


type GridType
    = Drums
    | Bass
    | Melody


type alias Col =
    Int


{-| Create a Grid model. params:

  - gridType: GridType
  - nr of rows: Int
  - nr of cols: Int
  - notes per bar (for visual accent)

-}
initModel : GridType -> Int -> Int -> Int -> Model
initModel gridType rows cols notesPerBar =
    { grid = Matrix.fromList (List.repeat rows (List.repeat cols Off))
    , velocities = (List.repeat cols Medium)
    , gridType = gridType
    , notesPerBar = notesPerBar
    , selectedStep = 0
    }



-- Update


type Msg
    = Tick
    | ToggleSelect Location
    | SetVelocity Col Velocity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            ( { model | selectedStep = (model.selectedStep + 1) % ((colsInGrid model) + 1) }
            , Cmd.none
            )

        SetVelocity col velocity ->
            ( { model
                | velocities =
                    List.indexedMap
                        (\i v ->
                            if i == col then
                                velocity
                            else
                                v
                        )
                        model.velocities
              }
            , Cmd.none
            )

        ToggleSelect location ->
            let
                toggleCell cell =
                    case cell of
                        On ->
                            Off

                        Off ->
                            On

                newGrid =
                    Maybe.withDefault model.grid
                        (Matrix.get location model.grid
                            |> Maybe.map toggleCell
                            |> Maybe.map (\newcell -> Matrix.set location newcell model.grid)
                        )
            in
                ( { model | grid = newGrid }
                , Cmd.none
                )



-- View


renderGrid : Model -> Html Msg
renderGrid model =
    let
        gridrowsAshtml : List (Html Msg)
        gridrowsAshtml =
            model.grid
                -- transform cells to html
                |> Matrix.mapWithLocation (mapCell model.selectedStep model.notesPerBar)
                -- create list of lists (rows)
                |> Matrix.toList
                -- convert rows to divs
                |> List.map (\row -> div [ (class "row") ] row)
    in
        gridrowsAshtml
            |> (addVelocityRow model.velocities)
            |> (\rows -> div [ (class "grid") ] rows)


addVelocityRow : List Velocity -> List (Html Msg) -> List (Html Msg)
addVelocityRow velocities rows =
    let
        stylesForVelocity velocity =
            case velocity of
                Soft ->
                    [ "on", "off", "off" ]

                Medium ->
                    [ "off", "on", "off" ]

                Strong ->
                    [ "off", "off", "on" ]

        velocitiesAsHtml =
            velocities
                |> List.indexedMap
                    (\i v ->
                        let
                            velClasses =
                                stylesForVelocity v
                        in
                            div [ (class "velocity") ]
                                (velClasses
                                    |> List.map (\vc -> div [ (class vc) ] [])
                                )
                    )
                |> (\list -> div [ class "velocities" ] list)
    in
        rows


mapCell : Int -> Int -> Location -> Cell -> Html Msg
mapCell selectedStep notesPerBar location cell =
    let
        col =
            Matrix.col location

        classes =
            [ "cell"
            , if selectedStep == col then
                "selected"
              else if col % 4 == 0 then
                "accent"
              else
                ""
            ]
                |> List.filter (\s -> not (String.isEmpty s))
    in
        div [ (class (String.join " " classes)), (onClick (ToggleSelect location)) ] []



--Utility


rowsInGrid : Model -> Int
rowsInGrid model =
    Matrix.rowCount model.grid


colsInGrid : Model -> Int
colsInGrid model =
    Matrix.colCount model.grid
