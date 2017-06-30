<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page language="java" import="java.sql.*;"%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Page</title>
</head>
<body>
<%
  String userName = request.getParameter("userName");
	
	Connection conn = null;
    String url = "jdbc:mysql://nacolias.com:3306/cse135_test";
    String driver = "com.mysql.jdbc.Driver";
    String dbUsername = "admin135"; 
    String dbPassword = "admin135";
	String select_sql = "select name,id from Customers where name = ?";

		try {
			// Load mysql Driver class file
			Class.forName(driver);
			conn = DriverManager.getConnection(url, dbUsername, dbPassword);
	
			PreparedStatement pstmt = conn.prepareStatement(select_sql);
			pstmt.setString(1,userName);
			ResultSet rs = pstmt.executeQuery();
			
		    if(rs.next())
			{
				  System.out.println("Username found, logging in");
				  session.setAttribute("userid",userName);
				  session.setAttribute("customer_id", rs.getInt("id"));
				  //session.setAttribute("role", rs.getString("role"));
				  /*
				  if(rs.getString("role").equals("owner"))
				  {
					  response.sendRedirect("products.jsp");
				  }
				  else
				  {
					  response.sendRedirect("product_browsing.jsp");
				  }
				  */
				  response.sendRedirect("product_browsing.jsp");

			}
			else
			{
               response.sendRedirect("login.jsp");
			}
		    
	      System.out.println("Connected to the database");
	      conn.close();
	      System.out.println("Disconnected from database");
	    } catch (Exception e) {
	      e.printStackTrace();
	    }
%>

</body>
</html>