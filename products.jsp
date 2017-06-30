<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Products Page</title>
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
			String select_sql = "select name from customers where name = ?";
			PreparedStatement pstmt = null;
			Statement statement = null;
			ResultSet rs = null;
			ResultSet cats_rs = null;

			try {
				// Load mysql Driver class file
				Class.forName(driver);
				conn = DriverManager.getConnection(url, dbUsername, dbPassword);
			%>
			
			<%-- ------- INSERT Code ------ --%>
			<%
				String action = request.getParameter("action");
				// Check if an insertion is requested
				if (action != null && action.equals("insert")) {
					//Begin Transaction
					conn.setAutoCommit(false);
					
					pstmt = conn.prepareStatement("Select id from Categories where name=?");
					pstmt.setString(1, request.getParameter("category"));
					rs = pstmt.executeQuery();
					
					pstmt = conn.prepareStatement(
							"insert into Products (sku, name, cat_id, price) values (?,?,?,?)");
					pstmt.setString(1, request.getParameter("sku"));
					pstmt.setString(2, request.getParameter("name"));
					//pstmt.setString(3, request.getParameter("cat_id"));
					if(rs.next()) {
						pstmt.setString(3, rs.getString("id"));
					} else {
						pstmt.setString(3,"0");
					}
					pstmt.setDouble(4, Double.parseDouble(request.getParameter("price")));
					int rowCount = pstmt.executeUpdate();
					
					// Commit transaction
					conn.commit();
					conn.setAutoCommit(true);
				}
			%>
			
			<%-- ---------UPDATE Code-------------- --%>
			<%
				if(action !=null && action.equals("update")) {
					conn.setAutoCommit(false);
					
					pstmt = conn.prepareStatement("Select id from Categories where name=?");
					pstmt.setString(1, request.getParameter("category"));
					rs = pstmt.executeQuery();				
					
					pstmt = conn.prepareStatement("update Products set sku = ?, name = ?, cat_id = ?, price = ? where sku = ?");
					pstmt.setString(1, request.getParameter("sku"));
					pstmt.setString(2, request.getParameter("name"));
					//pstmt.setString(3, request.getParameter("cat_id"));
					if(rs.next()) {
						pstmt.setString(3, rs.getString("id"));
					} else {
						pstmt.setString(3, "0");
					}
					pstmt.setDouble(4, Double.parseDouble(request.getParameter("price")));
					pstmt.setString(5, request.getParameter("sku"));
					int rowCount = pstmt.executeUpdate();
					
					// Commit transaction
					conn.commit();
					conn.setAutoCommit(true);
				}
			%>
			
			<%-- ------------DELETE Code ------------ --%>
			<%
				if(action !=null && action.equals("delete")) {
					conn.setAutoCommit(false);
					pstmt = conn.prepareStatement("delete from Products where sku = ?");
					
					pstmt.setString(1, request.getParameter("sku"));
					int rowCount = pstmt.executeUpdate();
					
					// Commit transaction
					conn.commit();
					conn.setAutoCommit(true);
				}
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
						//pstmt = conn.prepareStatement("Select * from Products where name=? and cat_id=? order by sku");
						pstmt.setString(1, request.getParameter("name"));
						pstmt.setString(2,request.getParameter("category"));
						//pstmt.setString(2,request.getParameter("cat_id"));
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
						//pstmt = conn.prepareStatement("Select * from Products where cat_id=? order by sku");
						pstmt.setString(1,request.getParameter("category"));
						//pstmt.setString(1, request.getParameter("cat_id"));
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
		<%-- ------- Categories Links -------%>
		<td>
		<%
			while(cats_rs.next()){ %>
			<a href="products.jsp?action=search&category=<%=cats_rs.getString("name")%>"><%=cats_rs.getString("name") %></a>
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
			<tr>
				<form action="products.jsp" method="POST">
					<input type="hidden" name="action" value="insert"/>
					<th>&nbsp;</th>
					<th><input value="" name="name" size="15"/></th>
					<th><input value="" name="sku" size="15"/></th>
					<th>
						<select name="category">
						<%
							cats_rs = statement.executeQuery("SELECT name from Categories");
							while(cats_rs.next()) {
						%>
							<option value="<%=cats_rs.getString("name")%>"
										> <%=cats_rs.getString("name")%>
						</option>			
						<%
							}
						%>
					
					</select></th>
					<th><input value="" name="price" size="15"/></th>
					<th><input type="submit" value="Insert"/></th>
				</form>
			</tr>
			<%-- ------Iteration Code-------------- --%>
			<%
				while(rs.next()) {
			%>
			<tr>

				<form action="products.jsp" method="POST">
					<input type="hidden" name="action" value="update"/>
					<input type="hidden" name="sku" value="<%=rs.getInt("sku") %>"/>
				<td>
					<%=rs.getInt("sku") %>
				</td>
				<td>
					<input value="<%=rs.getString("name") %>" name="name" size="15"/>
				</td>
				<td>
					<input value="<%=rs.getString("sku") %>" name="sku" size="15"/>
				</td>
				<td>
					<select name="category">
					<%
						cats_rs = statement.executeQuery("SELECT name,id from Categories");
						while(cats_rs.next()) {
						%>
						<option value="<%=cats_rs.getString("name")%>"
										<%
											//System.out.println(cats_rs.getString("id") + "==" + rs.getString("cat_id") );
											if(cats_rs.getString("id").equals(rs.getString("cat_id"))){
												//System.out.println("Match");
												out.write(" SELECTED");
											}
										%>
										> <%=cats_rs.getString("name")%>
						</option>			
						<%
					}
					%>
					
					</select>
					
				</td>
				<td>
					<input value="<%=rs.getDouble("price") %>" name="price" size="15"/>
				</td>
				
				<%-- BUTTON --%>
				<td><input type="submit" value="Update"></td>
				</form>
				<form action="products.jsp" method="POST">
					<input type="hidden" name="action" value="delete"/>
					<input type="hidden" value="<%=rs.getInt("sku") %>" name="sku"/>
					<%-- BUTTON --%>
				<td><input type="submit" value="Delete"/></td>
				</form>
			</tr>
			<%
				}
			%>
		<%-- --------Close Connection Code-------- --%>
		<%
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
			if(statement!=null){
				try{
					statement.close();
				}
				catch(SQLException e) {}
				statement=null;
			}
		}
		%>
		</table>
	</td>
	<%-- --------Close Connection Code-------- --%>
	<td>
		Search Product Name
		<form action="products.jsp" method="GET">
					<input type="hidden" name="action" value="search"/>
					<input value="" name="name" size="30"/>
					<input type=hidden name="category" value="<%=request.getParameter("category")%>">
					<input type="submit" value="Search"/>
		</form>
		<br />
		<a href="products.jsp">Show All</a>
	</td>

	</tr>
</table>
</body>
</html>