module PlottingCalanus

using Dates
using DelimitedFiles 
using NCDatasets
using DIVAnd
using PyCall
using PyPlot
const plt = PyPlot

cartopy = PyCall.pyimport("cartopy")
ccrs = PyCall.pyimport("cartopy.crs")
cfeature = PyCall.pyimport("cartopy.feature")
mticker = PyCall.pyimport("matplotlib.ticker")
coast = cfeature.GSHHSFeature(scale="full");
cartopyticker = PyCall.pyimport("cartopy.mpl.ticker")
lon_formatter = cartopyticker.LongitudeFormatter()
lat_formatter = cartopyticker.LatitudeFormatter()
datacrs = ccrs.PlateCarree()


"""
    make_plot_analysis(longrid, latgrid, fieldinterp, figtitle, figname, theproj)

Create a plot to display the analysed field on the map.

## Examples
```julia-repl
julia> make_plot_analysis(longrid, latgrid, f_finmarchicus, "Calanus finmarchicus analysis", figname, theproj)
```
"""
function make_plot_analysis(longrid, latgrid, fieldinterp::Matrix{Float64}, 
    figtitle::String="", figname::String="", theproj=ccrs.PlateCarree())

    llon, llat = DIVAnd.ndgrid(longrid, latgrid)

    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111, projection=theproj)

    ax.set_extent([longrid[1], longrid[end], latgrid[1], latgrid[end]], crs=datacrs)

    pcm = ax.pcolor(llon, llat, fieldinterp, 
            cmap=plt.cm.hot_r, vmin=0., vmax=50., transform=datacrs)
    cb = plt.colorbar(pcm, extend="max")

    ax.add_feature(coast, facecolor="#363636", edgecolor="k", zorder=5)

    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=true,
                        linewidth=.5, color="gray", alpha=1, linestyle="--")
    gl.top_labels = false
    gl.right_labels = false
    gl.xformatter = lon_formatter
    gl.yformatter = lat_formatter
    gl.xlabel_style = Dict("size" => 10)
    gl.ylabel_style = Dict("size" => 10)

    if length(figtitle) > 0
        ax.set_title(figtitle)
    end

    if length(figname) > 0
        plt.savefig(figname, dpi=300, bbox_inches="tight")
        plt.close()
    else
        plt.show()
    end
end

"""
    make_plot_error(longrid, latgrid, error, londata, latdata, figtitle, figname, theproj)

Create a plot to display the analysed field on the map.

## Examples
```julia-repl
julia> make_plot_error(longrid, latgrid, error, londata, latdata, figtitle, figname, theproj)
```
"""
function make_plot_error(longrid, latgrid, error::Matrix{Float64}, 
    londata::Vector, latdata::Vector,
    figtitle::String="", figname::String="", theproj=ccrs.PlateCarree())

    cmap = plt.cm.get_cmap("Reds", 10)

    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111, projection=theproj)
    pcm = ax.pcolormesh(longrid, latgrid, error', 
            cmap=cmap, vmin=0., vmax=1., transform=datacrs)

    scat = ax.scatter(londata, latdata, s=1, c="k", linewidth=.2, transform=datacrs)

    cb = plt.colorbar(pcm)

    ax.add_feature(coast, facecolor="#363636", edgecolor="k", zorder=5)

    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=true,
                        linewidth=.5, color="gray", alpha=1, linestyle="--")
    gl.top_labels = false
    gl.right_labels = false
    gl.xformatter = lon_formatter
    gl.yformatter = lat_formatter
    gl.xlabel_style = Dict("size" => 10)
    gl.ylabel_style = Dict("size" => 10)

    ax.set_extent([longrid[1], longrid[end], latgrid[1], latgrid[end]])

    if length(figtitle) > 0
        ax.set_title(figtitle)
    end

    if length(figname) > 0
        plt.savefig(figname, dpi=300, bbox_inches="tight")
        plt.close()
    else
        plt.show()
    end
end

"""
    make_plot_data_analysis(longrid, latgrid, error, londata, latdata, figtitle, figname, theproj)

Create a plot to display the analysed field on the map and the corresponding data points.

## Examples
```julia-repl
julia> make_plot_data_analysis(longrid, latgrid, field, londata, latdata, fielddata, figtitle, figname, theproj)
```
"""
function make_plot_data_analysis(longrid, latgrid, fieldinterp::Matrix{Float64}, 
    londata::Vector, latdata::Vector, fieldata::Vector, 
    figtitle::String="", figname::String="", theproj=ccrs.PlateCarree())

    llon, llat = ndgrid(longrid, latgrid)

    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111, projection=theproj)
    ax.set_extent([longrid[1], longrid[end], latgrid[1], latgrid[end]])


    pcm = ax.pcolor(llon, llat, fieldinterp', 
            cmap=plt.cm.hot_r, vmin=0., vmax=50., transform=datacrs)

    scat = ax.scatter(londata, latdata, s=1, c=fieldata, 
                    cmap=plt.cm.hot_r, vmin=0., vmax=50., transform=datacrs)

    cb = plt.colorbar(pcm, extend="max")

    ax.add_feature(coast, facecolor="#363636", edgecolor="k", zorder=5)

    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=true,
                        linewidth=.5, color="gray", alpha=1, linestyle="--")
    gl.top_labels = false
    gl.right_labels = false
    gl.xformatter = lon_formatter
    gl.yformatter = lat_formatter
    gl.xlabel_style = Dict("size" => 10)
    gl.ylabel_style = Dict("size" => 10)
        
    if length(figtitle) > 0
        ax.set_title(figtitle)
    end

    if length(figname) > 0
        plt.savefig(figname, dpi=300, bbox_inches="tight")
        plt.close()
    else
        plt.show()
    end
end


end