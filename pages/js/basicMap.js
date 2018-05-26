var map = null;
var trzniMista = null;

function onEachFeature(feature, layer) {
    var popupContent = "<p>Adresa: ";

    if (feature.properties && feature.properties["alternativeIdentifier"]) {
        popupContent += feature.properties["alternativeIdentifier"];
    }
    popupContent += "</p>Kod: ";
 
    if (feature.properties && feature.properties["gml_id"]) {
        popupContent += feature.properties["gml_id"];
    }   
    popupContent += "</p>";

    layer.bindPopup(popupContent);
}

function onVectorDataReady(data) {
    L.geoJson(data, {
        onEachFeature: onEachFeature,
        pointToLayer: function (feature, latlng) {
            return L.circleMarker(latlng, {
                radius: 8,
                fillColor: "#ff7800",
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8,
                fill: true
            });
        }

   }).addTo(map);
}

function initMap() {
    map = L.map('map').setView([50.08, 14.415], 13);

    L.tileLayer('https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiaG9ya3lsYWRpc2xhdiIsImEiOiJjaXVwbTZraGgwMDNmMnlwazE5c2wxazZpIn0.vPPHzOu544kRuJ6j8zml2g', {
        attribution: '&copy; Mapbox, &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);;

    //get the vector data
    var x = new XMLHttpRequest();
    x.overrideMimeType("application/json");
    x.open("GET", 'geo/trzni-rad.geojson', true);
    x.onreadystatechange = function () {
        if ((x.readyState) == 4 && ((x.status == 200) || (x.status == 0)))
        {
            trzniMista = JSON.parse(x.responseText);
            onVectorDataReady(JSON.parse(x.responseText));
        }
    };
    x.send(null);
}
