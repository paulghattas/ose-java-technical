<!DOCTYPE html>
<!--[if IE 8]><html class="ie8"><![endif]-->
<!--[if IE 9]><html class="ie9"><![endif]-->
<!--[if gt IE 9]><!-->
<html>
<!--<![endif]-->
  <head>
    <%@ page import="javax.servlet.http.HttpUtils,java.util.Enumeration" %>
    <%@ page import="java.lang.management.*" %>
    <%@ page import="java.util.*" %>
    <title>JBoss EAP - Powered by OpenShift</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="../dist/img/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../dist/img/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../dist/img/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../dist/img/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="../dist/img/apple-touch-icon-57-precomposed.png">
    <link href="../dist/css/patternfly.css" rel="stylesheet" media="screen, print">
    <style>
      #proxy-status .container {
      	box-sizing: border-box;
      	width: 850px;
      	height: 450px;
      	padding: 20px 15px 15px 15px;
      	margin: 15px auto 30px auto;
      	border: 1px solid #ddd;
      	background: #fff;
      	background: linear-gradient(#f6f6f6 0, #fff 50px);
      	background: -o-linear-gradient(#f6f6f6 0, #fff 50px);
      	background: -ms-linear-gradient(#f6f6f6 0, #fff 50px);
      	background: -moz-linear-gradient(#f6f6f6 0, #fff 50px);
      	background: -webkit-linear-gradient(#f6f6f6 0, #fff 50px);
      	box-shadow: 0 3px 10px rgba(0,0,0,0.15);
      	-o-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
      	-ms-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
      	-moz-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
      	-webkit-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
      }
      
      #proxy-status .placeholder {
      	width: 100%;
      	height: 100%;
      	font-size: 14px;
      	line-height: 1.2em;
      }
      
      #proxy-status .legend table {
      	border-spacing: 5px;
      }
      
      #proxy-status .control-group {
      	padding: 0px 15px;
      }
      
      #proxy-status #hostname.failed {
      	color: red;
      }
      
      #proxy-status button#toggle {
      	width: 100px;
      	height: 35px;
      }
      
      #proxy-status button {
      	color: white;
      	font-weight: bold;
      }
      
      #proxy-status button.on {
      	background-color: green;
      }
      
      #proxy-status button.off {
      	background-color: red;
      }
    </style>
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
    <script src="../components/html5shiv/dist/html5shiv.min.js"></script>
    <script src="../components/respond/dest/respond.min.js"></script>
    <![endif]-->
    <!-- IE8 requires jQuery and Bootstrap JS to load in head to prevent rendering bugs -->
    <!-- IE8 requires jQuery v1.x -->
    <script src="//code.jquery.com/jquery-1.10.2.min.js"></script>
    <script src="../components/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="../dist/js/patternfly.min.js"></script>
    <script src="../components/bootstrap-select/bootstrap-select.min.js"></script>
    <script>
      // Initialize Boostrap-select
      $(document).ready(function() {
        $('.selectpicker').selectpicker();
      });
    </script>
    <!-- haproxy stuff -->
    <script language="javascript" type="text/javascript" src="http://www.flotcharts.org/flot/jquery.flot.js"></script>
    <script language="javascript" type="text/javascript" src="http://www.flotcharts.org/flot/jquery.flot.time.js"></script>
    <script type="text/javascript">

	$(function() {
		updateInterval = 1;
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
				roof:        10,
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
//						twelveHourClock: true
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
					var y = parseFloat(fields[4]);
                                        console.log('field 4: ' + y);
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

	</script>
  </head>
  <body>
    <nav class="navbar navbar-default navbar-pf" role="navigation">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse-1">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="/">
          <img src="../dist/img/brand.svg" alt="PatternFly" />
        </a>
      </div>
      <div class="collapse navbar-collapse navbar-collapse-1">
        <ul class="nav navbar-nav navbar-primary">
          <li class="active">
            <a href="#">Home</a>
          </li>
        </ul>
      </div>
    </nav>
    <div class="container-fluid">
      <div class="row">
        <div class="col-md-12">
          <h1>Welcome to an OpenShift Application!</h1>
          <p>The purpose of this application is to demonstrate several interesting features about OpenShift. We hope you enjoy it!</p>
        </div>
      </div>
      <div class="row">
        <div class="col-md-6 col-md-offset-3">
          <h2>Application Information</h2>
          <% String variable = System.getenv("OPENSHIFT_APP_UUID"); %>
          <table class="table table-striped table-bordered table-hover">
            <thead>
              <tr>
                <th>Env Var</th>
                <th>Value</th>
              <tr>
            </thead>
            <tbody>
              <tr>
                <td>Instance UUID</td>
                <td><%= System.getenv("OPENSHIFT_GEAR_UUID") %></td>
              </tr>
              <tr>
                <td>Instance Internal IP</td>
                <td><%= System.getenv("OPENSHIFT_JBOSSEAP_IP") %></td>
              </tr>
              <tr>
                <td>Instance Internal Port</td>
                <td><%= System.getenv("OPENSHIFT_JBOSSEAP_HTTP_PORT") %></td>
              </tr>
              <tr>
                <td>Instance Memory (Allowed [MB])</td>
                <td><%= System.getenv("OPENSHIFT_GEAR_MEMORY_MB") %></td>
              </tr>
              <tr>
                <td>Instance Memory (Used [MB])</td>
                <% int mb = 1024*1024; %>
                <td><%= (Runtime.getRuntime().totalMemory()) / mb %></td>
              </tr>
              <tr>
                <td>Node (header)</td>
                <td><%= request.getHeader("x-forwarded-server") %></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="row" id="proxy-status">
        <div class="col-md-6 col-md-offset-3">
          <h2>HAProxy Status</h2>
	  <h3 id="hostname"></h3>
	  <div id="content">
	    <div class="container">
	    	<div id="placeholder" class="placeholder"></div>
	    </div>
	    <div class="control-group">
	      <span>
	        <button id="toggle" class="on" value="on">ON</button>
	      </span>
	      <span style="float: right">
	        Refresh rate:
	        <select id="updateInterval" style="margin: 5px">
	          <option value="1" selected>1</option>
	          <option value="2">2</option>
	          <option value="5">5</option>
	          <option value="10">10</option>
	          <option value="20">20</option>
	          <option value="30">30</option>
	          <option value="60">60</option>
	          <option value="120">120</option>
	        </select>
	        seconds
	      </span>
            </div>
	  </div>
        </div>
      </div>
    </div>
  </body>
</html>
