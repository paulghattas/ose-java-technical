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
    <link href="../components/haproxy-status.css" rel="stylesheet" media="screen, print">
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
    <script src="../components/haproxy-status.js"></script>
    <script>
      // Initialize Boostrap-select
      $(document).ready(function() {
        $('.selectpicker').selectpicker();
      });
    </script>
    <!-- haproxy stuff -->
    <script language="javascript" type="text/javascript" src="http://www.flotcharts.org/flot/jquery.flot.js"></script>
    <script language="javascript" type="text/javascript" src="http://www.flotcharts.org/flot/jquery.flot.time.js"></script>
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
          <div class="panel-group" id="accordion">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h2 class="panel-title">
                  <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                    Application Information
                  </a>
                </h2>
              </div>
            </div>
            <div id="collapseOne" class="panel-collapse collapse in">
              <div class="panel-body">
                Inside the panel!
              </div>
            </div>
          </div>
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
	          <option value="1">1</option>
	          <option value="2" selected>2</option>
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
      <div class="row">
        <div class="col-md-6 col-md-offset-3">
          <div class="panel-group" id="accordion">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4 class="panel-title">
                  <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                    Collapsible Group Item #1
                  </a>
                </h4>
              </div>
              <div id="collapseOne" class="panel-collapse collapse in">
                <div class="panel-body">
                  Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
                </div>
              </div>
            </div>
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4 class="panel-title">
                  <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
                    Collapsible Group Item #2
                  </a>
                </h4>
              </div>
              <div id="collapseTwo" class="panel-collapse collapse">
                <div class="panel-body">
                  Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
                </div>
              </div>
            </div>
            <div class="panel panel-default">
              <div class="panel-heading">
                <h4 class="panel-title">
                  <a data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
                    Collapsible Group Item #3
                  </a>
                </h4>
              </div>
              <div id="collapseThree" class="panel-collapse collapse">
                <div class="panel-body">
                  Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
