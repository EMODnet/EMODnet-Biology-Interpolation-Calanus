# Configuration file for the analysis

using PyCall
mpl = PyCall.pyimport("matplotlib")
mpl.style.use("../src/calanus.mplstyle")

# Type of analysis
run_year = true
run_month = true
analysistype = "multivariate"

title = "Calanus interpolation parameters"

# Switches for plotting
makeplot = false
usecartopy = false

# Domain and resolution
yearmin = 1959
yearmax = 2018
domain = [-20.5, 11.75, 41.25, 67.0]
dlon = 0.25
dlat = 0.25
@info("Workig at resoluton $(dlon)° X $(dlat)°")

# Directories
datadir = "../data/"
figdir = "../figures/$(analysistype)/"
resdir = "../results/$(analysistype)/025deg/"
datafigdir = joinpath(figdir, "observations/")
resfigdir = joinpath(figdir, "025deg/")
wodfigdir = joinpath(figdir, "WOD/")
resdirnc = joinpath(resdir, "netCDF")
resdirtif = joinpath(resdir, "GeoTIFF")

# Create if necessary
isdir(resdir) ? @debug("already there") : mkpath(resdir)
isdir(resdirnc) ? @debug("already there") : mkpath(resdirnc)
isdir(resdirtif) ? @debug("already there") : mkpath(resdirtif)
isdir(figdir) ? @debug("already there") : mkpath(figdir)
isdir(datafigdir) ? @debug("already there") : mkpath(datafigdir)
isdir(wodfigdir) ? @debug("already there") : mkpath(wodfigdir)

# Files 
datafile = joinpath(datadir, "MBA_CPRdata_Emodnet_21Jan22.csv")
datafileURL = "https://dox.ulg.ac.be/index.php/s/hjWKf1F3C1Pzz1r/download"
bathyfile = joinpath(datadir, "gebco_30sec_16.nc")
bathyfileURL = "https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download"
temperaturefile = joinpath(datadir, "temperature_surface_WOD2.nc")
temperaturefileURL = "https://dox.ulg.ac.be/index.php/s/aksXIhEFk41npCb/download"

# Download if necessary
isfile(datafile) ? @info("Observation file already downloaded") : download(datafileURL, datafile)
isfile(bathyfile) ? @info("Bathymetry file already downloaded") : download(bathyfileURL, datbathyfile)
(analysistype == "multivariate") & !(isfile(temperaturefile)) ? download(temperaturefileURL, temperaturefile) : @info("Temperature file already downloaded")

# Colors 
# (to keep homogeneity accross the figures)
mycolor = "#6667AB" ;
mycolor2 = "#456A30"; # Green treetop
