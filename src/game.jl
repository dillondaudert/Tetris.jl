# game logic functionality for tetris.

##### PLAYER ACTIONS #####

abstract type PlayerAction end
struct TranslateAction <: PlayerAction
    dir::Vec2{Int}
end
struct RotateAction <: PlayerAction
    rot::Symbol
end

##### GAME REPRESENTATION #####

"""
    TetrisBoard

A struct representing the state of the game board.
    `grid` - 2D array of bools representing cell occupancy; this includes hidden or fixed cells
    `play_area` - the indices of the grid that denote the play area

Note that index (1, 1) on the board denotes the top left corner of the grid.
"""
mutable struct TetrisGame
    grid::Array{Bool, 2} # grid of cells representing occupancy of the board; this includes hidden or fixed cells
    play_area::CartesianIndices{2} # the indices of the grid that denote the play area
    score::Int # the current score
    tetromino::Union{Nothing, Tetromino} # the current active tetromino, or nothing if there is none
    game_over::Bool
    player_action::Union{Nothing, PlayerAction}
    lock_delay::Int
    gravity::Rational{Int} # the gravity of the game, in cells over frames
    gravity_delay::Int # the number of frames since the last gravity update
end
function TetrisGame()
    grid = trues(42, 12) # 40 rows, 10 cols; border of fixed cells
    play_area = CartesianIndices((2:41, 2:11))
    grid[play_area] .= false
    TetrisGame(grid, play_area, 0, nothing, false, nothing, 0, 1//30, 0)
end

##### GAMEPLAY LOGIC #####

function update!(game::TetrisGame)
    # update 1 frame of the game
    
    # player manipulates active tetromino
    do_player_action!(game, game.player_action)
    # gravity / falling
    do_gravity!(game)
    # check for completed lines and clear them
    do_line_clear!(game)
    # if there is no active tetromino, spawn a new one
    spawn_tetromino!(game)
end

"""
    do_player_action!

Handle player input to move or rotate the active tetromino.
"""
do_player_action!(::TetrisGame, ::Nothing) = nothing

function do_player_action!(game::TetrisGame, action::TranslateAction)
    game.player_action = nothing
    # shift the active tetromino in a given direction
    if isnothing(game.tetromino)
        return
    end
    # attempt to shift the tetromino
    new_tetromino = move_tetromino(game, game.tetromino, action.dir)
    # if attempting to shift downwards, lock the tetromino if it cannot be shifted
    if action.dir == Vec2(1, 0) && new_tetromino == game.tetromino
        # lock tetromino
        lock_tetromino!(game, game.tetromino)
    end
    game.tetromino = new_tetromino
    return
end

function do_player_action!(game::TetrisGame, action::RotateAction)
    game.player_action = nothing
    # rotate the active tetromino in a given direction
    if isnothing(game.tetromino)
        return
    end
    # attempt to rotate the tetromino
    game.tetromino = move_tetromino(game, game.tetromino, Val(action.rot))
    return
end

"""
    do_gravity!

Handle gravity for the active tetromino.
"""
function do_gravity!(game::TetrisGame)
    # if there is no active tetromino, do nothing
    if isnothing(game.tetromino)
        return
    end
    
    # attempt to shift the tetromino downwards
    down_shift = Vec2(numerator(game.gravity), 0)
    new_tetromino = move_tetromino(game, game.tetromino, down_shift)
    # if the tetromino cannot be shifted downwards, increment lock delay or lock
    if new_tetromino == game.tetromino
        # lock delay
        game.lock_delay += 1
        if game.lock_delay >= 30
            # lock tetromino
            lock_tetromino!(game, game.tetromino)
        end
    else
        # increment gravity delay
        game.gravity_delay += 1
        if denominator(game.gravity) > game.gravity_delay
            # wait a number of frames equal to the denominator
            return
        end
        game.gravity_delay = 0
        # successfully shift downwards
        game.lock_delay = 0
        game.tetromino = new_tetromino
    end
    return
end

function do_line_clear!(game::TetrisGame)
    # check for completed lines and clear them
    # TODO
    return
end



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
function move_tetromino(board::TetrisGame, tetromino::Tetromino, translation::Vec2{Int})
    new_tetromino = translate(tetromino, translation)
    if is_valid_position(board, new_tetromino)
        return new_tetromino
    end 
    return tetromino
end

# try to rotate the tetromino; returns a new Tetromino instance with updated (or same) orientation
function move_tetromino(board::TetrisGame, tetromino::Tetromino, rot::R) where {R <: Union{Val{:clockwise}, Val{:counterclockwise}}} 
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
function is_valid_position(board::TetrisGame, tetromino)
    # check if the tetromino is in a valid position on the board
    # this means that all of its cells are within the bounds of the board and are not occupied
    tetro_cells = get_cells(tetromino)
    return is_inbounds(board, tetro_cells) && !is_occupied(board, tetro_cells)
end

"""
    is_inbounds

Check if any of the cells are out of bounds.
"""
function is_inbounds(board::TetrisGame, cells)
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
function is_occupied(board::TetrisGame, cells)
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
This function should guarantee that the player never receive more than four 'S' and 'Z' pieces in a row.
"""
function get_next_tetromino()
    # TODO: actually implement sampling logic
    return rand([Tetrominos.I, Tetrominos.J, Tetrominos.L, Tetrominos.O, Tetrominos.S, Tetrominos.T, Tetrominos.Z])
end

function spawn_tetromino!(board::TetrisGame)

    if !isnothing(board.tetromino)
        return
    end
    # spawn a tetromino on the board
    # this means that the tetromino is placed at the top of the board, centered horizontally
    # returns the active tetromino

    # instantiate the next type of tetromino to be spawned
    TetT = get_next_tetromino()
    # instantiate the tetromino with the correct origin and orientation
    tetromino = _spawn_tetromino(TetT)
    board.tetromino = tetromino
    @info "Spawning a new tetromino: $(board.tetromino)"

    # if the active tetromino is not in a valid position, the game is over (BLOCK OUT)
    if !is_valid_position(board, tetromino)
        @debug "BLOCK OUT: Tried to spawn a tetromino in an invalid position."
        board.game_over = true
    end
    return
end

function _spawn_tetromino(::Type{T}) where {T <: Tetromino}
    # instantiate the tetromino with the correct origin and orientation
    # this is a helper function for spawn_tetromino

    # the grid is 42 x 12
    # in the play area, the spawn origin is (19, 4) - 2 rows above the play area (rows 21-40)
    # and the 4 center columns (1 2 3 [4 5 6 7] 8 9 10)
    # since we have an extra row and column for the border, we need to add 1 to the row and column indices
    origin = (20, 5)
    return T{Tetrominos.Up}(origin)
end

"""
    lock_tetromino

Lock a tetromino in place on the board.
"""
function lock_tetromino!(board::TetrisGame, tetromino)
    # lock the tetromino in place on the board
    # this means that all of its cells are added to the board grid
    # and the tetromino is removed from the board

    # add the tetromino's cells to the board grid
    for cell in get_cells(tetromino)
        board.grid[CartesianIndex(cell...)] = true
    end
    # remove the tetromino from the board
    board.tetromino = nothing

    # if this tetromino was locked completely above the visible play area, the game is over (LOCK OUT)
    if all(getindex.(get_cells(tetromino), 1) .< 22)
        @debug "LOCK OUT: Tried to lock a tetromino completely above the visible play area."
        board.game_over = true
    end
    return
end

function drop_tetromino(game::TetrisGame, tetromino::Tetromino)
    # drop the tetromino as far as it can go
    # this means that the tetromino is translated down until it is in an invalid position
    # returns the tetromino with the new origin

    new_tetromino = translate(tetromino, Vec2((0, 1)))
    while is_valid_position(game, new_tetromino)
        tetromino = new_tetromino
        new_tetromino = translate(tetromino, Vec2((0, 1)))
    end
    return tetromino
end


function get_shadow(game::TetrisGame)
    # get the shadow of the active tetromino
    # this is the position where the tetromino would fall if it were dropped
    # returns a tetromino with the same type as the active tetromino, but with the shadow origin

    if isnothing(game.tetromino)
        return nothing
    end

    shadow_tetromino = drop_tetromino(game, game.tetromino)
    return shadow_tetromino
end