"""
    @sdl_assert sdl_fn success_check_fn

Pass a closure representing a specific call to an SDL-related function, and a
function accepting the result of sdl_fn which returns a bool indicating if
sdl_fn executed successfully.
This function either raises an error which surfaces the result SDL_GetError on
failure or returns the result of the call to sdl_fn.
"""
macro sdl_assert(sdl_fn, success_check_fn)
    return quote
        local res
        try
            res = $(esc(sdl_fn))
        catch e
            throw(e)
        end

        if !$(esc(success_check_fn))(res)
            throw(ErrorException("Error encountered when calling SDL: $(unsafe_string(SDL_GetError()))"))
        end
        res
    end
end