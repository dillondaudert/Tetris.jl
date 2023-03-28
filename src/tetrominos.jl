module Tetrominos

using GeometryTypes
# tetromino representation

abstract type Orientation end
struct Up <: Orientation end
struct Down <: Orientation end
struct Left <: Orientation end
struct Right <: Orientation end

abstract type Tetromino{Q <: Orientation} end

struct I{Q} <: Tetromino{Q}
    origin::Point2{Int}
end

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

function get_cells(t::I)


end # module