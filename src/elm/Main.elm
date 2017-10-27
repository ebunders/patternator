port module Main exposing (..)

import Grid exposing (GridType(Melody), Velocity(Soft, Medium, Strong))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Melody exposing (renderControls)
import Time


-- Ports
-- component import example
-- APP


type alias Note =
    { frequencies : List Int, velocity : Float }


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
    { grid : Grid.Model
    , melody : Melody.Model
    , bpm : Int
    , running : Bool
    , blink : Bool
    }


initalModel : Model
initalModel =
    { grid = (Grid.initModel Melody 12 16 4)
    , melody = Melody.initModel
    , bpm = 100
    , running = False
    , blink = False
    }


init : ( Model, Cmd Msg )
init =
    ( initalModel, Cmd.none )



-- UPDATE


type Msg
    = GridMessage Grid.Msg
    | MelodyMessage Melody.Msg
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
        GridMessage msg ->
            let
                ( gridModel, gridCmd ) =
                    Grid.update msg model.grid
            in
                ( { model | grid = gridModel }, (Cmd.map GridMessage gridCmd) )

        MelodyMessage msg ->
            let
                ( melodyModel, melodyCmd ) =
                    Melody.update msg model.melody
            in
                ( { model | melody = melodyModel }, Cmd.map MelodyMessage melodyCmd )

        Tick t ->
            let
                newModel =
                    { model | blink = not model.blink }
            in
                if model.running then
                    translateGridUpdate
                        newModel
                        (notesToCmds <| Grid.notesAndVelocity model.grid)
                        (Grid.update Grid.Tick model.grid)
                else
                    ( newModel, Cmd.none )

        TransportMsg msg ->
            handleTransportMsg msg model



{--
We have to send the velocity along with the
--}


notesToCmds : ( Velocity, List Int ) -> Cmd msg
notesToCmds ( velocity, notes ) =
    if List.isEmpty notes then
        Cmd.none
    else
        let
            freqs =
                notes
                    |> List.map ((+) 40)
                    |> List.map notetoFreq

            velocityFloat =
                case velocity of
                    Soft ->
                        0.2

                    Medium ->
                        0.7

                    Strong ->
                        1.0

            note : Note
            note =
                { frequencies = freqs, velocity = velocityFloat }
        in
            playNote note


handleTransportMsg : TransportMsgType -> Model -> ( Model, Cmd Msg )
handleTransportMsg msg model =
    case msg of
        ToggleTransport ->
            ( { model | running = not model.running }, Cmd.none )

        Rewind ->
            translateGridUpdate model Cmd.none (Grid.update Grid.Rewind model.grid)

        BpmUp ->
            ( { model | bpm = (model.bpm + 1) }, Cmd.none )

        BpmDown ->
            ( { model | bpm = (model.bpm - 1) }, Cmd.none )


translateGridUpdate : Model -> Cmd Msg -> ( Grid.Model, Cmd Grid.Msg ) -> ( Model, Cmd Msg )
translateGridUpdate model cmd ( gridModel, gridCmd ) =
    ( { model | grid = gridModel }
    , Cmd.batch
        [ Cmd.map GridMessage gridCmd
        , cmd
        ]
    )



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Patternator" ]
        , div []
            [ div [ (class "grid") ] [ (Html.map GridMessage <| Grid.renderGrid model.grid) ]
            , div [ (class "instrument") ] [ (Html.map MelodyMessage <| Melody.renderControls model.melody) ]
            ]
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
    floor (16.35 * 2 ^ (toFloat (note) / 12))
