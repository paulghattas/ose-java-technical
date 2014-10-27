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
    <title>Form - PatternFly</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="../dist/img/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../dist/img/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../dist/img/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../dist/img/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="../dist/img/apple-touch-icon-57-precomposed.png">
    <link href="../dist/css/patternfly.css" rel="stylesheet" media="screen, print">
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
                <td>Instance Memory (Allowed)</td>
                <td><%= System.getenv("OPENSHIFT_GEAR_MEMORY_MB") %></td>
              </tr>
              <tr>
                <td>Instance Memory (Used)</td>
                <td><%= java.lang.Runtime.totalMemory() %></td>
              </tr>
              <tr>
                <td>Node (header)</td>
                <td><%= request.getHeader("x-forwarded-server") %></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </body>
</html>
