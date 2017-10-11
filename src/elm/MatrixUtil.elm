module MatrixUtil exposing (getRow, getColumn, mapCell, listOfMaybeToMaybeOfList)

import Matrix exposing (Location, Matrix, matrix)


getRow : Int -> Matrix a -> Maybe (List a)
getRow index aMatrix =
    if indexInRange index (Matrix.rowCount aMatrix) then
        Matrix.toList aMatrix
            |> List.drop index
            |> List.head
    else
        Nothing


getColumn : Int -> Matrix a -> Maybe (List a)
getColumn index aMatrix =
    if indexInRange index (Matrix.colCount aMatrix) then
        Matrix.toList aMatrix
            |> List.map (\row -> row |> List.drop index |> List.head)
            |> listOfMaybeToMaybeOfList
    else
        Nothing


indexInRange : Int -> Int -> Bool
indexInRange index size =
    index >= 0 && index < size


mapCell : Location -> (a -> a) -> Matrix a -> Matrix a
mapCell location fn matrix =
    Matrix.mapWithLocation
        (\aLoc anA ->
            if aLoc == location then
                (fn anA)
            else
                anA
        )
        matrix



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
