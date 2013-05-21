
import 'dart:html';
import 'package:js/js.dart' as js;

class GoogleChats {

  var listData = [];
  var options = [];
  var div;

  GoogleChats(this.listData,this. options, this.div) {
    js.context.google.load('visualization', '1', js.map(
      {
        'packages': ['corechart'],
        'callback': new js.Callback.once(drawVisualization)
      }));
  }

  void drawVisualization() {
    var gviz = js.context.google.visualization;

    var arrayData = js.array(listData);

    var tableData = gviz.arrayToDataTable(arrayData);

    // Create and draw the visualization.
    var chart = new js.Proxy(gviz.LineChart, query(div));
    chart.draw(tableData, js.map(options));
  }
}