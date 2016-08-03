# The `plantecophys` R package

[![](http://www.r-pkg.org/badges/version/plantecophys)](http://cran.rstudio.com/web/packages/plantecophys/index.html) ![](http://cranlogs.r-pkg.org/badges/plantecophys) ![](https://img.shields.io/bitbucket/issues/remkoduursma/plantecophys.svg)

Welcome to the home of *plantecophys*, an R package that bundles a number of tools to analyze and model leaf gas exchange data.

[Please report bugs or suggest features here](https://bitbucket.org/remkoduursma/plantecophys/issues?status=new&status=open).



### Contents

* `fitaci` and `fitacis` fit the Farquhar-von Caemmerer-Berry model of photosynthesis to observations of photosynthesis (A) and Ci as measured with a Licor 6400 or similar instrument.
* `fitBB` fits various forms of the Ball-Berry stomatal conductance model to data.
* `Photosyn` is an implementation of a coupled leaf gas exchange model, including the Farquhar-Berry-von Caemmerer model of photosynthesis, and Ball-Berry-type stomatal conductance models. Accounts for leaf temperature effects on many processes.
* `PhotosynEB` is the same, but also calculates the leaf temperature (Tleaf) by solving the leaf energy balance (and takes air temperature as input). Extra inputs are wind speed, leaf width, and some others.
* `Aci` calculates the dependence of photosynthesis (A) on the intercellular CO2 concentration (Ci) for C3 plants with the FvCB model (as used by `fitaci`)
* `FARAO` is an implementation of the stomatal optimization model as suggested by Cowan and Farquhar (1977). It is a full numerical solution to the model, and uses the FARquhar model for photosynthesis.
* The functions `RHtoVPD`, `VPDtoRH`, and `DewtoVPD`convert between relative humidity, vapour pressure deficit (VPD) and the dewpoint. 

### Citation

Duursma, R.A., 2015. Plantecophys - An R Package for Analysing and Modelling Leaf Gas Exchange Data. PLoS ONE 10, e0143346. [doi:10.1371/journal.pone.0143346]().


### Installation

The package is now on CRAN, so just do:

```
install.packages("plantecophys")
```

To install the development version, use the following command. Windows users must have [Rtools](http://cran.r-project.org/bin/windows/Rtools/) installed.

```
library(devtools)
install_bitbucket("remkoduursma/plantecophys")
```


For questions, comments, and suggestions, please email remkoduursma@gmail.com