<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Signup Page</title>
</head>
<body>
	Welcome to the Signup Page
	<p />

	<form method="GET" action="signup.jsp">
		<input type="text" name="name">Username <br /> <input
			type="text" name="age">Age <br /> <select name="state">
			<option value="" selected="selected">Select a State</option>
			<option value="AL">Alabama</option>
			<option value="AK">Alaska</option>
			<option value="AZ">Arizona</option>
			<option value="AR">Arkansas</option>
			<option value="CA">California</option>
			<option value="CO">Colorado</option>
			<option value="CT">Connecticut</option>
			<option value="DE">Delaware</option>
			<option value="DC">District Of Columbia</option>
			<option value="FL">Florida</option>
			<option value="GA">Georgia</option>
			<option value="HI">Hawaii</option>
			<option value="ID">Idaho</option>
			<option value="IL">Illinois</option>
			<option value="IN">Indiana</option>
			<option value="IA">Iowa</option>
			<option value="KS">Kansas</option>
			<option value="KY">Kentucky</option>
			<option value="LA">Louisiana</option>
			<option value="ME">Maine</option>
			<option value="MD">Maryland</option>
			<option value="MA">Massachusetts</option>
			<option value="MI">Michigan</option>
			<option value="MN">Minnesota</option>
			<option value="MS">Mississippi</option>
			<option value="MO">Missouri</option>
			<option value="MT">Montana</option>
			<option value="NE">Nebraska</option>
			<option value="NV">Nevada</option>
			<option value="NH">New Hampshire</option>
			<option value="NJ">New Jersey</option>
			<option value="NM">New Mexico</option>
			<option value="NY">New York</option>
			<option value="NC">North Carolina</option>
			<option value="ND">North Dakota</option>
			<option value="OH">Ohio</option>
			<option value="OK">Oklahoma</option>
			<option value="OR">Oregon</option>
			<option value="PA">Pennsylvania</option>
			<option value="RI">Rhode Island</option>
			<option value="SC">South Carolina</option>
			<option value="SD">South Dakota</option>
			<option value="TN">Tennessee</option>
			<option value="TX">Texas</option>
			<option value="UT">Utah</option>
			<option value="VT">Vermont</option>
			<option value="VA">Virginia</option>
			<option value="WA">Washington</option>
			<option value="WV">West Virginia</option>
			<option value="WI">Wisconsin</option>
			<option value="WY">Wyoming</option>
		</select><br /> <select name="role">
			<option value="owner">Owner</option>
			<option value="customer">Customer</option>
		</select> 
		<input type="hidden" name="action" value="insert" />
		<input type="submit" value="Click to Signup" />
	</form>
	<%@ page language="java" import="java.sql.*"%>
	<jsp:declaration>
	Statement stmt;
	Connection conn;
	ResultSet rs = null;
	String select_sql = "select name from Customers where name = ?";</jsp:declaration>

	<%
		String action = request.getParameter("action");
		// Check if an insertion is requested
		if (action != null && action.equals("insert") && request.getParameter("name") != null) {
			// Load mysql Driver class file
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(
					"jdbc:mysql://nacolias.com:3306/cse135_test", "admin135",
					"admin135");

			stmt = conn.createStatement();
            PreparedStatement pstmt = conn.prepareStatement(select_sql);
            pstmt.setString(1, request.getParameter("name"));
			rs = pstmt.executeQuery();
	%>
		<%
			int count = 0;
			while (rs.next()) {
				count++;
			}
			if(count==0){
				conn.setAutoCommit(false);
				System.out.println("No matches found, good to insert");
				String insert_sql = "insert into Customers (name,age,state) values (?,?,?)";
				PreparedStatement ins_pstmt = conn.prepareStatement(insert_sql);
				ins_pstmt.setString(1,request.getParameter("name"));
				//ins_pstmt.setString(2,request.getParameter("role"));
				ins_pstmt.setString(2,request.getParameter("age"));
				ins_pstmt.setString(3,request.getParameter("state"));
				ins_pstmt.executeUpdate();
				conn.commit();
				conn.setAutoCommit(true);
				out.println("Successful Signup");
			}
			else{
				out.println("Name Already Exists : Please try again");
			}
		%>
		<%
		conn.close(); 
		}
		%>

	
</body>
</html>