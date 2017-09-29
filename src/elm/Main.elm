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


initalModel : Model
initalModel =
    { grid = matrix 12 16 (\_ -> False)
    , selectedColumn = 0
    , bpm = 100
    , running = False
    , blink = False
    }


init : ( Model, Cmd Msg )
init =
    ( initalModel, Cmd.none )


type alias Model =
    { grid : Matrix Bool
    , selectedColumn : Int
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
                newSelectedColumn =
                    if model.running then
                        (model.selectedColumn + 1) % 16
                    else
                        model.selectedColumn
            in
                ( { model
                    | selectedColumn = newSelectedColumn
                    , blink = not model.blink
                  }
                , Cmd.none
                )

        TransportMsg msg ->
            handleTransportMsg msg model


handleTransportMsg : TransportMsgType -> Model -> ( Model, Cmd Msg )
handleTransportMsg msg model =
    case msg of
        ToggleTransport ->
            ( { model | running = not model.running }, Cmd.none )

        Rewind ->
            ( { model | selectedColumn = 0 }, Cmd.none )

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
