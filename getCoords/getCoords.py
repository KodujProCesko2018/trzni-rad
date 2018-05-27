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
    r = requests.get(url = uri)
    root = ElementTree.fromstring(r.content)
    if root.tag == "{http://www.opengis.net/wfs/2.0}FeatureCollection":
        if int(root.attrib['numberMatched']) > 0:
            for child in root:
                if child.tag == '{http://www.opengis.net/wfs/2.0}member':
                    return child.find(
                        '{http://inspire.ec.europa.eu/schemas/cp/4.0}CadastralParcel/{http://inspire.ec.europa.eu/schemas/cp/4.0}referencePoint/{http://www.opengis.net/gml/3.2}Point/{http://www.opengis.net/gml/3.2}pos').text
        else:
            return False
    else:
        return False

data = {}
data['type'] = 'FeatureCollection'
data['features'] = []

with open('trzni_rad.csv', 'r', encoding='utf8') as f:
  reader = csv.reader(f)
  address_list = list(reader)

for i, record in enumerate(address_list):
    if i != 0:

        feature = {}
        feature['geometry'] = {}
        feature['properties'] = {}
        feature['geometry']['coordinates'] = []

        tz_id = record[0]
        druh_mista = record[1]
        momc = record[2]
        adresa = record[3]
        mista = record[4]
        zabor = record[5]
        lode = record[6]
        prodejni_doba = record[7]
        doba_provozu = record[8]
        druh_zbozi = record[9]
        vice_zaznamu = record[10]
        ulice = record[11]
        cislo_domu = record[12]
        cislo_parcely = record[13]
        ku = record[14]
        cislo_ku = record[15]
        tags = record[16]
        tagy = tags.split(";")

        uri = ""
        uri2 = ""
        cislo_popisne = ""
        cislo_orientacni = ""

        if len(cislo_parcely.split(",")) > 0:
            cislo_parcely = cislo_parcely.split(",")[0]
        if len(cislo_domu.split(",")) > 0:
            cislo_domu = cislo_domu.split(",")[0]
        if len(ulice.split(",")) > 0:
            ulice = ulice.split(",")[0]

        if len(cislo_domu.split('/')) == 2:
            if cislo_domu.split('/')[1] > cislo_domu.split('/')[0]:
                cislo_popisne = cislo_domu.split('/')[1]
                cislo_orientacni = cislo_domu.split('/')[0]
            else:
                cislo_popisne = cislo_domu.split('/')[0]
                cislo_orientacni = cislo_domu.split('/')[1]

        else:
            cislo_orientacni = cislo_domu

        if cislo_popisne and cislo_orientacni:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&NUMBER=" + cislo_popisne + "&ADDRESS_NUMBER=" + cislo_orientacni + "&THOROUGHFARE_NAME=" + ulice
            uri2 = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&NUMBER=" + cislo_orientacni + "&ADDRESS_NUMBER=" + cislo_popisne + "&THOROUGHFARE_NAME=" + ulice
        elif cislo_popisne:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&NUMBER=" + cislo_popisne + "&THOROUGHFARE_NAME=" + ulice
        elif cislo_orientacni:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&ADDRESS_NUMBER=" + cislo_orientacni + "&THOROUGHFARE_NAME=" + ulice

        coords = ""

        if uri:
            if getCoordsFromAddress(uri):
                coords = getCoordsFromAddress(uri).split(" ")
            elif uri2 and getCoordsFromAddress(uri2):
                coords = getCoordsFromAddress(uri2).split(" ")
                tmp = cislo_orientacni
                cislo_orientacni = cislo_popisne
                cislo_popisne = tmp
            if coords:
                feature['geometry']['coordinates'].append(float(coords[0]))
                feature['geometry']['coordinates'].append(float(coords[1]))

        elif cislo_parcely:
            uri = "http://services.cuzk.cz/wfs/inspire-cp-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetParcel&srsName=EPSG:4326&UPPER_ZONING_ID=" + cislo_ku + "&TEXT=" + cislo_parcely
            print(uri)
            if getCoordsFromParcel(uri):
                coords = getCoordsFromParcel(uri).split(" ")
                feature['geometry']['coordinates'].append(float(coords[0]))
                feature['geometry']['coordinates'].append(float(coords[1]))

        elif ulice:
            uri = "http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=wfs&request=getFeature&version=2.0.0&storedQuery_Id=GetAddressByComponents&srsName=EPSG:4326&municipality_code=554782&MOMC_NAME=" + momc + "&THOROUGHFARE_NAME=" + ulice
            if getCoordsFromAddress(uri):
                coords = getCoordsFromAddress(uri).split(" ")
                feature['geometry']['coordinates'].append(float(coords[0]))
                feature['geometry']['coordinates'].append(float(coords[1]))

        if feature['geometry']['coordinates']:
            feature['type'] = 'Feature'
            feature['properties']['ulice'] =  ulice
            feature['properties']['cislo_popisne'] = cislo_popisne
            feature['properties']['cislo_orientacni'] = cislo_orientacni
            feature['properties']['momc'] = momc
            feature['properties']['druh_mista'] = druh_mista
            feature['properties']['druh_zbozi'] = druh_zbozi
            feature['properties']['tags'] = tagy
            feature['geometry']['type'] = 'Point'
            data['features'].append(feature)

with open('output.geojson','w', encoding='utf8') as outfile:
    json.dump(data,outfile,ensure_ascii=False,sort_keys=True)