# game logic functionality for tetris.

# TODO: Represent the tetrominos somehow. Enum ? Struct ?

##### GAMEPLAY LOGIC #####

"""
    move_tetromino

Move a tetromino in a given direction (translation) or rotate it (rotation).
This needs to know the state of the board to determine if a move is valid, as well as
the current position and orientation of the tetromino.

This should implement the SRS (Super Rotation System) required for tetris.

Given a board and a tetromino, attempt to move or rotate the tetromino. This function
should return a new tetromino with the new position and orientation, or the old tetromino.
"""
function move_tetromino end

# try to translate the tetromino; returns a new Tetromino instance with updated (or same) origin
function move_tetromino(board::TetrisBoard, tetromino, ::Translation) end

# try to rotate the tetromino; returns a new Tetromino instance with updated (or same) orientation
function move_tetromino(board::TetrisBoard, tetromino, rot::R) where {R <: Union{::Val{:clockwise}, ::Val{:counterclockwise}}} 
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
    get_next_tetromino

Randomly select a tetromino.
This function should guarantee that the player never receives more than four 'S' and 'Z' pieces in a row.
"""
function get_next_tetromino end

##### GAME REPRESENTATION #####

struct TetrisBoard
    grid::Array{Bool, 2} # grid of cells representing occupancy of the board
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
