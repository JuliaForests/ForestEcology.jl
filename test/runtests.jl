using ForestEcology
using Test

@testset "ForestEcology.jl" begin
  @testset "Community Structure" begin
    species = ["A", "B", "A", "C", "B", "A"]
    plots = [1, 1, 2, 2, 3, 3]
    dbh = [10.0, 15.0, 12.0, 20.0, 14.0, 11.0] * u"cm"
    area = 0.3u"ha"
    result = phytosociology(species, plots, dbh, area)
    @test size(result) == (3, 12)
    # Check exact categorical and integer outputs
    @test result.species == ["A", "B", "C"]
    @test result.n == [3, 2, 1]
    @test result.plots == [3, 2, 1]
    # Check Absolute Frequencies
    @test isapprox(result.AF, [100.0, 66.6667, 33.3333], atol=1e-4)
    # Check Relative Parameters (%)
    @test isapprox(result.RDe, [50.0, 33.3333, 16.6667], atol=1e-4)
    @test isapprox(result.RDo, [30.7757, 35.4975, 33.7268], atol=1e-4)
    @test isapprox(result.RF, [50.0, 33.3333, 16.6667], atol=1e-4)
    # Check Integrated Phytosociological Indices
    @test isapprox(result.VC, [80.7757, 68.8308, 50.3935], atol=1e-4)
    @test isapprox(result.IVI, [43.5919, 34.0547, 22.3534], atol=1e-4)
    # Validate logical totals
    @test isapprox(sum(result.RDe), 100.0, atol=1e-5)
    @test isapprox(sum(result.RDo), 100.0, atol=1e-5)
    @test isapprox(sum(result.RF), 100.0, atol=1e-5)
    # Test dimension mismatch error handling
    @test_throws DimensionMismatch phytosociology(["A"], [1, 2], [10.0u"cm"], area)
  end
end
