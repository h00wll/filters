part of charts;

class GoogleChats {

  var listData = [];
  var options = [];
  var div;
  var type;

  GoogleChats(this.listData,this. options, this.div, {this.type: 1}) {
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
    var chart;
    if (type == GoogleChartType.Line) {
      chart = new js.Proxy(gviz.LineChart, query(div));
    } else if (type == GoogleChartType.Scatter) {
      chart = new js.Proxy(gviz.ScatterChart, query(div));
    }
    chart.draw(tableData, js.map(options));
  }
}

class GoogleChartType {
  static final int Line = 1;
  static final int Scatter = 2;
}