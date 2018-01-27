FlightGear TerraGear toolbox
===

This image contains the terragear tools from https://git.code.sf.net/p/flightgear/terragear

Available at the docker hub: `docker pull flightgear/terragear`

Usage
---
* Get a disk with a few hundret GB of space available. A fast disk helps a lot, use a SSD.
* Mount that disk and add a folder for TerraGear data, probably name it `TerraGear`
* Run the terragear docker image and mount this folder into the container:
 `docker run -it --rm -v /path/to/TerraGear/:/home/flightgear/tg flightgear/terragear:ws20 [CMD]`
 (replace /path/to/TerraGear with /your/ pathname to your TerraGear data folder)

if [CMD] is missing, the image prints out some hopefully helpful message about how to use it (well, not yet, soon it will).

Valid values for [CMD] are

* **mirror-srtm3**
 mirrors (by using wget --mirror) SRTM3 data from https://dds.cr.usgs.gov/srtm/version2_1/SRTM3
* **mirror-srtm1**
 mirrors (by using wget --mirror) SRTM3 data from https://dds.cr.usgs.gov/srtm/version2_1/SRTM1
* **hgtchop-srtm3**
 runs hgtchop on the previously downloaded SRTM3 data
* **hgtchop-srtm1**
 runs hgtchop on the previously downloaded SRTM1 data
* **terrafit-srtm3**
 runs terrafit on the chopped SRTM3 data
* **terrafit-srtm1**
 runs terrafit on the chopped SRTM1 data

More to come. Stay tuned.



