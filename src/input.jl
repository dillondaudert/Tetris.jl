
function handle_input end

"""
    handle_input(state::AppState) -> AppState
Handle input events and return a new AppState to transition to.
"""
function handle_input(app::GameEngine)

    event_ref = Ref{SDL_Event}()
    
    while Bool(SDL_PollEvent(event_ref))
        event = event_ref[]
        type = SDL_EventType(event.type) # cast the Uint to an SDL_EventType
        # handle inputs (mostly mouse, but some keyboard events like ESC)
        # we want to change behavior based on app state.
        # @debug "Processing event for $type"
        result = handle_input(app.state, Val(type), event)

        if !isnothing(result)
            return result
        end 
    end
    # if we haven't returned a new state to transition to, return the current state 
    return app.state
end

handle_input(state, type, event) = nothing
handle_input(state, event, type, key) = nothing

# quit from anywhere whenever we receive a QUIT event
handle_input(::AppState, ::Val{SDL_QUIT}, _) = QuitState()

# handle keyboard events - we need to pull out the scancode of the button to dispatch
function handle_input(state::AppState, type::Val{SDL_KEYDOWN}, event)
    scancode = event.key.keysym.scancode
    # dispatch on state, SDL_KeyboardEvent, SDL_KEYDOWN, which key (scancode)
    return handle_input(state, event.key, type, Val(scancode))
end

# from the pause state, either resume the game or quit
handle_input(::PauseState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = QuitState()
handle_input(state::PauseState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_RETURN}) = StartingState(now(), state.game)

# during gameplay, we can pause or handle player actions
handle_input(state::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_ESCAPE}) = PauseState(state.game)
handle_input(state::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_LEFT}) = (state.game.player_action = TranslateAction((0, -1)); state)
handle_input(state::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_RIGHT}) = (state.game.player_action = TranslateAction((0, 1)); state)
handle_input(state::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_UP}) = (state.game.player_action = RotateAction(:clockwise); state)
handle_input(state::PlayState, ::SDL_KeyboardEvent, ::Val{SDL_KEYDOWN}, ::Val{SDL_SCANCODE_DOWN}) = (state.game.player_action = TranslateAction((1, 0)); state)