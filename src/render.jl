
"""
    get_renderer_size(renderer::Ptr{SDL_Renderer})::Tuple{Int, Int}

Get the size of the renderer's draw area as a tuple (width, height).
"""
function get_renderer_size(renderer::Ptr{SDL_Renderer})::Tuple{Int, Int}
    # get renderer height, width
    renderer_w_ref = Ref{Int32}()
    renderer_h_ref = Ref{Int32}()
    @sdl_assert SDL_GetRendererOutputSize(renderer, renderer_w_ref, renderer_h_ref) res -> res == 0
    return renderer_w_ref[], renderer_h_ref[]
end

function render(app::GameEngine)
    # clear the screen, then render based on game state
    SDL_SetRenderDrawColor(app.renderer, 25, 25, 25, 255)
    SDL_RenderClear(app.renderer)

    _render(app.renderer, app.state)
    # draw the backbuffer
    SDL_RenderPresent(app.renderer)
    return
end

function _render(renderer, state::StartingState)
    # render the starting state countdown
    # get the time remaining
    time_remaining = Dates.Second(3) - (now() - state.started)
    # render the time remaining
    # TODO
    return
end

function _render(renderer, state::PlayState)
    # render the game

    # we render a 2d grid of cells, with the border colored in grey, and the tetrominos colored
    # according to their standard colors.
    W, H = get_renderer_size(renderer)

    PAD = 2 # padding between cells
    # grid sizing
    outer_height = H / size(state.game.grid, 1)
    outer_width = W / size(state.game.grid, 2)
    inner_height = outer_height - 2*PAD
    inner_width = outer_width - 2*PAD
    
    # render the grid
    for index in CartesianIndices(state.game.grid)
        row, col = index.I
        # draw the bounding rectangle
        SDL_SetRenderDrawColor(renderer, 100, 100, 100, 100)
        orig_x = (col-1) * outer_width
        orig_y = (row-1) * outer_height
        rect = Ref(SDL_FRect(orig_x, orig_y, outer_width, outer_height))
        SDL_RenderDrawRectF(renderer, rect)
        # if cell occupied, draw and fill the inner rectangle
        if state.game.grid[index]
            SDL_SetRenderDrawColor(renderer, 200, 200, 200, 200)
            cell_rect = Ref(SDL_FRect(orig_x + PAD, orig_y + PAD, inner_width, inner_height))
            SDL_RenderFillRectF(renderer, cell_rect)
        end
    end

    # now render the active tetromino
    if !isnothing(state.game.tetromino)
        # tetromino colors
        SDL_SetRenderDrawColor(renderer, get_tetromino_color(state.game.tetromino)...)
        # render the tetromino
        for (row, col) in get_cells(state.game.tetromino)
            # draw the cells making up this tetromino
            orig_x = (col-1) * outer_width + PAD
            orig_y = (row-1) * outer_height + PAD
            cell_rect = Ref(SDL_FRect(orig_x, orig_y, inner_width, inner_height))
            SDL_RenderFillRectF(renderer, cell_rect)
        end
    end
    return
end

function _render(renderer, state::PauseState)
    # render the game paused
    # TODO
    return
end

function _render(renderer, state::GameOverState)
    # render the game over state
    # TODO
    return
end

_render(renderer, state::QuitState) = nothing

get_tetromino_color(::Tetrominos.I) = (0, 255, 255, 255) # cyan
get_tetromino_color(::Tetrominos.O) = (255, 255, 0, 255) # yellow
get_tetromino_color(::Tetrominos.T) = (128, 0, 128, 255) # purple
get_tetromino_color(::Tetrominos.S) = (0, 255, 0, 255)   # green
get_tetromino_color(::Tetrominos.Z) = (255, 0, 0, 255)   # red
get_tetromino_color(::Tetrominos.J) = (0, 0, 255, 255)   # blue
get_tetromino_color(::Tetrominos.L) = (255, 127, 0, 255) # orange