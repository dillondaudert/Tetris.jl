module Tetrominos

export Tetromino, rotate, translate, get_cells, get_kicks

using GeometryTypes
# tetromino representation

abstract type Orientation end
struct Up <: Orientation end
struct Down <: Orientation end
struct Left <: Orientation end
struct Right <: Orientation end

"""
    Tetromino{Q <: Orientation}

Abstract type for all tetrominos. The type parameter Q is the orientation of the tetromino.
All subtypes of Tetromino must have a field `origin` of type `Point2{Int}`.
This corresponds to the origin of the "bounding box" of the tetromino, not to the 
tetromino's center of rotation OR to a particular cell of the tetromino. The
cells of the tetromino are offset from its origin according to the orientation.
"""
abstract type Tetromino{Q <: Orientation} end

# generate all the tetromino structs
for TetT in [:I, :O, :T, :J, :L, :S, :Z]
    eval(quote
        struct $TetT{Q <: Orientation} <: Tetromino{Q}
            origin::Point2{Int}
        end
    end)
end


# generate rotation functions; for each direction and rotation, 
# generate a function that takes a Tetromino of that direction and
# returns a Tetromino of the new direction
# TODO: Test Me
for (dir, rot, newdir) in ((Up, "clockwise", Right),
                           (Right, "clockwise", Down),
                           (Down, "clockwise", Left),
                           (Left, "clockwise", Up),
                           (Up, "counterclockwise", Left),
                           (Left, "counterclockwise", Down),
                           (Down, "counterclockwise", Right),
                           (Right, "counterclockwise", Up))
    eval(quote
        function rotate(t::T, ::Val{Symbol($rot)}) where {T <: Tetromino{$dir}}
            TetType = T.name.wrapper
            return TetType{$newdir}(t.origin)
        end
    end)
end

function translate(t::T, dir::Tuple{Int, Int}) where {T <: Tetromino}
    return T(t.origin .+ dir)
end

# TODO: Test me 
# O tetromino
get_cells(t::O) = (t.origin,) .+ (Point2(1, 1), Point2(1, 2), Point2(2, 1), Point2(2, 2))

# I tetromino
get_cells(t::I{Up}) = (t.origin,) .+ (Point2(1, 0), Point2(1, 1), Point2(1, 2), Point2(1, 3))
get_cells(t::I{Right}) = (t.origin,) .+ (Point2(0, 2), Point2(1, 2), Point2(2, 2), Point2(3, 2))
get_cells(t::I{Down}) = (t.origin,) .+ (Point2(2, 0), Point2(2, 1), Point2(2, 2), Point2(2, 3))
get_cells(t::I{Left}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 1), Point2(2, 1), Point2(3, 1))

# J tetromino
get_cells(t::J{Up}) = (t.origin,) .+ (Point2(0, 0), Point2(1, 0), Point2(1, 1), Point2(1, 2))
get_cells(t::J{Right}) = (t.origin,) .+ (Point2(0, 1), Point2(0, 2), Point2(1, 1), Point2(2, 1))
get_cells(t::J{Down}) = (t.origin,) .+ (Point2(1, 0), Point2(1, 1), Point2(1, 2), Point2(2, 2))
get_cells(t::J{Left}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 1), Point2(2, 1), Point2(2, 0))

# L tetromino
get_cells(t::L{Up}) = (t.origin,) .+ (Point2(1, 0), Point2(1, 1), Point2(1, 2), Point2(2, 0))
get_cells(t::L{Right}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 1), Point2(2, 1), Point2(2, 2))
get_cells(t::L{Down}) = (t.origin,) .+ (Point2(1, 0), Point2(1, 1), Point2(1, 2), Point2(2, 0))
get_cells(t::L{Left}) = (t.origin,) .+ (Point2(0, 0), Point2(0, 1), Point2(1, 1), Point2(2, 1))

# S tetromino
get_cells(t::S{Up}) = (t.origin,) .+ (Point2(0, 1), Point2(0, 2), Point2(1, 0), Point2(1, 1))
get_cells(t::S{Right}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 1), Point2(1, 2), Point2(2, 2))
get_cells(t::S{Down}) = (t.origin,) .+ (Point2(1, 1), Point2(1, 2), Point2(2, 0), Point2(2, 1))
get_cells(t::S{Left}) = (t.origin,) .+ (Point2(0, 0), Point2(1, 0), Point2(1, 1), Point2(2, 1))

# Z tetromino
get_cells(t::Z{Up}) = (t.origin,) .+ (Point2(0, 0), Point2(0, 1), Point2(1, 1), Point2(1, 2))
get_cells(t::Z{Right}) = (t.origin,) .+ (Point2(0, 2), Point2(1, 1), Point2(1, 2), Point2(2, 1))
get_cells(t::Z{Down}) = (t.origin,) .+ (Point2(1, 0), Point2(1, 1), Point2(2, 1), Point2(2, 2))
get_cells(t::Z{Left}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 0), Point2(1, 1), Point2(2, 0))

# T tetromino
get_cells(t::T{Up}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 0), Point2(1, 1), Point2(1, 2))
get_cells(t::T{Right}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 1), Point2(1, 2), Point2(2, 1))
get_cells(t::T{Down}) = (t.origin,) .+ (Point2(1, 0), Point2(1, 1), Point2(1, 2), Point2(2, 1))
get_cells(t::T{Left}) = (t.origin,) .+ (Point2(0, 1), Point2(1, 0), Point2(1, 1), Point2(2, 1))

# We choose to represent this as data instead of code ( like above ). Unclear at this point
# if there's a major difference in terms of ergonomics or performance.
# NOTE: in the documentation of the wall kicks, they use the following convention:
#       DOCS: positive x is to the right, positive y is upwards. WE REVERSE Y and instead use:
#       HERE: POSITIVE X IS TO THE RIGHT, POSITIVE Y IS DOWNWARDS
# NOTE: the counterclockwise kick data is the same as the clockwise kick data for the destination
#       orientation, but with the x and y coordinates reversed. We don't store it explicitly, but 
#       instead just reverse the x and y coordinates when we need it.
# TODO: Test these in the test suite - each tetromino, orientation, rotation combination (7 * 8)
const KICK_DATA = Dict(
    # I tetromino has special rules
    (:I, :Up, :clockwise) => ((0, 0), (-2, 0), (1, 0), (-2, 1), (1, -2)),
    (:I, :Right, :clockwise) => ((0, 0), (-1, 0), (2, 0), (-1, -2), (2, 1)),
    (:I, :Down, :clockwise) => ((0, 0), (2, 0), (-1, 0), (2, -1), (-1, 2)),
    (:I, :Left, :clockwise) => ((0, 0), (1, 0), (-2, 0), (1, 2), (-2, -1)),
    # all other tetrominos use the same data
    (:T, :Up, :clockwise) => ((0, 0), (-1, 0), (-1, -1), (0, 2), (-1, 2)),
    (:T, :Right, :clockwise) => ((0, 0), (1, 0), (1, 1), (0, -2), (1, -2)),
    (:T, :Down, :clockwise) => ((0, 0), (1, 0), (1, -1), (0, 2), (1, 2)),
    (:T, :Left, :clockwise) => ((0, 0), (-1, 0), (-1, 1), (0, -2), (-1, -2))
)

end # module