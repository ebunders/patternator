module MainTest exposing (..)

import Expect exposing (Expectation)
import Matrix exposing (matrix)
import MatrixUtil exposing (listOfMaybeToMaybeOfList)
import Test exposing (..)


matrix : Matrix.Matrix Int
matrix =
    Matrix.fromList [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]


justList : List (Maybe Int)
justList =
    [ Just 1, Just 2, Just 3 ]


noList : List (Maybe Int)
noList =
    [ Just 1, Nothing, Just 3 ]


suite : Test
suite =
    describe "with the Matrix util"
        [ describe "function listOfMaybeToMaybeOfList"
            [ test "should map a list of Just a to a Just of list a" <|
                \_ ->
                    Expect.equal (Just [ 1, 2, 3 ]) (listOfMaybeToMaybeOfList justList)
            , test "should map a list of Just and Nothing to Nothing" <|
                \_ ->
                    Expect.equal Nothing (listOfMaybeToMaybeOfList noList)
            ]
        , describe "from a Matrix we expect to read"
            [ test "the first column as a list" <|
                \_ ->
                    Expect.equal (Just [ 1, 4, 7 ]) (MatrixUtil.getColumn 0 matrix)
            , test "the second column as a list" <|
                \_ -> Expect.equal (Just [ 2, 5, 8 ]) (MatrixUtil.getColumn 1 matrix)
            , test "the third column as a list" <|
                \_ -> Expect.equal (Just [ 3, 6, 9 ]) (MatrixUtil.getColumn 2 matrix)
            , test "Nothing when the column index is too high" <|
                \_ -> Expect.equal Nothing (MatrixUtil.getColumn 3 matrix)
            , test "Nothing when the column index is under 0" <|
                \_ -> Expect.equal Nothing (MatrixUtil.getColumn -1 matrix)
            , test "the first row as a list" <|
                \_ ->
                    Expect.equal (Just [ 1, 2, 3 ]) (MatrixUtil.getRow 0 matrix)
            , test "the second row as a list" <|
                \_ -> Expect.equal (Just [ 4, 5, 6 ]) (MatrixUtil.getRow 1 matrix)
            , test "the third row as a list" <|
                \_ -> Expect.equal (Just [ 7, 8, 9 ]) (MatrixUtil.getRow 2 matrix)
            , test "Nothing when the row index is too high" <|
                \_ -> Expect.equal Nothing (MatrixUtil.getRow 3 matrix)
            , test "Nothing when the row index is under 0" <|
                \_ -> Expect.equal Nothing (MatrixUtil.getRow -1 matrix)
            ]
        ]
