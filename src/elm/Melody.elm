port module Melody exposing (..)

import Html exposing (Html, div, h1, h3, h4, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


port melodyWaveform : String -> Cmd msg


type alias Model =
    { waveform : Waveform }


type Waveform
    = Square
    | Sine
    | Triangle
    | Sawtooth


type alias WaveformTick =
    { waveform : Waveform, selected : Bool }


waveformTicks : List WaveformTick
waveformTicks =
    [ { waveform = Square, selected = False }
    , { waveform = Sine, selected = False }
    , { waveform = Triangle, selected = False }
    , { waveform = Sawtooth, selected = False }
    ]


initModel : Model
initModel =
    { waveform = Square }


type Msg
    = SetWaveform Waveform


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWaveform newWaveform ->
            ( { model | waveform = newWaveform }, (melodyWaveform (waveformToLabel newWaveform)) )


waveformToLabel : Waveform -> String
waveformToLabel waveform =
    case waveform of
        Square ->
            "square"

        Sine ->
            "sine"

        Triangle ->
            "triangle"

        Sawtooth ->
            "sawtooth"


renderControls : Model -> Html Msg
renderControls model =
    div [ (class "melody") ]
        [ (renderWaveform model)
        ]


renderWaveform : Model -> Html Msg
renderWaveform model =
    let
        selectorModel =
            List.map (\tick -> { tick | selected = (tick.waveform == model.waveform) }) waveformTicks

        elements =
            (h4 [] [ (text "Waveform") ]) :: (List.map tickToHtml selectorModel)
    in
        div [ (class "waveform") ] elements


tickToHtml : WaveformTick -> Html Msg
tickToHtml tick =
    let
        tickClass =
            if tick.selected then
                "selected"
            else
                ""
    in
        div [ (class "tick") ]
            [ span
                [ (class tickClass)
                , (onClick (SetWaveform tick.waveform))
                ]
                [ text "" ]
            , span [ (onClick (SetWaveform tick.waveform)) ] [ (text (waveformToLabel tick.waveform)) ]
            ]
