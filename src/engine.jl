# the game engine logic



function launch()

    while true
        # run systems in order

        # input system - get user input
        # movement system - manipulate active tetromino (can mark as inactive)
        # falling system - periodically move active tetromino down (can mark as inactive)
        # line check system - check for completed lines and clear them; 
        #    if a line is cleared, move all lines above it down 1 grid unit
        #    add to score based on number of lines cleared
        # score system - update score based on line clear events
        # spawn system - if there is no active tetromino, spawn a new one. if the spawn is invalid, end the game
        # render system - draw the board and the active tetromino
    end
end