# Source:
# Institudo Brasileiro de Geologia e Estatistica
# http://mapas.ibge.gov.br/

# -- Configurations

# TopoJSON configurations
TOPOJSON = node --max_old_space_size=8192 node_modules/.bin/topojson -q 1e6

# All Brazilian states
STATES = \
	ac al am ap ba ce df es go ma \
	mg ms mt pa pb pe pi pr rj rn \
	ro rr rs sc se sp to

all: \
	node_modules \
	$(addprefix topo/,$(addsuffix -municipalities.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -micro.json,$(STATES))) \
	$(addprefix topo/,$(addsuffix -meso.json,$(STATES))) \
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

# Downloads the zip files
# ftp://geoftp.ibge.gov.br/malhas_digitais/municipio_2010/
zip/%.zip:
	$(eval STATE := $(patsubst %-municipalities,%,$*))
	$(eval STATE := $(patsubst %-micro,%,$(STATE)))
	$(eval STATE := $(patsubst %-meso,%,$(STATE)))
	$(eval STATE := $(patsubst %-state,%,$(STATE)))
	$(eval FILENAME := $(subst -municipalities,_municipios,$*))
	$(eval FILENAME := $(subst -micro,_microrregioes,$(FILENAME)))
	$(eval FILENAME := $(subst -meso,_mesorregioes,$(FILENAME)))
	$(eval FILENAME := $(subst -state,_unidades_da_federacao,$(FILENAME)))
	mkdir -p $(dir $@)
	curl 'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2010/$(STATE)/$(FILENAME).zip' -o $@.download
	mv $@.download $@

# Extracts the files
tmp/%/: zip/%.zip
	rm -rf $(basename $@)
	mkdir -p $(dir $@)
	unzip -d tmp/$* $<
	$(eval REGION := $(patsubst %-municipalities,municipalities,$*))
	$(eval REGION := $(patsubst %-micro,micro,$*))
	$(eval REGION := $(patsubst %-meso,meso,$*))
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
