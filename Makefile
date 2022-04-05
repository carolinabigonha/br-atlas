# Source:
# Institudo Brasileiro de Geologia e Estatistica
# http://mapas.ibge.gov.br/

# -- Configurations

# TopoJSON configurations
TOPOJSON = node --max_old_space_size=8192 node_modules/topojson-server/bin/geo2topo -q 1e6

# All Brazilian states
STATES = \
	AC AL AM AP BA CE DF ES GO MA \
	MG MS MT PA PB PE PI PR RJ RN \
	RO RR RS SC SE SP TO

# Maps year
YEAR = 2021

all: \
	node_modules \
	$(addprefix topo/,$(addsuffix -municipalities.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -micro.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -meso.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -immediate.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -intermediate.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -state.json,$(STATES))) \
	permission

# Install dependencies
node_modules:
	npm install

# Add execute permission
permission:
	chmod +x scripts/merge.py

# .SECONDARY with no dependencies marks all file targets mentioned in the makefile as secondary.
.SECONDARY:

# -- Downloading and extracting IBGE files

# Downloads States zip files
# ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2021/UFs/
zip/%.zip:
	$(eval STATE := $(patsubst %-municipalities,%,$*))
	$(eval STATE := $(patsubst %-micro,%,$(STATE)))
	$(eval STATE := $(patsubst %-meso,%,$(STATE)))
	$(eval STATE := $(patsubst %-immediate,%,$(STATE)))
	$(eval STATE := $(patsubst %-intermediate,%,$(STATE)))
	$(eval STATE := $(patsubst %-state,%,$(STATE)))
	$(eval FILENAME := $(subst -municipalities,_Municipios_$(YEAR),$*))
	$(eval FILENAME := $(subst -micro,_Microrregioes_$(YEAR),$(FILENAME)))
	$(eval FILENAME := $(subst -meso,_Mesorregioes_$(YEAR),$(FILENAME)))
	$(eval FILENAME := $(subst -immediate,_RG_Imediatas_$(YEAR),$(FILENAME)))
	$(eval FILENAME := $(subst -intermediate,_RG_Intermediarias_$(YEAR),$(FILENAME)))
	$(eval FILENAME := $(subst -state,_UF_$(YEAR),$(FILENAME)))
	mkdir -p $(dir $@)
	curl 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_$(YEAR)/UFs/$(STATE)/$(FILENAME).zip' -o $@.download
	mv $@.download $@

# Extracts the files
tmp/%/: zip/%.zip
	rm -rf $(basename $@)
	mkdir -p $(dir $@)
	unzip -d tmp/$* $<
	$(eval REGION := $(patsubst %-municipalities,municipalities,$*))
	$(eval REGION := $(patsubst %-micro,micro,$*))
	$(eval REGION := $(patsubst %-meso,meso,$*))
	$(eval REGION := $(patsubst %-immediate,immediate,$*))
	$(eval REGION := $(patsubst %-intermediate,intermediate,$*))
	$(eval REGION := $(patsubst %-state,state,$*))
	mv $@/*.shp $@/map.shp
	mv $@/*.shx $@/map.shx
	mv $@/*.dbf $@/map.dbf
	mv $@/*.prj $@/map.prj

# -- Generate GeoJSON files

geo/%.json: tmp/%/
	mkdir -p $(dir $@)
	ogr2ogr -f GeoJSON $@ tmp/$*/map.shp
	iconv -f ISO-8859-1 -t UTF-8 $@ > $@.utf8
	mv $@.utf8 $@
	touch $@

# -- Generating TopoJSON files for each state

# For individual states, municipality level
topo/%-municipalities.json: geo/%-municipalities.json
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=CD_GEOCODM -p name=NM_MUNICIP -o $@ municipalities=$^
	touch $@

# For individual states, micro-region level
topo/%-micro.json: geo/%-micro.json
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=NM_MICRO -p name=NM_MICRO -o $@ micro=$^
	touch $@

# For individual states, meso-region level
topo/%-meso.json: geo/%-meso.json
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=NM_MESO -p name=NM_MESO -o $@ meso=$^
	touch $@

# For individual states, immediate-region level
topo/%-immediate.json: geo/%-immediate.json
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=NM_IMEDIATA -p name=NM_IMEDIATA -o $@ immediate=$^
	touch $@

# For individual states, intermediate-region level
topo/%-intermediate.json: geo/%-intermediate.json
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=NM_INTERMEDIARIA -p name=NM_INTERMEDIARIA -o $@ intermediate=$^
	touch $@

# For individual states, state level:
topo/%-state.json: geo/%-state.json
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=CD_GEOCODU -p name=NM_ESTADO -p region=NM_REGIAO -o $@ state=$^
	touch $@

# -- Generating TopoJSON files for Brazil

# For Brazil with municipalities
topo/br-municipalities.json: $(addprefix geo/,$(addsuffix -municipalities.json,$(STATES)))
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=CD_GEOCODM -p name=NM_MUNICIP -o $@ -- $^
	./scripts/merge.py $@ > $@.merged
	mv $@.merged $@

# For Brasil with states
topo/br-states.json: $(addprefix geo/,$(addsuffix -state.json,$(STATES)))
	mkdir -p $(dir $@)
	$(TOPOJSON) --id-property=CD_GEOCODU -p name=NM_ESTADO -p region=NM_REGIAO -o $@ -- $^
	./scripts/merge.py $@ > $@.merged
	mv $@.merged $@

# Simplified version of state file
topo/br-states.min.json: topo/br-states.json
	$(TOPOJSON) -p --simplify-proportion=.2 -o $@ -- $^

# -- Clean

# Clean temporary files
clean-tmp:
	rm -rf tmp

# Clean extra files
clean-extra:
	rm -rf zip
	rm -rf tmp

# Clean result files
clean-result:
	rm -rf shp
	rm -rf geo
	rm -rf topo

# Clean everything
clean: clean-tmp clean-result clean-extra
