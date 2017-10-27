module Util exposing (..)


joinStrings : String -> (List String -> String)
joinStrings inject =
    List.intersperse inject >> String.concat



-- TODO: dit kan vermoedelijk veel beter met `Maybe.map head`


listOfMaybeToMaybeOfList : List (Maybe a) -> Maybe (List a)
listOfMaybeToMaybeOfList list =
    let
        head =
            (List.head list)

        rest =
            (List.drop 1 list)
    in
        case head of
            Just aMaybeA ->
                case aMaybeA of
                    Just a ->
                        listOfMaybeToMaybeOfList rest |> Maybe.map (\l -> a :: l)

                    Nothing ->
                        Nothing

            Nothing ->
                Just []
