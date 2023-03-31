# game logic functionality for tetris.

##### GAME REPRESENTATION #####

"""
    TetrisBoard

A struct representing the state of the game board.
    `grid` - 2D array of bools representing cell occupancy; this includes hidden or fixed cells
    `play_area` - the indices of the grid that denote the play area

Note that index (1, 1) on the board denotes the top left corner of the grid.
"""
mutable struct TetrisBoard
    grid::Array{Bool, 2} # grid of cells representing occupancy of the board; this includes hidden or fixed cells
    play_area::CartesianIndices{2} # the indices of the grid that denote the play area
    score::Int # the current score
end
function TetrisBoard()
    grid = trues(42, 12) # 40 rows, 10 cols; border of fixed cells
    play_area = CartesianIndices((2:41, 2:11))
    grid[play_area] .= false
    TetrisBoard(grid, play_area, 0)
end

# how should we represent the board?
# we have two seemingly different kinds of "objects": tetrominos, which have a position and orientation, and the board
# which has a grid of cells that can be empty or occupied by a (potentially partial) tetromino.
# Clearly, both of these things are made up of cells. The tetrominos need to move their cells together, but once they
#     are locked in place, their individual cells can be treated as separate (since they can be removed from the board
#     one by one). 

# when a tetromino is spawned, it creates 4 associated cells in a particular configuration (with other data like color).
#    when the tetromino moves, it moves all of its cells together. when it is locked in place, it is no longer
#    associated with the tetromino, and can be treated as separate cells.


##### GAMEPLAY LOGIC #####

"""
    move_tetromino

Move a tetromino in a given direction (translation) or rotate it (rotation).
This needs to know the state of the board to determine if a move is valid, as well as
the current position and orientation of the tetromino.

This implements the SRS (Super Rotation System) required for tetris.

Given a board and a tetromino, attempt to move or rotate the tetromino. This function
should return a new tetromino with the new position and orientation, or the old tetromino.
"""
function move_tetromino end

# try to translate the tetromino; returns a new Tetromino instance with updated (or same) origin
function move_tetromino(board::TetrisBoard, tetromino, translation)
    new_tetromino = translate(tetromino, translation)
    if is_valid_position(board, new_tetromino)
        return new_tetromino
    end 
    return tetromino
end

# try to rotate the tetromino; returns a new Tetromino instance with updated (or same) orientation
function move_tetromino(board::TetrisBoard, tetromino, rot::R) where {R <: Union{Val{:clockwise}, Val{:counterclockwise}}} 
    # SRS attempts to rotate using "wall kicks". 

    for kick in get_kicks(tetromino, rot)
        new_tetromino = translate(rotate(tetromino, rot), kick)
        if is_valid_position(board, new_tetromino)
            return new_tetromino
        end
    end
    return tetromino
end

"""
    is_valid_position

Check if a tetromino is in a valid position on the board.
"""
function is_valid_position(board::TetrisBoard, tetromino)
    # check if the tetromino is in a valid position on the board
    # this means that all of its cells are within the bounds of the board and are not occupied
    tetro_cells = get_cells(tetromino)
    return is_inbounds(board, tetro_cells) && !is_occupied(board, tetro_cells)
end

"""
    is_inbounds

Check if any of the cells are out of bounds.
"""
function is_inbounds(board::TetrisBoard, cells)
    # check if any of the cells are out of bounds
    # cells are Point2, play_area is the CartesianIndices of the play area
    for cell in cells
        if CartesianIndex(cell...) ∉ board.play_area
            return false
        end
    end
    return true
end

"""
    is_occupied

Check if any of the cells are occupied.
"""
function is_occupied(board::TetrisBoard, cells)
    # note this doesn't have bounds checking, so it should be called after is_inbounds
    for cell in cells
        if board.grid[CartesianIndex(cell...)]
            return true
        end
    end
    return false
end

"""
    get_next_tetromino

Randomly select a tetromino.
This function should guarantee that the player never receives more than four 'S' and 'Z' pieces in a row.
"""
function get_next_tetromino end
