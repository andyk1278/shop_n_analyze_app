<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Page</title>
</head>
<body>
	Welcome to the Login Page
	<p />
	<%@ page language="java" import="java.sql.*"%>
	
	<form name="loginform" method="POST" action="loginmid.jsp" onsubmit="return validLogin();">
		Username: <input type="text" name="userName" value=""> 
		<input type="submit" name="Submit" value="Login" />
	</form>

</body>
</html>