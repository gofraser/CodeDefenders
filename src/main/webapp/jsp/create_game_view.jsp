<!DOCTYPE html>
<html>

<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

	<!-- Title -->
	<title>Code Defenders - Create Game</title>

	<!-- App context -->
	<base href="${pageContext.request.contextPath}/">

	<!-- jQuery -->
	<script src="js/jquery.min.js" type="text/javascript" ></script>

	<!-- Bootstrap -->
	<script src="js/bootstrap.min.js" type="text/javascript" ></script>
	<link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />

	<!-- Bootstrap plugins -->
	<!-- toggle -->
	<link href="css/bootstrap-toggle_2.2.0.min.css" rel="stylesheet" type="text/css" />
	<script src="js/bootstrap-toggle_2.2.0.min.js" type="text/javascript" ></script>
	<!-- select -->
	<link href="css/bootstrap-select_1.9.3.min.css" rel="stylesheet" type="text/css" />
	<script src="js/bootstrap-select_1.9.3.min.js" type="text/javascript" ></script>

	<!-- Game -->
	<link href="css/gamestyle.css" rel="stylesheet" type="text/css" />

	<script>
		$(document).on('ready', function() {
			$("#fileUpload").fileinput({showCaption: false});
		});
	</script>
</head>

<body>

<%@ page import="org.codedefenders.DatabaseAccess" %>
<%@ page import="org.codedefenders.GameClass" %>
<nav class="navbar navbar-inverse navbar-fixed-top">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-1" aria-expanded="false">
			</button>
			<a class="navbar-brand" href="/">
				<span><img class="logo" href="/" src="images/logo.png"/></span>
				Code Defenders
			</a>
		</div>
		<div class= "collapse navbar-collapse" id="navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="games/user">My Games</a></li>
				<li><a href="games/open">Open Games</a></li>
				<li class="active"><a href="games/create">Create Game</a></li>
				<li><a href="games/history">History</a></li>
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<li></li>
				<li>
					<p class="navbar-text">
						<span class="glyphicon glyphicon-user" aria-hidden="true"></span>
						<%=request.getSession().getAttribute("username")%>
					</p>
				</li>
				<li><input type="submit" form="logout" class="btn btn-inverse navbar-btn" value="Log Out"/></li>
			</ul>
		</div>
	</div>
</nav>

<form id="logout" action="login" method="post">
	<input type="hidden" name="formType" value="logOut">
</form>



<div id="creategame" class="container">
	<form id="create" action="games" method="post" class="form-creategame">
		<h2>Create Game</h2>
		<input type="hidden" name="formType" value="createGame">
		<table class="tableform">
			<tr>
				<td>Java Class</td>
				<td>
					<select name="class" class="form-control selectpicker" data-size="large" >
						<% for (GameClass c : DatabaseAccess.getAllClasses()) { %>
						<option value="<%=c.id%>"><%=c.name%></option>
						<%}%>
					</select>
				</td>
				<td>
					<a href="games/upload" class="text-center new-account">Upload Class</a>
				</td>
			</tr>
			<tr>
				<td>Role</td> <td><input type="checkbox" id="role" name="role" class="form-control" data-size="large" data-toggle="toggle" data-on="Attacker" data-off="Defender" data-onstyle="success" data-offstyle="primary"></td>
			</tr>
			<tr>
				<td>Rounds</td><td><input class="form-control" type="number" name="rounds" value="3" min="1" max="10"></td>
			</tr>
			<tr>
				<td>Level</td> <td><input type="checkbox" id="level" name="level" class="form-control" data-size="large" data-toggle="toggle" data-on="Easy" data-off="Hard" data-onstyle="info" data-offstyle="warning">
			</tr>
		</table>
		<button class="btn btn-lg btn-primary btn-block" type="submit" value="Create">Create</button>
	</form>
</div>
</body>
</html>
