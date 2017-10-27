module MatrixUtil exposing (getRow, getColumn, mapCell)

import Matrix exposing (Location, Matrix, matrix)
import Util exposing (listOfMaybeToMaybeOfList)


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
