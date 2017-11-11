port module Melody exposing (..)

import Html exposing (Html, div, h1, h3, h4, span, text)
import Html.Attributes exposing (class, id, value)
import Html.Events exposing (onClick)


port melodyWaveform : String -> Cmd msg


port melodyInitKnob : KnobModel -> Cmd msg


port melodyUpdateKnob : (KnobValueUpdate -> msg) -> Sub msg


port melodySetAttack : Float -> Cmd msg


port melodySetRelease : Float -> Cmd msg


type alias ID =
    String


type alias KnobValue =
    Float


type alias KnobModel =
    { id : ID
    , minValue : KnobValue
    , maxValue : KnobValue
    , value : KnobValue
    , label : String
    }


type alias KnobValueUpdate =
    { id : ID
    , value : KnobValue
    }


type alias Model =
    { waveform : Waveform
    , knobs : List KnobModel
    }


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


initModel : ( Model, Cmd Msg )
initModel =
    let
        attackModel =
            { id = "id_attack"
            , minValue = 0.0
            , maxValue = 1.0
            , value = 0.0
            , label = "Attack"
            }

        releaseModel =
            { id = "id_release"
            , minValue = 0.0
            , maxValue = 1.0
            , value = 0.0
            , label = "Release"
            }

        model =
            { waveform = Square
            , knobs = [ attackModel, releaseModel ]
            }

        cmd =
            Cmd.batch
                [ (melodyInitKnob attackModel), (melodyInitKnob releaseModel) ]
    in
        ( model, cmd )


type Msg
    = SetWaveform Waveform
    | UpdateKnob KnobValueUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWaveform newWaveform ->
            ( { model | waveform = newWaveform }, (melodyWaveform (waveformToLabel newWaveform)) )

        UpdateKnob valueUpdate ->
            let
                -- TODO: this sucks totally!
                knobsAndCmds : List ( KnobModel, Cmd msg )
                knobsAndCmds =
                    model.knobs
                        |> List.map
                            (\knob ->
                                if valueUpdate.id == knob.id then
                                    let
                                        updatedKnob =
                                            { knob | value = valueUpdate.value }
                                    in
                                        ( updatedKnob, knobToCmd updatedKnob )
                                else
                                    ( knob, Cmd.none )
                            )
            in
                ( { model | knobs = (List.map Tuple.first knobsAndCmds) }
                , Cmd.batch (List.map Tuple.second knobsAndCmds)
                )



--TODO this sucks!


knobToCmd : KnobModel -> Cmd msg
knobToCmd knob =
    case knob.id of
        "id_attack" ->
            melodySetAttack knob.value

        "id_release" ->
            melodySetRelease knob.value

        x ->
            Debug.crash ("Knob id " ++ x ++ " is not supported")


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
    let
        renderedKnobs =
            List.map renderKnob model.knobs
    in
        div [ (class "melody") ] ((renderWaveform model) :: renderedKnobs)


renderKnob : KnobModel -> Html Msg
renderKnob model =
    div [ (class "controls") ]
        [ h4 [] [ (text model.label) ]
        , div [ (class "control"), (id model.id) ] [ text "" ]
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


subscriptions : Model -> Sub Msg
subscriptions model =
    melodyUpdateKnob UpdateKnob
