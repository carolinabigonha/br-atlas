# Brazil Atlas TopoJSON

Based on [Michael Bostock's us-atlas](http://github.com/mbostock/us-atlas.git), this repository is for generating [TopoJSON files](https://github.com/mbostock/topojson) for Brazilian maps.

All maps are downloaded from [IBGE (Instituto Brasileiro de Geografia e Estatística)](http://www.ibge.gov.br/), the agency responsible for
statistical, geographic, cartographic, geodetic and environmental information
in Brazil.

## Dependencies

Firstly, this repository depends on [Node.js](http://nodejs.org/).
You may install Node.js using the source code or a pre-built
installer for your platform, all available at
[Node.js download page](http://nodejs.org/download/).

The other dependency is the
[Geospatial Data Abstraction Library (GDAL)](http://www.gdal.org/),
used for converting the files.

For installing GDAL on Mac, you may use [Homebrew](http://brew.sh/):

```
brew install gdal
```

Or [Mac Ports](macports.org) (still on Mac)

```
port install gdal
```

For installing it on Linux, run:

```
sudo apt-get install gdal-bin
```

## Usage

Clone this repository, install the dependencies and run `make`.

```bash
git clone https://github.com/carolinabigonha/br-atlas.git
cd br-atlas
npm install
make
```

TopoJSON files will be generated inside ``topo/`` directory.
GeoJSON files will be generated inside ``geo/`` directory.

## More Information

Running ``make`` will generate TopoJSON and GeoJSON files for Brazil and
each of its states and municipalities. They are located in ``topo/`` and ``geo/`` directories.

Also, several intermediate files are generated: ``zip`` and ``tmp``
directories contain the original files downloaded and extracted from
IBGE. If you wish to delete these extra directories (they sum up 425MB),
run ``make clean-extra``.

In addition, you can run ``make topo/br-municipalities.json`` for generating
a Brazil map with municipalities and ``make topo/br-states.json`` for generating
a Brazil map with states. Similarly, you may generate files for
specific states, for example:
``make topo/mg-municipalities.json`` or ``make topo/mg-states.json``
for generating maps of Minas Gerais state.

Feel free to contribute and add new types of maps.
Additional source is available at ftp://geoftp.ibge.gov.br/mapas_interativos/.

## Licence

All files are under the BSD 3-Clause License, as stated in LICENCE.

## Contributors
Carolina Bigonha <carolinabigonha@gmail.com>
Marcelo Pontes <balaum@gmail.com>
João Guilherme <joaaogui@gmail.com>
Victor Navarro <victor.matias.navarro@gmail.com>
Nihey Takizawa <nihey.takizawa@gmail.com>

-----------------------------------

# Atlas TopoJSON do Brasil

Baseado no repositório [us-atlas](http://github.com/mbostock/us-atlas.git) do grande Michael Bostock, este é um repositório para geração de mapas TopoJSON
do Brasil.

## Dependências

Este repositório tem como dependência o [Node.js](http://nodejs.org/).
Pode-se instalar o Node.js por meio do código fonte ou por instaladores
para os diferentes sistemas operacionais, disponíveis na
[página de instalação do Node.js](http://nodejs.org/download/).

Outra dependência deste projeto é
[Geospatial Data Abstraction Library (GDAL)](http://www.gdal.org/),
utilizada para a conversão dos arquivos.

Para instalar GDAL no Mac, utilize o [Homebrew](http://brew.sh/):
``` 
brew install gdal 
```

Ou [Mac Ports](http://macports.org/)

``` 
port install gdal 
```

Para instalar no Linux, execute: 

``` 
sudo apt-get install gdal-bin 
```

## Modo de uso

Realize o download deste repositório, instale
as dependências e execute `make`.

Todos os mapas são extraídos do banco de dados do [IBGE (Instituto Brasileiro de Geografia e Estatística)](http://www.ibge.gov.br/), fundação pública da
administração federal brasileira.

```bash
git clone https://github.com/carolinabigonha/br-atlas.git
cd br-atlas
npm install
make
```

Os arquivos TopoJSON são gerados no diretório ``topo/``.
Os arquivos GeoJSON são gerados no diretório ``geo/``.

## Mais informações

Ao rodar ``make`` arquivos TopoJSON serão gerados para o Brasil e seus
estados na pasta ``topo/``. Arquivos GeoJSON também são gerados na
pasta ``geo/``, como sub-produto.

Além disso, as pastas ``zip/`` e ``tmp/``
contêm os arquivos originais obtidos do IBGE.
Se desejar apagar tais pastas
(``shp`` possui 140 MB e ``tmp`` possui 285 MB),
execute ``make clean-extra``.

Você ainda pode gerar mapas específicos, por exemplo: ``make topo/br-municipalities.
json`` para gerar um mapa do Brasil e seus municípios e ``make topo/br-states.
json`` para gerar um mapa do Brasil e seus estado. Você ainda pode gerar os
mapas para cada estado: por exemplo, ``make topo/mg-municipalities.json`` ou ``make
topo/mg-states.json`` geram arquivos TopoJSON para os municípios e para o
estado de Minas Gerais.

Sinta-se a vontade para contribuir. Ainda faltam vários mapas para serem
incluídos. Muitos encontrados em: ftp://geoftp.ibge.gov.br/mapas_interativos/.

## Licença

Todos os arquivos estão disponíveis sob a Licença BSD 3-Clause License.

## Contribuidores
Carolina Bigonha <carolinabigonha@gmail.com>
Marcelo Pontes <balaum@gmail.com>
João Guilherme <joaaogui@gmail.com>
Victor Navarro <victor.matias.navarro@gmail.com>
Nihey Takizawa <nihey.takizawa@gmail.com>
