module Grid exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
import Matrix exposing (Location, Matrix)
import MatrixUtil
import Util exposing (joinStrings)


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
    | Rewind


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

        Rewind ->
            ( { model | selectedStep = 0 }
            , Cmd.none
            )


{-| Get the notes and the velocity for the current step of a grid
It takes a grid model
It returns a tuple of a Velocity for the step, and
a List of note numbers, where the bottom row of the grid represents a 0
-}
notesAndVelocity : Model -> ( Velocity, List Int )
notesAndVelocity model =
    let
        velocity =
            Maybe.withDefault Medium <|
                (model.velocities
                    |> List.drop model.selectedStep
                    |> List.head
                )

        notes =
            (Maybe.withDefault [] <| MatrixUtil.getColumn model.selectedStep model.grid)
                |> List.reverse
                |> List.indexedMap (\i cell -> ( i, cell ))
                |> List.filter (\( i, cell ) -> cell == On)
                |> List.map (\( i, cell ) -> i)
    in
        ( velocity, notes )


nextVelocity : Velocity -> Velocity
nextVelocity velocity =
    case velocity of
        Soft ->
            Medium

        Medium ->
            Strong

        Strong ->
            Soft



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
                |> List.map (\row -> div [ (class "gridrow") ] row)
    in
        gridrowsAshtml
            |> (addVelocityRow model.velocities)
            |> (\rows -> div [ (class "grid") ] rows)


addVelocityRow : List Velocity -> List (Html Msg) -> List (Html Msg)
addVelocityRow velocities rows =
    let
        stylesForVelocityState : Velocity -> List String
        stylesForVelocityState velocity =
            case velocity of
                Soft ->
                    [ "off", "off", "on" ]

                Medium ->
                    [ "off", "on", "on" ]

                Strong ->
                    [ "on", "on", "on" ]

        styleForVelocityLevel =
            [ "strong", "medium", "soft" ]

        styleForVelocity : Velocity -> List String
        styleForVelocity velocity =
            List.map2 (\a b -> [ a, b ])
                (stylesForVelocityState velocity)
                styleForVelocityLevel
                |> List.map (joinStrings " ")

        velocitiesAsHtml =
            velocities
                |> List.indexedMap
                    (\i v ->
                        let
                            velClasses =
                                styleForVelocity v
                        in
                            div [ (class "velocity"), (onClick (SetVelocity i (nextVelocity v))) ]
                                (velClasses
                                    |> List.map (\vc -> div [ (class vc) ] [])
                                )
                    )
                |> (\list -> div [ class "velocities" ] list)
    in
        velocitiesAsHtml :: rows


mapCell : Int -> Int -> Location -> Cell -> Html Msg
mapCell selectedStep notesPerBar location cell =
    let
        col =
            Matrix.col location

        c =
            if cell == On then
                "cell on"
            else
                "cell"

        classes =
            [ c
            , if selectedStep == col then
                "selected"
              else if col % 4 == 0 then
                "accent"
              else
                case cell of
                    On ->
                        "on"

                    Off ->
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
