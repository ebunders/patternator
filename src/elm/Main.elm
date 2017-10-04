port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Matrix exposing (Location, Matrix, loc, mapWithLocation, matrix, row)
import MatrixUtil
import Time


-- Ports
-- component import example
-- APP


port playNote : Int -> Cmd msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


initalModel : Model
initalModel =
    { grid = matrix 12 16 (\_ -> False)
    , selectedStep = 0
    , bpm = 100
    , running = False
    , blink = False
    }


init : ( Model, Cmd Msg )
init =
    ( initalModel, Cmd.none )


type alias Model =
    { grid : Matrix Bool
    , selectedStep : Int
    , bpm : Int
    , running : Bool
    , blink : Bool
    }



-- UPDATE


type Msg
    = ToggleSelect Location
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



-- TODO: extract column from Matrix
-- filter active notes, and convert them to note numbers
-- create a list of playNote commands for each value
-- batch commands


notesToCmds : Int -> Matrix.Matrix Bool -> Cmd msg
notesToCmds step grid =
    case MatrixUtil.getColumn step grid of
        Just list ->
            list
                |> List.indexedMap (\i b -> ( i, b ))
                |> List.filter (\( i, b ) -> b)
                |> List.map (\( i, b ) -> notetoFreq (i + 40))
                |> List.map (\freq -> playNote freq)
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
        mapCell selectedStep location selected =
            let
                row =
                    Matrix.row location

                col =
                    Matrix.col location

                classes =
                    if selected || selectedStep == col then
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
