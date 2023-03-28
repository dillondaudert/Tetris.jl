
# Notes for Tetris
We want to implement this at least partially using an ECS design.

## Entities
The various entities in Tetris might be the following:
- The `cells` - occupied locations on the grid. These can be the static boundary cells,
    the active tetromino cells (associated group of 4), and the locked cells at the bottom
    of the game (inactive tetromino cells). 
- A `tetromino`, which is a meta entity containing 4 `cell`s. It has an identity (like `L`)
    which determines cell color and how the cells move together when translated/rotated.
- The `score`, which displays the player's current score.
- The `ghost tetromino` which displays where the active tetromino will end up if it 
    completes its fall.

## Components
- A `PositionComponent`, which encodes a location (x, y) on the game board.
- A `RenderComponent` containing information for rendering an entity
- Some way to identify 'inactive' cells (cells that the player has no control over)
- Some way to identify the 'active' tetramino (4 cells) controllable by the player

## Systems
- `InputSystem` - converts user input to actions that manipulate the active tetromino
- `MovementSystem` - update the position of the active tetromino based on user actions
- `FallingSystem` - periodically (based on a variable timestep; difficulty) move the 
    active tetromino down 1 row
- A system which checks the inactive cells for complete lines and deletes lines
- `ScoringSystem` - updates the score based on line completion events