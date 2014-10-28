$(function() {
	updateInterval = 2;
	totalPoints = 600;

	//http://stackoverflow.com/questions/7837456/comparing-two-arrays-in-javascript
	Array.prototype.equals = function (array) {
		// if the other array is a falsy value, return
		if (!array)
			return false;

		// compare lengths - can save a lot of time
		if (this.length != array.length)
			return false;

		for (var i = 0, l=this.length; i < l; i++) {
			// Check if we have nested arrays
			if (this[i] instanceof Array && array[i] instanceof Array) {
				// recurse into the nested arrays
				if (!this[i].equals(array[i]))
					return false;
			}
			else if (this[i] != array[i]) {
				// Warning - two different object instances will never be equal: {x:20} != {x:20}
				return false;
			}
		}
		return true;
	}


	function TimestampNow() {
		var now = new Date();
		return now.getTime() - (now.getTimezoneOffset() * 60 * 1000);
	};

	var ApplicationPlot = function(url) {
		this.url = url;
		this.backoff = 30; //secs
		this.state = {
			roof:        100,
			enabled:     false,
			startDate:   TimestampNow(),
			needRefresh: true,
		}

		this.createGear = function(name, index) {
			var gear = {
				index: index,
				name: name,
				data: [],
				push: function(timestamp, value) {
					if (this.data.length == totalPoints)
						this.data = this.data.slice(1);
					this.data.push([ timestamp, value ]);
				},
				serie: function() {
					return this.data;
					return this.data.map(function(value, index) {
						return value;
					});
				}
			};

			for (var i = 0; i < totalPoints; i++) {
				gear.push(null, null);
			}
			return gear;
		};

		this.getGear = function(name) {
			for (var i = 0; i < this.gears.length; i++) {
				if (this.gears[i].name === name) {
					return this.gears[i];
				}
			}
			var gear = this.createGear(name, this.gears.length);
			this.gears.push(gear);
			return gear;
		};

		this.buildSeries = function() {
			return this.gears.map(function(gear, i) {
				return {
					color: i,
					label: gear.name,
					data: gear.serie()
				};
			});
		};

		this.gears = [];
		this.series = [];

		this.makePlot = function() {
			console.log('Redraw');
			this.plot = $.plot("#placeholder", this.series, {
				legend: {
					position: 'nw',
					sorted: false,
					backgroundOpacity: 0.5,
				},
				yaxis: {
					min: 0,
					max: this.state.roof + 5
				},
				xaxis: {
					mode: "time",
					minTickSize: [1, "minute"],
					min: this.state.startDate,
					max: this.state.startDate + (totalPoints * 1000),
					twelveHourClock: true
				}
			});
		};

		this.updateSeries = function(stats) {
			var now = TimestampNow();
			stats.split('\n').reverse().forEach(function(line) {
				var fields = line.split(',');
				if (fields[0] !== 'express' || fields[1] === 'FRONTEND')
					return;

				var gear = this.getGear(fields[1]);
				var y = parseFloat(fields[33]);
                                console.log(fields);
				if (y < 0) {
					y = 0;
				} else if (y > this.state.roof) {
					this.state.roof = y;
					this.state.needRefresh = true;
				}

				gear.push(now, y);
			}.bind(this));

			var oldSeries = this.series.map(function(serie) { return serie.label; }).sort();
			this.series = this.buildSeries();
			var newSeries = this.series.map(function(serie) { return serie.label; }).sort();

			if (!oldSeries.equals(newSeries)) {
				//this handles the first draw and gear add/rm
				this.state.needRefresh = true;
			}
		};

		this.checkLimit = function() {
			//check if we are getting close to right edge
			var options = this.plot.getOptions();
			var lastPoint = this.series[0].data[this.series[0].data.length - 1];
			if (lastPoint[0] > options.xaxes[0].max - (this.backoff * 1000)) {
				// left shift
				this.state.startDate = options.xaxes[0].min + (this.backoff * 1000);
				this.state.needRefresh = true;
			}
		};

		this.update = function() {
			$.get('http://' + this.url + '/haproxy-status/;csv')
				.fail(function() {
					$('#hostname').addClass('failed');
					this.failed = true;
				}.bind(this))
				.success(function(stats) {
					if (this.failed) {
						$('#hostname').removeClass('failed');
						this.failed = false;
					}

					this.updateSeries(stats);

					if (this.state.needRefresh) {
						this.makePlot();
						this.needRefresh = false;
					}

					this.checkLimit();

					if (this.state.needRefresh) {
						this.makePlot();
					}

					this.plot.setData(this.series);
					this.plot.draw();
					this.state.needRefresh = false;
				}.bind(this))
				.always(function() {
					if (!this.state.enabled) {
						return;
					}
					var that = this;
					this.timer = setTimeout(function() { that.update() }, updateInterval * 1000);
				}.bind(this));
		};

		this.start = function() {
			this.state.enabled = true;
			this.update();
			console.log("Started");
		};

		this.stop = function() {
			clearTimeout(this.timer);
			this.state.enabled = false;
			console.log("Stoppped");
		};
	};

	var hostname = window.location.hostname;
	$('#hostname').html(hostname);
	app = new ApplicationPlot(hostname);
	app.start();

	$('#toggle').click(function() {
		var el = $(this);
		if (el.val() == "on") {
			var newVal = "off";
		} else {
			var newVal = "on";
		}
		el.addClass(newVal);
		el.removeClass(el.val());
		el.val(newVal).html(newVal.toUpperCase());
		if (newVal == "on") {
			app.start();
		} else {
			app.stop();
		}
	});

	$("#updateInterval").val(updateInterval).change(function () {
		var el = $(this);
		var v = el.val();
		if (v && !isNaN(+v)) {
			updateInterval = +v;
			if (updateInterval < 1) {
				updateInterval = 1;
			}
			app.stop();
			app.start();
		}
	});

});


