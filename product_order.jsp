<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Product Order Page</title>
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
			ResultSet cart_rs = null;
			
			String action = request.getParameter("action");

			try {
				// Load mysql Driver class file
				Class.forName(driver);
				conn = DriverManager.getConnection(url, dbUsername, dbPassword);
			%>
			<%-- ------- Add to cart  Code-------%>
			<%
			if (action != null && action.equals("add")) {
				//Begin Transaction
				conn.setAutoCommit(false);
				System.out.println(session.getAttribute("userid").toString());
				pstmt = conn.prepareStatement(
						"insert into cart (user, product, amount) values (?,?,?)");
				pstmt.setString(1, session.getAttribute("userid").toString());
				pstmt.setInt(2, Integer.parseInt(request.getParameter("id")));
				pstmt.setInt(3, Integer.parseInt(request.getParameter("amount")));
				int rowCount = pstmt.executeUpdate();
				
				// Commit transaction
				conn.commit();
				conn.setAutoCommit(true);
				response.sendRedirect("shopping_cart.jsp");
				}
			
			%>
			<%-- ------- SELECT Statement Code-------%>
			<%

			 	statement = conn.createStatement();
				rs = statement.executeQuery
					("SELECT * FROM Products where sku =" + request.getParameter("id"));

		
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
				<th>Name</th>
				<th>SKU</th>
				<th>Category</th>
				<th>Price</th>
				<th>Amount</th>
			</tr>
			<%-- ------Iteration Code-------------- --%>
			<%
			//	int id = 0;
				String name = "";
				String sku = "";
				String category = "";
				double price = 0;
				rs = statement.executeQuery
						("SELECT p.name,p.sku,cat.name,p.price FROM Products p,Categories cat where p.cat_id=cat.id and p.sku =" + request.getParameter("id"));
				
	//////////maybe dont need while loop here.. just a single rs.next()?? 	
				while(rs.next()) {
				//	id = rs.getInt("id");
					name = rs.getString("p.name");
					sku = rs.getString("p.sku");
					category = rs.getString("cat.name");
					price = rs.getDouble("price");
					
					
			%>
			<tr>
				<td>
					<%= name%>
				</td>
				<td>
					<%= sku%>
				</td>
				<td>
					<%= category %>
				</td>
				<td>
					<%= price%>
				</td>
				<form action="product_order.jsp" method="POST">
					<input type="hidden" name="action" value="add"/>
					<input type="hidden" value="<%=rs.getInt("sku") %>" name="id"/>
				<td>
					<input value="1" name="amount" size="15">
				</td>
					<%-- BUTTON --%>
				<td><input type="submit" value="Add to Cart"/></td>
				</form>
			</tr>
			
			<%
				}
			%>
		<%-- --------Show current shopping cart------- --%>
			<tr>
			<% 
				pstmt = conn.prepareStatement("select Products.name as name,sku,cat.name as category,price,sum(amount) as amount,(price*sum(amount)) as total from cart,Products, Categories cat where cat.id=Products.cat_id and user=? and cart.product=Products.sku group by product;");
				pstmt.setString(1,session.getAttribute("userid").toString());
				cart_rs = pstmt.executeQuery();
				
				while(cart_rs.next())
				{ 
			%>
				<tr>
					<td>
					<%=cart_rs.getString("name")%>
					</td>
					<td>
					<%=cart_rs.getString("sku") %>
					</td>
					<td>
					<%=cart_rs.getString("category") %>
					</td>
					<td>
					<%=cart_rs.getDouble("price") %>
					</td>
					<td>
					<%=cart_rs.getInt("amount") %>
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
		
	</tr>
	</table>
</body>
</html>