
@testset "Tetrominos Tests" begin
    @test rotate(Tetrominos.I{Tetrominos.Up}((0, 0)), Val(:clockwise)) == Tetrominos.I{Tetrominos.Right}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Up}((0, 0)), Val(:counterclockwise)) == Tetrominos.I{Tetrominos.Left}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Left}((0, 0)), Val(:clockwise)) == Tetrominos.I{Tetrominos.Up}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Left}((0, 0)), Val(:counterclockwise)) == Tetrominos.I{Tetrominos.Down}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Down}((0, 0)), Val(:clockwise)) == Tetrominos.I{Tetrominos.Left}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Down}((0, 0)), Val(:counterclockwise)) == Tetrominos.I{Tetrominos.Right}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Right}((0, 0)), Val(:clockwise)) == Tetrominos.I{Tetrominos.Down}((0, 0))
    @test rotate(Tetrominos.I{Tetrominos.Right}((0, 0)), Val(:counterclockwise)) == Tetrominos.I{Tetrominos.Up}((0, 0))

    @testset "Kick Data Tests" begin
        # test that a counterclockwise rotation from SRC -> DST returns the same data as
        # a clockwise rotation from DST -> SRC, with signs flipped
        kick_counterclockwise = get_kicks(Tetrominos.I{Tetrominos.Right}((0, 0)), Val(:counterclockwise))
        kick_clockwise = get_kicks(Tetrominos.I{Tetrominos.Up}((0, 0)), Val(:clockwise))
        @test all(kick_counterclockwise .== (-1) .* kick_clockwise)
    end
end