import csv
import requests
from xml.etree import ElementTree
import json


def getCoordsFromAddress(uri):
    r = requests.get(url=uri)
    root = ElementTree.fromstring(r.content)
    if root.tag == "{http://www.opengis.net/wfs/2.0}FeatureCollection":
        if int(root.attrib['numberMatched']) > 0:
            for child in root:
                if child.tag == '{http://www.opengis.net/wfs/2.0}member':
                    return child.find(
                        '{http://inspire.ec.europa.eu/schemas/ad/4.0}Address/{http://inspire.ec.europa.eu/schemas/ad/4.0}position/{http://inspire.ec.europa.eu/schemas/ad/4.0}GeographicPosition/{http://inspire.ec.europa.eu/schemas/ad/4.0}geometry/{http://www.opengis.net/gml/3.2}Point/{http://www.opengis.net/gml/3.2}pos').text
        else:
            return False
    else:
        return False

def getCoordsFromParcel(uri):
    print('bude dělat nějakou chujovinu')

data = {}
# json_data = {}
data['features'] = []


with open('trzni_rad.csv', 'r', encoding='utf8') as f:
  reader = csv.reader(f)
  address_list = list(reader)

for i, record in enumerate(address_list):
    if i != 0 and i < 10:

        feature = {}
        feature['geometry'] = {}
        feature['properties'] = {}
        feature['geometry']['coordinates'] = []

        ulice = record[9]
        momc = record[1]
        druh_mista = record[0]
        mista = record[3]
        zabor = record[4]
        prodejni_doba = record[5]
        druh_zbozi = record[7]
        #there can be more thoroughfares and more numbers
        if len(record[10].split('/')) == 2:
            if record[10].split('/')[1] > record[10].split('/')[0]:
                cislo_popisne = record[10].split('/')[1]
                cislo_orientacni = record[10].split('/')[0]
            else:
                cislo_popisne = record[10].split('/')[0]
                cislo_orientacni = record[10].split('/')[1]

        else:
            cislo_orientacni = record[10]

        cislo_parcely = record[11]

        if cislo_popisne and cislo_orientacni:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&NUMBER=" + cislo_popisne + "&ADDRESS_NUMBER=" + cislo_orientacni + "&THOROUGHFARE_NAME=" + ulice
            uri2 = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&NUMBER=" + cislo_orientacni + "&ADDRESS_NUMBER=" + cislo_popisne + "&THOROUGHFARE_NAME=" + ulice
        if cislo_popisne:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&NUMBER=" + cislo_popisne + "&THOROUGHFARE_NAME=" + ulice
        if cislo_orientacni:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&ADDRESS_NUMBER=" + cislo_orientacni + "&THOROUGHFARE_NAME=" + ulice

        if uri:
            if getCoordsFromAddress(uri):
                feature['geometry']['coordinates'].append(getCoordsFromAddress(uri))
            elif getCoordsFromAddress(uri2):
                feature['geometry']['coordinates'].append(getCoordsFromAddress(uri2))

        elif cislo_parcely:
            getCoordsFromParcel(uri)

        elif ulice:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&THOROUGHFARE_NAME=" + ulice
            if getCoordsFromAddress(uri):
                feature['geometry']['coordinates'].append(getCoordsFromAddress(uri))

        if feature['geometry']['coordinates']:
            feature['type'] = 'Feature'
            feature['properties']['ulice'] =  ulice
            feature['properties']['cislo_domovni'] = cislo_popisne
            feature['properties']['cislo_orientacni'] = cislo_orientacni
            feature['properties']['momc'] = momc
            feature['properties']['druh_mista'] = druh_mista
            feature['properties']['druh_zbozi'] = druh_zbozi
            feature['geometry']['type'] = 'Point'
            data['features'].append(feature)

data['type'] = 'FeatureCollection'
# json_data = json.dumps(data)

with open('output.geojson','w', encoding='utf8') as outfile:
    json.dump(data,outfile,ensure_ascii=False)

# print(json_data)
