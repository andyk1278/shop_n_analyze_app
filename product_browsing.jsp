<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Product Browsing Page</title>
</head>
<body>
<jsp:include page="welcome.jsp" />
<table>
	<tr>
		
			<%@ page import="java.sql.*" %>
			<%
			
			Connection conn = null;
    		String url = "jdbc:mysql://nacolias.com:3306/cse135_test";
    		String driver = "com.mysql.jdbc.Driver";
    		String dbUsername = "admin135"; 
    		String dbPassword = "admin135";
			PreparedStatement pstmt = null;
			Statement statement = null;
			ResultSet rs = null;
			ResultSet cats_rs = null;
			
			String action = request.getParameter("action");

			try {
				// Load mysql Driver class file
				Class.forName(driver);
				conn = DriverManager.getConnection(url, dbUsername, dbPassword);
			%>
			

			<%-- ------- SELECT Statement Code-------%>
			<%
			if(action !=null && action.equals("search") )
			{
				//System.out.println(request.getParameter("name"));
				if(request.getParameter("category") != "null" && request.getParameter("name") != null)
				{
					//System.out.println(request.getParameter("category"));

					pstmt = conn.prepareStatement("Select * from Products where name=? and cat_id in (select id from Categories where name=?) order by sku");
					pstmt.setString(1, request.getParameter("name"));
					pstmt.setString(2,request.getParameter("category"));
					rs = pstmt.executeQuery();	

				}
				else if(request.getParameter("category") == "null" && request.getParameter("name") != null)
				{
					pstmt = conn.prepareStatement("Select * from Products where name=? order by sku");
					pstmt.setString(1, request.getParameter("name"));
					rs = pstmt.executeQuery();
				
				}
				else if(request.getParameter("name")==null && request.getParameter("category") != "null")
				{
					pstmt = conn.prepareStatement("Select * from Products where cat_id in (select id from Categories where name=?) order by sku");
					pstmt.setString(1,request.getParameter("category"));
					rs = pstmt.executeQuery();
				}
				else
				{
				 	statement = conn.createStatement();
					rs = statement.executeQuery
							("SELECT * FROM Products where sku=0 order by sku");
				}
				
			}
			else
			{
			 	statement = conn.createStatement();
				rs = statement.executeQuery
					("SELECT * FROM Products order by sku");
			}
		
			statement = conn.createStatement();
			cats_rs = statement.executeQuery("SELECT name from Categories");
			%>
			<td>
			<%
				while(cats_rs.next()){ %>
					<a href="product_browsing.jsp?action=search&category=<%=cats_rs.getString("name")%>"><%=cats_rs.getString("name") %></a>
					<br />
			<%
			}
			%>
		
		
			</td>
			<td>	
			<table border="1">
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>SKU</th>
				<th>Category</th>
				<th>Price</th>
			</tr>
			<%-- ------Iteration Code-------------- --%>
			<%
				int id = 0;
				String name = "";
				String sku = "";
				String category = "";
				double price = 0;
			
				while(rs.next()) {
					pstmt = conn.prepareStatement("Select name from Categories where id=?");
					pstmt.setString(1,rs.getString("cat_id"));
					cats_rs = pstmt.executeQuery();
					
					id = rs.getInt("sku");
					name = rs.getString("name");
					sku = rs.getString("sku");
					if(cats_rs.next()) {
						category = cats_rs.getString("name");
					} else {
						category = "none";
					}
					price = rs.getDouble("price");					
			%>
			<tr>
				<td>
					<a href="product_order.jsp?action=purchase&id=<%=id%>"><%=id %></a> 
				</td>
				<td>
					<a href="product_order.jsp?action=purchase&id=<%=id%>"><%=name %></a> 
				</td>
				<td>
					<a href="product_order.jsp?action=purchase&id=<%=id%>"><%=sku %></a>
				</td>
				<td>
					<a href="product_order.jsp?action=purchase&id=<%=id%>"><%=category %></a>
				</td>
				<td>
					<a href="product_order.jsp?action=purchase&id=<%=id%>"><%=price %></a>
				</td>
			</tr>
			<%
				}
			%>
		<%-- --------Close Connection Code-------- --%>
		<%
			rs.close();
			conn.close();
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
		finally {
			if(rs!=null) {
				try {
					rs.close();
				} catch (SQLException e) {}
				rs = null;
			}
			if(cats_rs!=null) {
				try {
					cats_rs.close();
				} catch (SQLException e) {}
				cats_rs = null;
			}
			if(statement!=null) {
				try {
					statement.close();
				} catch (SQLException e) {}
				statement = null;
			}
			if(pstmt!=null) {
				try {
					pstmt.close();
				} catch(SQLException e) {}
				pstmt = null;
			}
			if(conn!=null) {
				try {
					conn.close();
				} catch(SQLException e) {}
				conn = null;
			}
		}
		%>
		</table>
	</td>
		<td>
		Search Product Name
		<form action="product_browsing.jsp" method="GET">
					<input type="hidden" name="action" value="search"/>
					<input value="" name="name" size="30"/>
					<input type=hidden name="category" value="<%=request.getParameter("category")%>">
					<input type="submit" value="Search"/>
		</form>
		<br />
		<a href="product_browsing.jsp">Show All</a>
	
	</td>
	</tr>
	</table>
</body>
</html>