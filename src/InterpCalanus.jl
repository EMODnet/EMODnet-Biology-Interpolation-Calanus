module InterpCalanus

using Dates
using DelimitedFiles 
using NCDatasets
using GeoArrays
using TOML

if isfile("../Manifest.toml")
    juliaversion = TOML.parsefile("../Manifest.toml")["julia_version"]
    DIVAndversion = TOML.parsefile("../Manifest.toml")["deps"]["DIVAnd"][1]["version"]
else
    juliaversion = "1.8.0"
    DIVAndversion = "2.7.9"
end


"""
    read_data_calanus(datafile)

Read the data from a CSV data file containing the CPR data


## Examples
```julia-repl
julia> lon, lat, dates, c_fin, c_helgo = read_data_calanus("CPRfile.csv)
```
"""
function read_data_calanus(datafile::String)
    data = readdlm(datafile, ',', skipstart=1);

    lon = data[:,3]
    lat = data[:,2]
    year = data[:,4]
    month = data[:,5]
    dates = Date.(year, month)
    c_fin = data[:,6]
    c_helgo = data[:,7];
    @info(extrema(lon));
    @info(extrema(lat));
    
    return lon, lat, dates, c_fin, c_helgo
end

"""
    count_years_months(datesarray)

Count the number of occurrences of each month and each year from the array dates,
starting with the 1st year appearing in the list

## Examples
```julia-repl
julia> testdates = [Date(2009, 6, 1), Date(2009, 6, 5), Date(2010, 6, 1)]
julia> yearcount, monthcount = count_years_months(testdates)
([2.0, 1.0], [0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
```
"""
function count_years_months(dates::Array)
    
    year = Dates.year.(dates)
    month = Dates.month.(dates)
    
    nyears = maximum(year) - minimum(year) + 1
    yearcount = zeros(nyears)
    monthcount = zeros(12)
    
    ii = 0
    for yyyy in minimum(year):maximum(year)
        ii += 1
        yearcount[ii] = sum(year .== yyyy)
    end
    
    for mm in 1:12
        monthcount[mm] = sum(month .== mm)
    end
       
    return yearcount, monthcount
end

"""
    create_nc_results(filename, lons, lats, field, L, epsilon2, speciesname)

Write a netCDF file `filename` with the coordinates `lons`, `lats` and the
heatmap `field`. `speciesname` is used for the 'title' attribute of the netCDF.

## Examples
```julia-repl
julia> create_nc_results("Bacteriastrum_interp.nc", lons, lats, field,
    "Bacteriastrum")
```
"""
function create_nc_results(filename::String, lons, lats, times, field, L, epsilon2,
                           speciesname::String="";
                           valex=-999.9,
                           varname::String = "heatmap",
                           long_name::String = "Heatmap",
						   domain::Array = [-180., 180., -90., 90.],
						   aphiaID::Int32 = 0
                           )
    NCDatasets.Dataset(filename, "c") do ds

        # Dimensions
        ds.dim["lon"] = length(lons)
        ds.dim["lat"] = length(lats)
        ds.dim["time"] = Inf # unlimited dimension

        # Declare variables
		nccrs = defVar(ds, "crs", Int64, ())
    	nccrs.attrib["grid_mapping_name"] = "latitude_longitude"
    	nccrs.attrib["semi_major_axis"] = 6371000.0 ;
    	nccrs.attrib["inverse_flattening"] = 0 ;

        ncfield = defVar(ds, varname, Float64, ("lon", "lat"))
        ncfield.attrib["missing_value"] = Float64(valex)
        ncfield.attrib["_FillValue"] = Float64(valex)
		ncfield.attrib["units"] = "1"
        ncfield.attrib["long_name"] = long_name
		ncfield.attrib["coordinates"] = "lat lon"
		ncfield.attrib["grid_mapping"] = "crs" ;
        
        ncerror = defVar(ds, "$(varname)_error", Float64, ("lon", "lat"))
        ncerror.attrib["missing_value"] = Float64(valex)
        ncerror.attrib["_FillValue"] = Float64(valex)
		ncerror.attrib["units"] = "1"
        ncerror.attrib["long_name"] = "Relative error on $(long_name)"
		ncerror.attrib["coordinates"] = "lat lon"
		ncerror.attrib["grid_mapping"] = "crs" ;
        
        nctime = defVar(ds, "time", Int64, ("time",))
        nctime.attrib["missing_value"] = Float32(valex)
        nctime.attrib["units"] = "days since 1950-01-01 00:00:00"
        nctime.attrib["long_name"] = "time"
        
        nclon = defVar(ds,"lon", Float32, ("lon",))
        # nclon.attrib["missing_value"] = Float32(valex)
        nclon.attrib["_FillValue"] = Float32(valex)
        nclon.attrib["units"] = "degrees_east"
        nclon.attrib["long_name"] = "Longitude"
		nclon.attrib["standard_name"] = "longitude"
		nclon.attrib["axis"] = "X"
		nclon.attrib["reference_datum"] = "geographical coordinates, WGS84 projection"
		nclon.attrib["valid_min"] = -180.0 ;
		nclon.attrib["valid_max"] = 180.0 ;

        nclat = defVar(ds,"lat", Float32, ("lat",))
        # nclat.attrib["missing_value"] = Float32(valex)
        nclat.attrib["_FillValue"] = Float32(valex)
        nclat.attrib["units"] = "degrees_north"
		nclat.attrib["long_name"] = "Latitude"
		nclat.attrib["standard_name"] = "latitude"
		nclat.attrib["axis"] = "Y"
		nclat.attrib["reference_datum"] = "geographical coordinates, WGS84 projection"
		nclat.attrib["valid_min"] = -90.0 ;
		nclat.attrib["valid_max"] = 90.0 ;

        # Global attributes
		ds.attrib["Species_scientific_name"] = speciesname
		ds.attrib["Species_aphiaID"] = aphiaID
		ds.attrib["title"] = "$(long_name) based on presence/absence of $(speciesname)"
		ds.attrib["institution"] = "GHER - University of Liege, MBA"
		ds.attrib["source"] = "Spatial interpolation of presence/absence data"
        ds.attrib["project"] = "EMODnet Biology Phase IV"
        ds.attrib["comment"] = "Original data prepared by P. Helaouet"
        ds.attrib["data_authors"] = "Pierre Helaouet <pihe@MBA.ac.uk>"
        ds.attrib["processing_authors"] = "C. Troupin <ctroupin@uliege>, A. Barth <a.barth@uliege.be>"
		ds.attrib["publisher_name"] = "VLIZ"
		ds.attrib["publisher_url"] = "http://www.vliz.be/"
		ds.attrib["publisher_email"] = "info@vliz.be"
        ds.attrib["created"] = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
		ds.attrib["geospatial_lat_min"] = domain[3]
		ds.attrib["geospatial_lat_max"] = domain[4]
		ds.attrib["geospatial_lon_min"] = domain[1]
		ds.attrib["geospatial_lon_max"] = domain[2]
		ds.attrib["geospatial_lat_units"] = "degrees_north"
		ds.attrib["geospatial_lon_units"] = "degrees_east"
		ds.attrib["license"] = "GNU General Public License v2.0"
		ds.attrib["citation"] = "to be filled"
		ds.attrib["acknowledgement"] = "to be filled"
		ds.attrib["tool"] = "DIVAnd"
		ds.attrib["tool_version"] = DIVAndversion
		ds.attrib["tool_doi"] = "10.5281/zenodo.7016823"
		ds.attrib["language"] = "Julia $(juliaversion)"
		ds.attrib["Conventions"] = "CF-1.7"
		ds.attrib["netcdf_version"] = "4"
        ds.attrib["Correlation lengh"] = L
        ds.attrib["Noise-to-signal ratio"] = epsilon2

        # Define variables
        ncfield[:] = field
        nctime[:] = times
        nclon[:] = lons
        nclat[:] = lats;

    end
end

"""
    create_nc_results_time(filename, lons, lats)

Create a new netCDF file `filename` with the coordinates `lons`, `lats` that will 
be filled with interpolated field and error field.

## Examples
```julia-repl
julia> create_nc_results_time("Bacteriastrum_interp.nc", lons, lats)
```
"""
function create_nc_results_time(filename::String, lons, lats, speciesname="";
                           valex=-999.9,
                           varname::String = "abundance",
                           long_name::String = "Interpolated abundance",
						   domain::Array = [-180., 180., -90., 90.],
						   aphiaID::Int32 = 0,
                           L, epsilon2
                           )
    Dataset(filename, "c") do ds

        # Dimensions
        ds.dim["lon"] = length(lons)
        ds.dim["lat"] = length(lats)
        ds.dim["time"] = Inf # unlimited dimension

        # Declare variables
		nccrs = defVar(ds, "crs", Int64, ())
    	nccrs.attrib["grid_mapping_name"] = "latitude_longitude"
    	nccrs.attrib["semi_major_axis"] = 6371000.0 ;
    	nccrs.attrib["inverse_flattening"] = 0 ;

        ncfield = defVar(ds, varname, Float64, ("lon", "lat", "time"))
        ncfield.attrib["missing_value"] = Float64(valex)
        ncfield.attrib["_FillValue"] = Float64(valex)
		ncfield.attrib["units"] = "1"
        ncfield.attrib["long_name"] = long_name
		ncfield.attrib["coordinates"] = "lat lon time"
		ncfield.attrib["grid_mapping"] = "crs" ;
        
        ncerror = defVar(ds, "error", Float64, ("lon", "lat", "time"))
        ncerror.attrib["missing_value"] = Float64(valex)
        ncerror.attrib["_FillValue"] = Float64(valex)
		ncerror.attrib["units"] = "1"
        ncerror.attrib["long_name"] = "Relative error on $(long_name)"
		ncerror.attrib["coordinates"] = "lat lon time"
		ncerror.attrib["grid_mapping"] = "crs" ;
        
        nclon = defVar(ds,"lon", Float32, ("lon",))
        # nclon.attrib["missing_value"] = Float32(valex)
        nclon.attrib["_FillValue"] = Float32(valex)
        nclon.attrib["units"] = "degrees_east"
        nclon.attrib["long_name"] = "Longitude"
		nclon.attrib["standard_name"] = "longitude"
		nclon.attrib["axis"] = "X"
		nclon.attrib["reference_datum"] = "geographical coordinates, WGS84 projection"
		nclon.attrib["valid_min"] = -180.0 ;
		nclon.attrib["valid_max"] = 180.0 ;

        nclat = defVar(ds,"lat", Float32, ("lat",))
        # nclat.attrib["missing_value"] = Float32(valex)
        nclat.attrib["_FillValue"] = Float32(valex)
        nclat.attrib["units"] = "degrees_north"
		nclat.attrib["long_name"] = "Latitude"
		nclat.attrib["standard_name"] = "latitude"
		nclat.attrib["axis"] = "Y"
		nclat.attrib["reference_datum"] = "geographical coordinates, WGS84 projection"
		nclat.attrib["valid_min"] = -90.0 ;
		nclat.attrib["valid_max"] = 90.0 ;
        
        nctime = defVar(ds,"time", Float32, ("time",))
        #nctime.attrib["_FillValue"] = Float32(valex)
        nctime.attrib["units"] = "degrees_north"
		nctime.attrib["long_name"] = "Time"
		nctime.attrib["standard_name"] = "time"
        nctime.attrib["units"] = "days since 1950-01-01 00:00:00"
		nctime.attrib["axis"] = "T"

        # Global attributes
		ds.attrib["Species_scientific_name"] = speciesname
		ds.attrib["Species_aphiaID"] = aphiaID
		ds.attrib["title"] = "$(long_name) based on presence/absence of $(speciesname)"
		ds.attrib["institution"] = "GHER - University of Liege, MBA"
		ds.attrib["source"] = "Spatial interpolation of presence/absence data"
        ds.attrib["project"] = "EMODnet Biology Phase IV"
        ds.attrib["comment"] = "Original data prepared by P. Helaouet (Marine Biological Association)"
        ds.attrib["data_authors"] = "Pierre Helaouet <pihe@MBA.ac.uk>"
        ds.attrib["processing_authors"] = "C. Troupin <ctroupin@uliege>, A. Barth <a.barth@uliege.be>"
		ds.attrib["publisher_name"] = "VLIZ"
		ds.attrib["publisher_url"] = "http://www.vliz.be/"
		ds.attrib["publisher_email"] = "info@vliz.be"
        ds.attrib["created"] = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
		ds.attrib["geospatial_lat_min"] = domain[3]
		ds.attrib["geospatial_lat_max"] = domain[4]
		ds.attrib["geospatial_lon_min"] = domain[1]
		ds.attrib["geospatial_lon_max"] = domain[2]
		ds.attrib["geospatial_lat_units"] = "degrees_north"
		ds.attrib["geospatial_lon_units"] = "degrees_east"
		ds.attrib["license"] = "GNU General Public License v2.0"
		ds.attrib["citation"] = "to be filled"
		ds.attrib["acknowledgement"] = "to be filled"
		ds.attrib["tool"] = "DIVAnd"
		ds.attrib["tool_version"] = DIVAndversion
		ds.attrib["tool_doi"] = "10.5281/zenodo.7016823"
		ds.attrib["language"] = "Julia $(juliaversion)"
		ds.attrib["Conventions"] = "CF-1.7"
		ds.attrib["netcdf_version"] = "4"
        ds.attrib["Correlation length (degrees)"] = L
        ds.attrib["Noise-to-signal ratio"] = epsilon2

        # Define variables
        nclon[:] = collect(lons)
        nclat[:] = collect(lats);

    end
end;

"""
    write_nc_error(filename, error, valex=valex, varname=varname)

Write the error field `error` in the netCDF file `filename`

## Examples
```julia-repl
julia> write_nc_error("analysis.nc", cpme_error, valex=-99.9, varname="error")
```
"""
function write_nc_error(filename::String, error::Array, varname::String="abundance"; valex=-999.9)

    Dataset(filename, "a") do ds
        ds["$(varname)_error"][:] = error
    end
end

"""
    write_geotiff(filename, field, domain)

Write the field (analysis or error) in the geoTIFF file `filename`

## Examples
```julia-repl
julia> write_geotiff("f_finmarchicus.tif", f_finmarchicus, [-20.5, 11.75, 41.25, 67.0])
```
"""
function write_geotiff(filename::String, field::Array, domain::Vector)

    ga = GeoArray(field)
    bbox!(ga, (min_x=domain[1], min_y=domain[3], max_x=domain[2], max_y=domain[4]))
    epsg!(ga, 4326)  # in WGS84
    GeoArrays.write!(filename, ga)
end



end