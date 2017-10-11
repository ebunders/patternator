port module Main exposing (..)

import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Matrix exposing (Location, Matrix, loc, mapWithLocation, matrix, row)
import MatrixUtil
import Time


-- Ports
-- component import example
-- APP


type alias Note =
    { frequency : Int, velocity : Float }


port playNote : Note -> Cmd msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { grid : Matrix Cell
    , selectedStep : Int
    , bpm : Int
    , running : Bool
    , blink : Bool
    }


type Cell
    = Empty
    | Off
    | Soft
    | Medium
    | Strong



-- empty cells switch to medium when turend on, afther that they cycle through
-- soft, medium, strong, off, ..


nextCellValue : Cell -> Cell
nextCellValue cell =
    case cell of
        Empty ->
            Medium

        Off ->
            Soft

        Soft ->
            Medium

        Medium ->
            Strong

        Strong ->
            Off


cellToString : Cell -> String
cellToString cell =
    case cell of
        Soft ->
            "soft"

        Medium ->
            "medium"

        Strong ->
            "strong"

        _ ->
            "off"


cellToVelocity : Cell -> Float
cellToVelocity cell =
    case cell of
        Soft ->
            0.3

        Medium ->
            0.6

        Strong ->
            1.0

        _ ->
            0


initalModel : Model
initalModel =
    { grid = matrix 12 16 (\_ -> Empty)
    , selectedStep = 0
    , bpm = 100
    , running = False
    , blink = False
    }


init : ( Model, Cmd Msg )
init =
    ( initalModel, Cmd.none )



-- UPDATE


type Msg
    = ToggleSelect Location Cell
    | TransportMsg TransportMsgType
    | Tick Time.Time


type TransportMsgType
    = Rewind
    | ToggleTransport
    | BpmUp
    | BpmDown


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleSelect location newCell ->
            ( { model
                | grid = (Matrix.set location newCell model.grid)
              }
            , Cmd.none
            )

        Tick t ->
            let
                ( newSelectedStep, playNotes ) =
                    if model.running then
                        ( (model.selectedStep + 1) % 16, True )
                    else
                        ( model.selectedStep, False )

                cmd =
                    if playNotes then
                        notesToCmds newSelectedStep model.grid
                    else
                        Cmd.none
            in
                ( { model
                    | selectedStep = newSelectedStep
                    , blink = not model.blink
                  }
                , cmd
                )

        TransportMsg msg ->
            handleTransportMsg msg model



{--
We have to send the velocity along with the
--}


notesToCmds : Int -> Matrix.Matrix Cell -> Cmd msg
notesToCmds step grid =
    case MatrixUtil.getColumn step grid of
        Just list ->
            List.reverse list
                |> List.indexedMap (\i cell -> ( i, cell ))
                |> List.filter
                    (\( i, cell ) ->
                        if cell == Off || cell == Empty then
                            False
                        else
                            True
                    )
                |> List.map (\( i, cell ) -> ( i, (cellToVelocity cell) ))
                |> List.map (\( i, vel ) -> ( notetoFreq (i + 40), vel ))
                |> List.map (\( freq, vel ) -> (playNote { frequency = freq, velocity = vel }))
                |> Cmd.batch

        Nothing ->
            Cmd.none


handleTransportMsg : TransportMsgType -> Model -> ( Model, Cmd Msg )
handleTransportMsg msg model =
    case msg of
        ToggleTransport ->
            ( { model | running = not model.running }, Cmd.none )

        Rewind ->
            ( { model | selectedStep = 0 }, Cmd.none )

        BpmUp ->
            ( { model | bpm = (model.bpm + 1) }, Cmd.none )

        BpmDown ->
            ( { model | bpm = (model.bpm - 1) }, Cmd.none )



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Patternator" ]
        , div [ (class "grid") ] (rendergrid model)
        , div [ (class "controls") ] (renderControls model)
        ]


renderControls : Model -> List (Html Msg)
renderControls model =
    let
        blink =
            if (not (model.running)) && model.blink then
                " blink"
            else
                " "

        classes =
            if model.running then
                "fa fa-pause"
            else
                "fa fa-play"
    in
        [ i [ class (classes ++ blink), onClick (TransportMsg ToggleTransport) ] [ text "" ]
        , i [ class "fa fa-fast-backward", onClick (TransportMsg Rewind) ] [ text "" ]
        , div [ class "separator" ] [ text "" ]
        , i [ class "fa fa-arrow-down", onClick (TransportMsg BpmDown) ] [ text "" ]
        , span [ class "bpm" ] [ text ("BPM: " ++ (toString model.bpm)) ]
        , i [ class "fa fa-arrow-up", onClick (TransportMsg BpmUp) ] [ text "" ]
        ]


rendergrid : Model -> List (Html Msg)
rendergrid { grid, selectedStep } =
    let
        mapCell selectedStep location cell =
            let
                col =
                    Matrix.col location

                classes =
                    [ "cell"
                    , (cellToString cell)
                    , if selectedStep == col then
                        "selected"
                      else if col % 4 == 0 then
                        "accent"
                      else
                        ""
                    ]
                        |> List.filter (\s -> not (String.isEmpty s))
            in
                div [ (class (String.join " " classes)), (onClick (ToggleSelect location (nextCellValue cell))) ] []
    in
        grid
            -- transform cells to html
            |> Matrix.mapWithLocation (mapCell selectedStep)
            -- create list of lists (rows)
            |> Matrix.toList
            -- convert rows to divs
            |> List.map (\row -> div [ (class "row") ] row)



-- subscriptions


subscriptions : Model -> Sub.Sub Msg
subscriptions model =
    (Time.every (bpmToMs model.bpm) Tick)



-- BPM


type Signature
    = Quarter
    | Eight


bpmToMs : Int -> Float
bpmToMs bpm =
    let
        ticksPerMinute =
            bpmToTickspm bpm Quarter

        msPerMinute =
            60000
    in
        msPerMinute / ticksPerMinute


{-| Calculate ticks per minute:
bpm = ticks * sig
ticks = bpm / sig
sig = bpm / ticks
-}
bpmToTickspm : Int -> Signature -> Float
bpmToTickspm bpm signature =
    let
        sig =
            sigToFloat signature
    in
        (toFloat bpm) / sig


sigToFloat : Signature -> Float
sigToFloat sig =
    case sig of
        Quarter ->
            0.25

        Eight ->
            0.125


{-| Calculate the frequency by the (midi) note number
-}
notetoFreq : Int -> Int
notetoFreq note =
    floor (440 * 2 ^ ((toFloat (note - 58)) / 12))
