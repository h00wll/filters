part of charts;

class GoogleMaps {

  bool init = false;
  var maps;
  var map;

  GoogleMaps() {
    maps = js.context.google.maps;
  }
  
  void draw(List listData, var color) {
    if (!init) {
      init = true;
      drawVisualization(listData);
    }
    
    List flightPlanCoordinates = new List();
    listData.forEach((List coords) {
      flightPlanCoordinates.add(new js.Proxy(maps.LatLng, coords[0] / 100000, coords[1] / 100000));
      //flightPlanCoordinates.add('qwe');
    });
    
    var fpo = {
               'path': js.array(flightPlanCoordinates),
               'strokeColor': color,
               'strokeOpacity': 1.0,
               'strokeWeight': 1
    };
    var flightPath = new js.Proxy(maps.Polyline, js.map(fpo));

    flightPath.setMap(map);
    
  }

  void drawVisualization(listData) {
    var center = new js.Proxy(maps.LatLng, listData.first[0] / 100000, listData.first[1] / 100000);
    var mapOptions = {
        'center': center,
        'zoom': 16,
        'mapTypeId': maps.MapTypeId.ROADMAP
    };
    map = new js.Proxy(maps.Map, query('#map1'), js.map(mapOptions));
  }
}