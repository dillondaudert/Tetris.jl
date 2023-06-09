# the game engine logic

"""
    AppState
An abstract type to represent the current state of the application.
"""
abstract type AppState end
# whenever we start a new game, or unpause, enter StartingState which counts down until
# the game begins
struct StartingState <: AppState
    started::DateTime
    game::TetrisGame
end
# represents an active game state
struct PlayState <: AppState
    game::TetrisGame
end
# pausing the game
struct PauseState <: AppState
    game::TetrisGame
end
# end of game state screen
struct GameOverState <: AppState
    game::TetrisGame
end
# the finalization state once we exit the application
struct QuitState <: AppState end

"""
    GameEngine
A mutable struct to represent the running game engine.
This will handle SDL initialization and teardown, contain the
game state, and any other engine-wide variables.
"""
mutable struct GameEngine
    # SDL variables
    sdl_initialized::Bool
    ttf_initialized::Bool
    window::Ptr{SDL_Window}
    renderer::Ptr{SDL_Renderer}
    # game state
    state::AppState
    # inner constructor that attaches the finalizer
    function GameEngine()
        obj = new(false, false, C_NULL, C_NULL, StartingState(now(), TetrisGame()))
        finalizer(obj) do self
            @async @debug "Destroying GameEngine $self; destroying SDL and TTF."
            shutdown!(self)
        end
    end
end

"""
    startup!(eng::GameEngine)
Initialize SDL and TTF, and create the main game window.
"""
function startup!(eng::GameEngine)
    # initialize SDL
    @sdl_assert SDL_Init(SDL_INIT_EVERYTHING) res -> res == 0
    eng.sdl_initialized = true
    # initialize TTF
    @sdl_assert TTF_Init() res -> res == 0
    eng.ttf_initialized = true
    # create window and renderer
    WIN_WIDTH, WIN_HEIGHT = 571, 1000
    eng.window = @sdl_assert SDL_CreateWindow("Tetris", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIN_WIDTH, WIN_HEIGHT, SDL_WINDOW_SHOWN) res -> res != C_NULL
    eng.renderer = @sdl_assert SDL_CreateRenderer(eng.window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC) res -> res != C_NULL
    return
end

"""
    shutdown!(eng::GameEngine)
Destroy the main game window and teardown SDL and TTF.
"""
function shutdown!(eng::GameEngine)
    # destroy renderer and window
    SDL_DestroyRenderer(eng.renderer)
    eng.renderer = C_NULL
    SDL_DestroyWindow(eng.window)
    eng.window = C_NULL
    # teardown TTF
    if eng.ttf_initialized
        TTF_Quit()
        eng.ttf_initialized = false
    end
    # teardown SDL
    if eng.sdl_initialized
        SDL_Quit()
        eng.sdl_initialized = false
    end
    return
end

transition_state!(app::GameEngine, state::AppState) = transition_state!(app, app.state, state)
# transition from starting to play based on time
function transition_state!(app::GameEngine, old_state::StartingState, ::StartingState)
    if now() - old_state.started >= Dates.Second(3)
        app.state = PlayState(old_state.game)
        @debug "Transitioning from $(typeof(old_state)) to $(typeof(app.state))"
    end
    return
end
# do nothing if the state is the same
transition_state!(::GameEngine, ::S, ::S) where {S <: AppState} = nothing
# else, change states
function transition_state!(app::GameEngine, ::AppState, new_state::AppState)
    @debug "Transitioning from $(typeof(app.state)) to $(typeof(new_state))"
    app.state = new_state
    return
end

# app update
function update!(app::GameEngine)
    update!(app, app.state)
    return
end
# nothing to update when the game starting, paused, game over, or quitting
function update!(::GameEngine, ::S) where {S <: Union{StartingState, PauseState, GameOverState, QuitState}}
    return
end

function update!(app::GameEngine, play::PlayState)
    # update game
    update!(play.game)
    # if the game is over, transition to game over state
    if play.game.game_over
        transition_state!(app, play, GameOverState(play.game))
    end
    return
end




function launch()

    app = GameEngine()
    startup!(app)
    @debug "Engine starting up"

    while !(app.state isa QuitState)
        # run systems in order

        # input system - get user input
        new_state = handle_input(app)

        transition_state!(app, new_state)

        # update game 1 frame
        update!(app)
        # movement system - manipulate active tetromino (can mark as inactive)
        # falling system - periodically move active tetromino down (can mark as inactive)
        # line check system - check for completed lines and clear them; 
        #    if a line is cleared, move all lines above it down 1 grid unit
        #    add to score based on number of lines cleared
        # score system - update score based on line clear events
        # spawn system - if there is no active tetromino, spawn a new one. if the spawn is invalid, end the game
        # render system - draw the board and the active tetromino
        render(app)

        SDL_Delay(1000 ÷ 60)
    end

    shutdown!(app)
end