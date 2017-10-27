module GridTest exposing (..)

import Expect
import Grid exposing (..)
import Matrix
import Test exposing (Test, describe, test)


-- import Grid.GridType exposing (..)


drumGridModel : Grid.Model
drumGridModel =
    Grid.initModel Grid.Drums 4 4 2


bassGridModel : Grid.Model
bassGridModel =
    Grid.initModel Grid.Bass 4 4 2


melodyGridModel : Grid.Model
melodyGridModel =
    Grid.initModel Grid.Melody 4 4 2


matrix : Matrix.Matrix Cell
matrix =
    Matrix.fromList
        [ [ Off, Off, Off, Off ]
        , [ Off, Off, Off, Off ]
        , [ Off, Off, Off, Off ]
        , [ Off, Off, Off, Off ]
        ]


suite : Test
suite =
    describe "With the Grid module"
        [ describe "creating Grid model"
            [ test "the correct type should be set for a bass model" <|
                \_ ->
                    Expect.equal Grid.Bass bassGridModel.gridType
            , test "the correct type should be set for a drum model" <|
                \_ ->
                    Expect.equal Grid.Drums drumGridModel.gridType
            , test "the correct type should be set for a melody model" <|
                \_ ->
                    Expect.equal Grid.Melody melodyGridModel.gridType
            , test
                ("The matrix should contain the proper number of cells "
                    ++ "and the cells should all be Off"
                )
              <|
                \_ ->
                    Expect.equal matrix bassGridModel.grid
            , test "the coumns should be set right" <|
              \
            ]
        ]
