
import 'dart:html';
import 'package:js/js.dart' as js;

class GoogleMaps {

  List listData;
  var options = [];
  var div;

  GoogleMaps(this.listData) {

    //google.maps.event.addDomListener(window, 'load', initialize);
    drawVisualization();
  }

  void drawVisualization() {
    var maps = js.context.google.maps;
    var center = new js.Proxy(maps.LatLng, listData.first[1], listData.first[0]);
    var mapOptions = {
                      'center': center,
                      'zoom': 14,
                      'mapTypeId': maps.MapTypeId.ROADMAP
    };
    var map = new js.Proxy(maps.Map, query('#map1'), js.map(mapOptions));


    List flightPlanCoordinates = new List();
    listData.forEach((List coords) {
      flightPlanCoordinates.add(new js.Proxy(maps.LatLng, coords[1], coords[0]));
      //flightPlanCoordinates.add('qwe');
    });
              
    var a = js.array(flightPlanCoordinates);
    
    var fpo = {
               'path': a,
               'strokeColor': '#FF0000',
               'strokeOpacity': 1.0,
               'strokeWeight': 2
             };
    var flightPath = new js.Proxy(maps.Polyline, js.map(fpo));

    flightPath.setMap(map);



   /* var gviz = js.context.google.visualization;

    var arrayData = js.array(listData);

    var tableData = gviz.arrayToDataTable(arrayData);

    // Create and draw the visualization.
    var chart = new js.Proxy(gviz.LineChart, query(div));
    chart.draw(tableData, js.map(options));*/
  }
}