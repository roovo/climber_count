csvUrl = "http://roovoweb.com/data/climber_count.csv"

d3.csv(csvUrl, function(d) {
  return {
    time: new Date(d.time),
    count: +d.count
  };

}, function(error, rows) {
  var chart = d3_timeseries()
          .addSerie(rows, { x: 'time', y: 'count' }, { interpolate: 'linear', color: "#a6cee3", label: "climbers" })
          .width(650)
          .height(300)
  chart('#chart');
});
