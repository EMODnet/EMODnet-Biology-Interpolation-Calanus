using Test 
using Dates
using Statistics

include("../src/InterpCalanus.jl")

datadir = "../data/"
datafile = joinpath(datadir, "MBA_CPRdata_Emodnet_21Jan22.csv")
isfile(datafile) ? @debug("already downloaded") : download("https://dox.ulg.ac.be/index.php/s/hjWKf1F3C1Pzz1r/download", datafile)

@testset "data reading" begin

    @time lon, lat, dates, calanus_finmarchicus, calanus_helgolandicus = InterpCanalus.read_data_calanus(datafile);
    @test length(lon) == 146158
    @test lon[1] == 11.128
    @test lat[2] == 66.228
    @test dates[3] == Date("2009-06-01")
    @test calanus_finmarchicus[end] == 0
    @test calanus_helgolandicus[end] == 0
    @test mean(calanus_finmarchicus) == 6.663521668331564
end

@testset "dates" begin

    testdates = [Date(2009, 6, 1), Date(2009, 6, 5), Date(2010, 6, 1)]
    yearcount, monthcount = InterpCanalus.count_years_months(testdates)
    @test yearcount[1] == 2
    @test yearcount[2] == 1
    @test monthcount[6] == 3

end