XPGET=xpget.py
TGROOT=/home/flightgear/tg

DAT_FILES := $(wildcard airports/dat/*.dat)
STA_FILES := $(addprefix airports/state/,$(notdir $(DAT_FILES:.dat=.sta)))

TERRAIN_DIR=/blob/terrascenery/work/ws2.x/Terrain

GENAPTS=/home/jenkins/workspace/TerraGear/dist/bin/genapts850
GENAPTS_FLAGS=--work=/mnt/tg/work --threads=1 --nudge=20

TGCONSTRUCT=/home/jenkins/workspace/TerraGear/dist/bin/tg-construct
    
TGCONSTRUCT_AREAS=AirportArea \
    AirportObj \
    Default
    
TGCONSTRUCT_FLAGS=\ 
    --output-dir=$(TERRAIN_DIR) \
    --work-dir=/mnt/tg/work \
    --share-dir=./share \
    --usgs-map=./usgsmap.txt \ 
    --priorities=./default_priorities.txt \
    --nudge=20 --ignore-landmass \
    --debug-dir=./debug \
    --threads=2 \
    $(TGCONSTRUCT_AREAS)
    
airports: $(STA_FILES)
	@echo "Airports done" 
      
gateway:
	rm -f airports/meta.json
	$(XPGET) -o airports
	
terrain:
	@mkdir -p $(TERRAIN_DIR)
	echo $(TGCONSTRUCT) $(TGCONSTRUCT_FLAGS)
	
airports/state/%.sta: airports/dat/%.dat
	mkdir -p airports/state
	$(GENAPTS) $(GENAPTS_FLAGS) --input=$< 
	@touch $@

mirror-srtm3:
	cd $(TGROOT)/mirrors && \
	wget --wait=0 --random-wait --mirror --no-parent https://dds.cr.usgs.gov/srtm/version2_1/SRTM3
	rm -f $(TGROOT)/data/SRTM-3 && ln -s $(TGROOT)/mirrors/dds.cr.usgs.gov/srtm/version2_1/SRTM3 $(TGROOT)/data/SRTM-3

mirror-srtm1:
	cd $(TGROOT)/mirrors && \
	wget --wait=1 --random-wait --mirror --no-parent https://dds.cr.usgs.gov/srtm/version2_1/SRTM1/
	rm -f $(TGROOT)/data/SRTM-1 && ln -s $(TGROOT)/mirrors/dds.cr.usgs.gov/srtm/version2_1/SRTM1 $(TGROOT)/data/SRTM-1

hgtchop-srtm3:
	cd $(TGROOT) && \
	for f in data/SRTM-3/*/*.zip; do hgtchop 3 "$$f" work/SRTM-3; done

hgtchop-srtm1:
	cd $(TGROOT) && \
	for f in data/SRTM-1/*/*.zip; do hgtchop 1 "$$f" work/SRTM-1; done

terrafit-srtm3:
	terrafit $(TGROOT)/work/SRTM-3

terrafit-srtm1:
	terrafit $(TGROOT)/work/SRTM-1
