module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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
    { grid = (List.repeat 12 (List.repeat 16 False)) }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


type alias Model =
    { grid : List (List Bool) }


type alias Note =
    { pitch : Maybe Int
    , velocity : Maybe Int
    }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Patternator" ]
        , div [ (class "grid") ] (rendergrid model.grid)
        ]


rendergrid : List (List Bool) -> List (Html Msg)
rendergrid grid =
    List.map (\l -> (renderLine l)) grid


renderLine : List Bool -> Html Msg
renderLine l =
    let
        style bool =
            if bool then
                "cell selected"
            else
                "cell"

        cells =
            List.map (\bool -> div [ (class (style bool)) ] []) l
    in
        div [ (class "row") ] cells



-- CSS STYLES


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }



-- subscriptions


subscriptions : Model -> Sub.Sub Msg
subscriptions model =
    Sub.none
