
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