<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Categories Page</title>
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
			String select_sql = "select name from Customers where name = ?";
			PreparedStatement pstmt = null;
			Statement statement = null;
			ResultSet rs = null;
			ResultSet prods_rs = null;

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
					pstmt = conn.prepareStatement(
							"insert into Categories (name, description) values (?,?)");
					pstmt.setString(1, request.getParameter("name"));
					pstmt.setString(2, request.getParameter("description"));

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
					pstmt = conn.prepareStatement("update Categories set name = ?, description = ? where id = ?");
					pstmt.setString(1, request.getParameter("name"));
					pstmt.setString(2, request.getParameter("description"));
					pstmt.setString(3, request.getParameter("id"));
					
					int rowCount = pstmt.executeUpdate();
					
					// Commit transaction
					conn.commit();
					conn.setAutoCommit(true);
				}
			%>
			
			<%-- ------------DELETE Code ------------ --%>
			<%
				if(action !=null && action.equals("delete")) {
					
					//Checking if this category is able to be deleted
					pstmt = conn.prepareStatement("select * FROM Products WHERE cat_id=?");
					pstmt.setString(1, request.getParameter("id"));
					prods_rs = pstmt.executeQuery();	
					
					if (!prods_rs.next()) {
						conn.setAutoCommit(false);
						
						pstmt = conn.prepareStatement("delete from Categories where id = ?");
						
						pstmt.setString(1, request.getParameter("id"));
						int rowCount = pstmt.executeUpdate();
						
						// Commit transaction
						conn.commit();
						conn.setAutoCommit(true);
					} else {
						out.println("ERROR: Cannot delete a category that products belong to. Please delete products first.");
					}
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
						pstmt = conn.prepareStatement("Select * from Categories where name=? and description=? order by id");
						pstmt.setString(1, request.getParameter("name"));
						pstmt.setString(2,request.getParameter("description"));
						rs = pstmt.executeQuery();	

					}
					else if(request.getParameter("category") == "null" && request.getParameter("name") != null)
					{
						pstmt = conn.prepareStatement("Select * from Categories where name=? order by id");
						pstmt.setString(1, request.getParameter("name"));
						rs = pstmt.executeQuery();
					
					}
					else if(request.getParameter("name")==null && request.getParameter("description") != "null")
					{
						pstmt = conn.prepareStatement("Select * from Categories where description=? order by id");
						pstmt.setString(1, request.getParameter("description"));
						rs = pstmt.executeQuery();
					}
					else
					{
					 	statement = conn.createStatement();
						rs = statement.executeQuery
							("SELECT * FROM Categories where id=0 order by id");
					}
					
				}
				else
				{
				 	statement = conn.createStatement();
					rs = statement.executeQuery
						("SELECT * FROM Categories order by id");
				}		
				
			%>
				
			<%-- ------- Checking If Products Have This Category-------%>

		
		<td>
			<table border="1">
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>Description</th>
			</tr>
			<tr>
				<form action="categories.jsp" method="POST">
					<input type="hidden" name="action" value="insert"/>
					<th>&nbsp;</th>
					<th><input value="" name="name" size="15"/></th>
					<th><input value="" name="description" size="15"/></th>

					<th><input type="submit" value="Insert"/></th>
				</form>
			</tr>
			
			<%-- ------Iteration Code-------------- --%>
			<%
				while(rs.next()) {
			%>
			<tr>

				<form action="categories.jsp" method="GET">
					<input type="hidden" name="action" value="update"/>
					<input type="hidden" name="id" value="<%=rs.getInt("id") %>"/>
				<td>
					<%=rs.getInt("id") %>
				</td>
				<td>
					<input value="<%=rs.getString("name") %>" name="name" size="15"/>
				</td>
				<td>
					<input value="<%=rs.getString("description") %>" name="description" size="15"/>
				</td>
				
				<%-- BUTTON --%>
				<td><input type="submit" value="Update"></td>
				</form>
				
				<form action="categories.jsp" method="POST">
					<input type="hidden" name="action" value="delete"/>
					<input type="hidden" value="<%=rs.getInt("id") %>" name="id"/>
					<input type="hidden" value="<%=rs.getString("name") %>" name="name"/>
					
					<%-- BUTTON --%>
					<% 
					//Checking if this category is able to be deleted
					pstmt = conn.prepareStatement("select * FROM Products WHERE cat_id=?");
					pstmt.setString(1, rs.getString("id"));
					prods_rs = pstmt.executeQuery();	
					%>
					
				<td><% if (!prods_rs.next()) { %>
					<input type="submit" value="Delete"/>
  				<% } %>
  				</td>
  				
				</form>
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
			if(prods_rs!=null) {
				try {
					prods_rs.close();
				} catch (SQLException e) {}
				prods_rs = null;
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
	
	</tr>
</table>
</body>
</html>