# EMODnet-Bio-Interp-Calanus

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![DOI](https://zenodo.org/badge/452690474.svg)](https://zenodo.org/badge/latestdoi/452690474)
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/EMODnet-Bio-Interp-Calanus)

Spatial interpolation of _Calanus finmarchicus_ and _Calanus helgolandicus_ observations in the North Sea using the [`DIVAnd`](https://github.com/gher-uliege/DIVAnd.jl) software tool.

## Objectives

The objective of this project is twofold:
1. Create gridded maps of _Calanus finmarchicus_ and _Calanus helgolandicus_ abundances and
2. Develop and apply a multivariate approach in the interpolatio method.

## Data

__CPR__ stands for Continuous Plankton Recorder. It is an instrument, towed by volunteer
merchant ships, designed to capture plankton samples. CPR datasets are unique
in the sense that data have been acquired in a consistent way (same method)
for more that 70 years.

The domain of interest ranges from 41.25°N to 67.0°N and from 20.5°W to 11.75°E.

### How does it work?

In the instrument, plankton collected by continuously moving bands of filter silk
is filtered and then the silk, stored in a cassette, is analysed in a laboratory.

__More info:__ https://www.cprsurvey.org/services/the-continuous-plankton-recorder/

### Typical scales

- Each sample represents 10 nautical miles (< 20 km) of towing.
- The instrument towed at depth of about 5 -10 metres.
- Speed is up to 25 knots (46 km/h)

### Data distribution

_Finmarchicus_             |  Helgolandicus
:-------------------------:|:-------------------------:
![count_calanus_finmarchicus](https://user-images.githubusercontent.com/11868914/151570410-7dad2e00-ef08-452a-9076-8ebd9cadfc36.jpg) | ![count_calanus_helgolandicus](https://user-images.githubusercontent.com/11868914/151571375-6a2ef5c4-cf55-47f4-933c-f83be5fb5aec.jpg)

## Results

### Basic analysis

* L = 2.5
* epsilon2 = 5.

_Finmarchicus_             |  _Helgolandicus_
:-------------------------:|:-------------------------:
![analysis_calanus_finmarchicus](https://user-images.githubusercontent.com/11868914/151572917-f1df7bee-382d-4d88-85f4-ea204ceba5a7.jpg) | ![analysis_calanus_helgolandicus](https://user-images.githubusercontent.com/11868914/151572924-14459d9f-e999-49b4-9ab9-dfa4674a8f27.jpg)

### Output formats
The formats are adopted for this project:
1. netCDF, following the Climate and Forecast conventions for the metadata and attributes
2. geoTIFF, more widely used in different scientific communities.


## Useful references

Webjørn Melle, Jeffrey Runge, Erica Head, Stéphane Plourde, Claudia Castellani, Priscilla Licandro, James Pierson, Sigrun Jonasdottir, Catherine Johnson, Cecilie Broms, Høgni Debes, Tone Falkenhaug, Eilif Gaard, Astthor Gislason, Michael Heath, Barbara Niehoff, Torkel Gissel Nielsen, Pierre Pepin, Erling Kaare Stenevik, Guillem Chust (2014). The North Atlantic Ocean as habitat for Calanus finmarchicus: Environmental factors and life history traits,
_Progress in Oceanography_, **129:** 244-284. DOI: [https://doi.org/10.1016/j.pocean.2014.04.026](https://doi.org/10.1016/j.pocean.2014.04.026)
https://www.sciencedirect.com/science/article/pii/S0079661114000743

Wilson Robert J., Heath Michael R., Speirs Douglas C. (2016). Spatial Modeling of Calanus finmarchicus and Calanus helgolandicus: Parameter Differences Explain Differences in Biogeography, _Frontiers in Marine Science_, **3**                
https://www.frontiersin.org/articles/10.3389/fmars.2016.00157/full

Shuang Gao, Solfrid Sætre Hjøllo, Tone Falkenhaug, Espen Strand, Martin Edwards, Morten D. Skogen (2021). Overwintering distribution, inflow patterns and sustainability of Calanus finmarchicus in the North Sea, _Progress in Oceanography_,**194**, DOI: [10.1016/j.pocean.2021.102567](https://doi.org/10.1016/j.pocean.2021.102567).        
https://www.sciencedirect.com/science/article/pii/S0079661121000549
