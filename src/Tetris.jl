module Tetris

using Logging
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

logger = SimpleLogger(stderr, Logging.Debug)
global_logger(logger)

# game description:
# 1. the game is played on a 10x20 grid
# 2. a random tetromino is generated at the top of the grid
# 3. the player can move the tetromino left, right, down, and rotate it
# 4. the tetromino is locked in place when it hits the bottom of the grid or another tetromino
# 5. when a row is filled, it is cleared and all rows above it are moved down
# 6. the game ends when a tetromino hits the top of the grid
# 7. the score is the number of rows cleared

# rule: the game must guarantee the player never receives more than four 'S' and 'Z' pieces in a row.
# scoring: single line: 100 points, double line: 300 points, triple line: 500 points, tetris: 800 points
#          back-to-back tetris: 1200 points

include("utils.jl")
include("tetrominos.jl")
using .Tetrominos

include("game.jl")
include("engine.jl")
include("render.jl")


end 
