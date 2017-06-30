<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Welcome Page</title>
</head>
<body>

<%
	if(session.getAttribute("userid")!=null)
	{
	String user = session.getAttribute("userid").toString();
%>
	
	Hello <%= user%>
	<br/>
	
<%
		if(true) {
			%>
			<a href="product_browsing.jsp">Product Browsing</a>
			<br/>
			<a href="shopping_cart.jsp">Shopping Cart</a>
			<br/>
			<br/>
			<%
		}


		

	}
%>

</body>
</html>