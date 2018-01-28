XPGET=xpget.py
TGROOT=/home/flightgear/tg

DAT_FILES := $(wildcard $(TGROOT)/airports/dat/*.dat)
STA_FILES := $(addprefix $(TGROOT)/airports/state/,$(notdir $(DAT_FILES:.dat=.sta)))

TERRAIN_DIR=$(TGROOT)/output/

GENAPTS=genapts850
GENAPTS_FLAGS=--work=$(TGROOT)/work --threads=1 --nudge=20

TGCONSTRUCT=tg-construct
    
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
	rm -f $(TGROOT)/airports/meta.json
	$(XPGET) -o $(TGROOT)/airports
	
terrain:
	@mkdir -p $(TERRAIN_DIR)
	echo $(TGCONSTRUCT) $(TGCONSTRUCT_FLAGS)
	
$(TGROOT)/airports/state/%.sta: $(TGROOT)/airports/dat/%.dat
	mkdir -p $(TGROOT)/airports/state
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
