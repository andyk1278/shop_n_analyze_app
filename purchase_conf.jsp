

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Your Order confirmation</title>
</head>
<body>
<jsp:include page="welcome.jsp" />
<table>
	<tr>
		
			<%@ page import="java.util.*,java.sql.*" %>
			<%
			
			Connection conn = null;
    		String url = "jdbc:mysql://nacolias.com:3306/cse135_test";
    		String driver = "com.mysql.jdbc.Driver";
    		String dbUsername = "admin135"; 
    		String dbPassword = "admin135";
			PreparedStatement pstmt = null;
			PreparedStatement pstmt1 = null;
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
			

			<%-- ------- SELECT Statement Code-------%>
			
			<td>	
			Your Purchase Confirmation Summary
			<table border="1">
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>SKU</th>
				<th>Category</th>
				<th>Price</th>
				<th>Amount</th>
				<th>Total</th>
			</tr>
			<%-- ------Iteration Code-------------- --%>
			<%
				int id = 0;
				String name = "";
				String sku = "";
				String category = "";
				double price = 0;
				
		%>
		
		<%-- --------Show current shopping cart------- --%>
			
			<% 
			pstmt = conn.prepareStatement("select Products.name as name,sku,cat.name as category,price,sum(amount) as amount,(price*sum(amount)) as total from cart,Products, Categories cat where cat.id=Products.cat_id and user=? and cart.product=Products.sku group by product;");
			pstmt.setString(1,session.getAttribute("userid").toString());
			cart_rs = pstmt.executeQuery();
				double cart_total = 0;
				while(cart_rs.next())
				{
					Integer prod_id = (Integer) cart_rs.getInt("sku");
					Integer cust_id = Integer.parseInt(session.getAttribute("customer_id").toString());
					Integer quantity = (Integer) cart_rs.getInt("amount");
					Integer total_cost = (Integer) cart_rs.getInt("total");

					
					pstmt1 = conn.prepareStatement("insert into Sales (product_id, customer_id, day, month, quantity, total_cost) " +
													"VALUES (?,?,?,?,?,?)");
					pstmt1.setInt(1, prod_id);
					pstmt1.setInt(2, Integer.parseInt(session.getAttribute("customer_id").toString()));
					pstmt1.setInt(3, Calendar.DAY_OF_MONTH + 1);
					pstmt1.setInt(4, Calendar.MONTH + 1);
					pstmt1.setInt(5, quantity);
					pstmt1.setInt(6, total_cost);
					int rowCount = pstmt1.executeUpdate();
			%>
					<tr>

						<td>
						<%=cart_rs.getString("sku") %>
						</td>
						<td>
						<%=cart_rs.getString("name")%>
						</td>
						<td>
						<%=cart_rs.getString("category") %>
						</td>
						<td>
						<%=cart_rs.getInt("amount") %>
						</td>
						<td>
						<%=cart_rs.getDouble("price") %>
						</td>
						<td>
						<%=cart_rs.getDouble("total") %>
						<%
							cart_total+=cart_rs.getDouble("total");
						%>
						</td>
					</tr>
			<%
				}
			%>
				<tr>
					<td />
					<td />
					<td />			
					<td />
					<td />
					<th>
						Total Amount Spent
					</th>
					<td>
						<%=cart_total%>
					</td>
				</tr>
			</table>
			
		<%-- --------Empty Cart Code-------- --%>	
		<%
			if(request.getParameter("action") != null && request.getParameter("action").equals("purchase")  )
			{
				pstmt = conn.prepareStatement("delete from cart where user=?");
				pstmt.setString(1,session.getAttribute("userid").toString());
				pstmt.executeUpdate();
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

		
	</tr>
	</table>
</body>
</html>