csvUrl = "https://roovoweb.com/data/climber_count.csv"

const DAYS_TO_SHOW = 7;

d3.csv(csvUrl, function(d) {
  return {
    time: new Date(d.time),
    count: +d.count
  };

}, function(error, rows) {
  var startOfWeek = new Date();
      startOfWeek.setHours(0, 0, 0, 0);
      startOfWeek.setDate(startOfWeek.getDate() - DAYS_TO_SHOW);

  var filtered = rows.filter(function(r) {
    return r.time > startOfWeek;
  });

  var chart = d3_timeseries()
          .addSerie(filtered, { x: 'time', y: 'count' }, { interpolate: 'linear', color: "#a6cee3", label: "climbers" })
          .width(650)
          .height(300)
  chart('#chart');
});
