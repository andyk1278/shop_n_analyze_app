<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Customer Analytics Page</title>

<script language=Javascript type="text/javascript">

  var sel = document.getElementById('mode');
  
  var toggle = function() {
	  alert("called");
	  var div1 = document.getElementById('salesA');
	  var div2 = document.getElementById('salesB');
	  var selText = sel.options[sel.selectedIndex].text;
	  if (selText == "Customer Names")
	  {
		  div1.style.display = 'block';
	  	  div2.style.display = 'none';
	  } else {
		div1.stle.display = 'none';
	  	div2.style.display = 'block';
	  }
  }
</script>

</head>
<body>
<%@ page import="java.sql.*" %>
	<%

	//	if(action!= null && action.equals("next"))
		Connection conn = null;
  		String url = "jdbc:mysql://nacolias.com:3306/cse135_perf";
  		String driver = "com.mysql.jdbc.Driver";
  		String dbUsername = "admin135"; 
  		String dbPassword = "admin135";
  		
  		//Statements
		Statement statement = null;
  		Statement rowStatement = null;
  		Statement colStatement = null;
  		Statement cellStatement = null;
  		
  		//ResultSets
		ResultSet cats_rs = null;
		ResultSet states_rs = null;
		ResultSet currentRowsRs = null;
		ResultSet currentColsRs = null;
		ResultSet cellRs = null;
		
		//stored filter form information
  		int current_row = 0;
		int current_col = 0;
		String age = "age";
		String[] age_range = new String[2];
		String state = "state";
		int category_id = -1;
		String quarter = "quarter";
		String mode = "cust_name";
		String query_string = "";
		
		//stored results
		int[] product_id_arr = new int[10];
		int[] customer_id_arr = new int[10];
		
		
		try {
			// Load mysql Driver class file
			Class.forName(driver);
			conn = DriverManager.getConnection(url, dbUsername, dbPassword);
			statement = conn.createStatement();
			colStatement = conn.createStatement();
			rowStatement = conn.createStatement();
			cellStatement = conn.createStatement();
	%>

	<%!
		public String quarter_converter(String quarter)
		{
			if(quarter.equals("fall"))
			{
				return "(month>=9 or month<=11)";
			}
			else if(quarter.equals("winter"))
			{
				return "(month=12 or month<=2)";
			}
			else if(quarter.equals("spring"))
			{
				return "(month>=3 or month<=5)";
			}
			else if(quarter.equals("summer"))
			{
				return "(month>=6 or month<=9)";
			}
			else
			{
				return "(month>0 or month <13)";
			}
		}
	
		public String mode_converter(String mode)
		{
			if(!mode.equals("cust_state"))
			{
				return "c.name";
			}
			else
			{
				return "c.state";
			}
			
			
		}
	
	%>




	<%--Printout of Results --%>

	<%
		if(request.getParameter("current_row") != null)
		{
			current_row = Integer.parseInt(request.getParameter("current_row"));
		}
		if(request.getParameter("current_col") != null)
		{
			current_col = Integer.parseInt(request.getParameter("current_col"));
		}
		if(request.getParameter("mode") != null)
		{
			mode = request.getParameter("mode");
		}
		if(request.getParameter("age") != null)
		{
			age = request.getParameter("age");
			if(!age.equals("age"))
			{
				age_range = age.split("-");
			}
		}
		if(request.getParameter("state") != null)
		{
			state = request.getParameter("state");

		}
		if(request.getParameter("category_id") != null)
		{
			category_id = Integer.parseInt(request.getParameter("category_id"));
		}
		if(request.getParameter("quarter") != null)
		{
			quarter = request.getParameter("quarter");
		}
		
		
		//FROM HERE THIS NEEDS TO BE REDONE
			
		// 1111	
		if(!age.equals("age") && !state.equals("state") && !quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and state=\"" + state + "\" and " + quarter_converter(quarter) + "  and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
							+ "and state=\"" + state + "\" and " + quarter_converter(quarter) + " and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		// 1110
		else if(!age.equals("age") && !state.equals("state") && !quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and state=\"" + state + "\" and " + quarter_converter(quarter) + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + " and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and state=\"" + state + "\" and quarter=\"" + quarter + "\" and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		// 1101
		else if(!age.equals("age") && !state.equals("state") && quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and state=\"" + state + "\" and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
							+ "and state=\"" + state + "\" and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		// 1100
		else if(!age.equals("age") && !state.equals("state") && quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and state=\"" + state + "\" and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + " and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and state=\"" + state + "\" and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		// 1011
		else if(!age.equals("age") && state.equals("state") && !quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and " + quarter_converter(quarter) + "  and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
							+ "and " + quarter_converter(quarter) + " and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		// 1010
		else if(!age.equals("age") && state.equals("state") && !quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and " + quarter_converter(quarter) + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + " and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and quarter=\"" + quarter + "\" and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		// 1001
		else if(!age.equals("age") && state.equals("state") && quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
							+ "and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//1000
		else if(!age.equals("age") && state.equals("state") && quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, c.id, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + "  and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "c.age >= " + Integer.parseInt(age_range[0]) + " and c.age <= " + Integer.parseInt(age_range[1]) + " "
					+ "and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);

		}
		//0111
		else if(age.equals("age") && !state.equals("state") && !quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "state=\"" + state + "\" and " + quarter_converter(quarter) + "  and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "state=\"" + state + "\" and " + quarter_converter(quarter) + " and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0110
		else if(age.equals("age") && !state.equals("state") && !quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "state=\"" + state + "\" and " + quarter_converter(quarter) + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "state=\"" + state + "\" and quarter=\"" + quarter + "\" and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0101
		else if(age.equals("age") && !state.equals("state") && quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "state=\"" + state + "\" and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "state=\"" + state + "\" and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0100
		else if(age.equals("age") && !state.equals("state") && quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select c.name, c.state, product_id, p.name, count(total_cost) as order_count, sum(total_cost) as total_cost "
					+ "from Customers c, Products p, Sales s where "
					+ "state=\"" + state + "\" and s.customer_id = c.id and s.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "state=\"" + state + "\" and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0011
		else if(age.equals("age") && state.equals("state") && !quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select product_id, p.name, sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Product_Sum ps, Products p where "
					+ "quarter=\"" + quarter + "\" and ps.product_id = p.sku and p.cat_id=" + category_id + " "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ quarter_converter(quarter) + " and p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0010
		else if(age.equals("age") && state.equals("state") && !quarter.equals("quarter") && category_id==-1)
		{
			//Column Selection
			query_string = ("select product_id, p.name, sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Product_Sum ps, Products p where "
					+ "quarter=\"" + quarter + "\" and ps.product_id = p.sku "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Customer_Sum cs, Customers c where "
					+ "quarter=\"" + quarter + "\" and cs.customer_id = c.id "
					+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0001
		else if(age.equals("age") && state.equals("state") && quarter.equals("quarter") && category_id!=-1)
		{
			//Column Selection
			query_string = ("select product_id, p.name, sum(order_count) as order_count, sum(total_cost) as total_cost "
					+ "from Product_Sum ps, Products p where "
					+ "ps.product_id = p.sku and p.cat_id=" + category_id + " "
					+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
			currentColsRs = colStatement.executeQuery(query_string);
			
			
			//Row Selection
			query_string = ("select c.name, c.state, c.id, product_id, count(total_cost) as order_count, sum(total_cost) as total_cost "
							+ "from Customers c, Products p, Sales s where "
							+ "p.cat_id = " + category_id + " and s.customer_id = c.id and s.product_id = p.sku "
							+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
			currentRowsRs = rowStatement.executeQuery(query_string);
			
		}
		//0000
		else
		{

				//Column Selection
				query_string = ("select product_id, p.name, sum(order_count) as order_count, sum(total_cost) as total_cost "
						+ "from Product_Sum ps, Products p where "
						+ "ps.product_id = p.sku "
						+ "GROUP BY product_id ORDER BY total_cost desc limit " + current_col + ",10");
				currentColsRs = colStatement.executeQuery(query_string);
				
				
				//Row Selection
				query_string = ("select customer_id,state, name,sum(order_count) as order_count, sum(total_cost) as total_cost "
						+ "from Customer_Sum cs, Customers c where "
						+ "cs.customer_id = c.id "
						+ "GROUP BY " + mode_converter(mode) + " ORDER BY total_cost desc limit " + current_row + ",10");
				currentRowsRs = rowStatement.executeQuery(query_string);
		}
		
		// TO HERE THIS NEEDS TO BE REDONE
	%>
	
	<%--Table iteration --%>
	<table border="1">
	
		<tr>
			<th>
			<%
				if(!mode.equals("cust_state"))
				{
					out.println("Customer Name");
					System.out.println("Ran");
				}
				else
				{
					out.println("States");
					
				}
			%>
			</th>
			<%
			 	int i=0;
				while(currentColsRs.next())
				{
					System.out.println("Ran");
					%>
					<th>
						<%
							out.println(currentColsRs.getString("p.name"));
							product_id_arr[i] = currentColsRs.getInt("product_id");
							i++;
						%>
					</th>
					<%
				}
			%>
		</tr>
		<%
			while(currentRowsRs.next())
			{
				
				%>
				<tr>
					<th>
					<%
						if(!mode.equals("cust_state"))
						{
							out.println(currentRowsRs.getString("c.name"));
							//System.out.println("Ran");
						}
						else
						{
							out.println(currentRowsRs.getString("c.state"));
							
						}
						
					%>
					</th>
					<%
						for(int product_id : product_id_arr)
						{
							System.out.println(product_id);
							if(!mode.equals("cust_state"))
							{
								if(category_id==-1)
								{
									query_string = "select count(*) as order_count, sum(total_cost) as total_cost from Sales where "
											+ "customer_id=" + currentRowsRs.getInt("customer_id") + " and product_id=" + product_id + " and " + quarter_converter(quarter);
									cellRs = cellStatement.executeQuery(query_string); 
									cellRs.next();
								}
								else
								{
									query_string = "select count(*) as order_count, sum(total_cost) as total_cost from Sales where "
											+ "customer_id=" + currentRowsRs.getInt("c.id") + " and product_id=" + product_id + " and " + quarter_converter(quarter);
									cellRs = cellStatement.executeQuery(query_string); 
									cellRs.next();	
								}
							}
							else
							{
								query_string = "select count(*) as order_count, sum(total_cost) as total_cost from Sales s,Customers c where "
											+ "c.state=\"" + currentRowsRs.getString("c.state") + "\" and product_id=" + product_id + " and " + quarter_converter(quarter);
								System.out.println(query_string);
								cellRs = cellStatement.executeQuery(query_string); 
								cellRs.next();
							}
							%>
							<td>
							<%
								if(cellRs.getString("total_cost")==null)
								{
									out.println("$0 , 0");
								}
								else
								{
									out.println("$" + cellRs.getString("total_cost") + " , " + cellRs.getString("order_count")); 
								}
								
								
							%>
							</td>
							<%
						}
					
					
					%>
				</tr>
				<%
			}
		%>
		
	
	
	
	
	</table>











	<%-- Next Buttons --%>
	<table>
		<tr>
			<td>
				<form action="performance_analytics.jsp" method="GET">
					<input type="hidden" name="action" value="next">
					<input type="hidden" name="table" value="customer">
					<input type="hidden" name="current_row" value=<%=current_row + 10%>>
					<input type="hidden" name="current_col" value=<%=current_col%>>
					<input type=hidden name="mode" value=<%=mode %>>
					<input type=hidden name="age" value=<%=age %>>
					<input type=hidden name="state" value=<%=state %>>
					<input type=hidden name="category_id" value=<%=category_id %>>
					<input type=hidden name="quarter" value=<%=quarter %>>
					Next 10 Customers
				<input type="submit">
				</form>
			</td>
			<td>
				<form action="performance_analytics.jsp" method="GET">
					<input type="hidden" name="action" value="next">
					<input type="hidden" name="table" value="product">
					<input type="hidden" name="current_row" value=<%=current_row%>>
					<input type="hidden" name="current_col" value=<%=current_col + 10%>>
					<input type=hidden name="mode" value=<%=mode %>>
					<input type=hidden name="age" value=<%=age %>>
					<input type=hidden name="state" value=<%=state %>>
					<input type=hidden name="category_id" value=<%=category_id %>>
					<input type=hidden name="quarter" value=<%=quarter %>>
					Next 10 Products
					<input type="submit">
				</form>
			</td>
		</tr>
	</table>




	<%-- Filters Table --%>

	<form action="performance_analytics.jsp" method="GET">
		<table id="filters" border="1">
			<tr>
				<th>Row Type</th>
				<th>Age</th>
				<th>State</th>
				<th>Category</th>
				<th>Quarter</th>
			</tr>
			<tr>
				<td>
					<select id="mode" name="mode" onchange="toggle();">
						<option value="cust_name" selected="selected">Customer Names</option>
						<option value="cust_state">Customer States</option>	
					</select>
				</td>
				<td>
					<select name="age">
						<option value="age" selected="selected">All Ages</option>
						<%									
							for(i = 0; i < 100; i=i+10) {
						%>
								<option value="<%=i + "-" + (i+9)%>">
								<%=i + " - " + (i+9)%>
								</option>
						<%			
							}
						%>
					</select>
				</td>

				<td>
					<select name="state">
						<option value="state" selected="selected">All States</option>
						<%
							states_rs = statement.executeQuery("SELECT distinct state from Customers order by state");
							while(states_rs.next()) {
						%>
								<option value="<%=states_rs.getString("state")%>">
								<%=states_rs.getString("state")%>
								</option>
						<%
							}
						%>
					</select>
				</td>

				<td>
					<select name="category_id">
						<option value="-1" selected="selected">All Categories</option>
						<%
							cats_rs = statement.executeQuery("SELECT id,name from Categories order by name");
							while(cats_rs.next()) {
						%>
								<option value="<%=cats_rs.getString("id")%>">
								<%=cats_rs.getString("name")%>
								</option>
						<%
							}
						%>
					</select>
				</td>

				<td>
					<select name="quarter">
						<option value="quarter" selected="selected">All Year</option>
						<option value="fall">Fall</option>
						<option value="winter">Winter</option>
						<option value="spring">Spring</option>
						<option value="summer">Summer</option>
					</select>
					<input type="hidden" name="current_col" value=<%=0 %>>
					<input type="hidden" name="current_row" value=<%=0 %>>
				</td>
				<%-- BUTTON --%>
				<td><input type="submit" value="Run Query"></td>
				
			</tr>
		</table>
	</form>
	<%
		conn.close();
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
		finally {
			
			if(conn!=null) {
				try {
					conn.close();
				} catch(SQLException e) {}
				conn = null;
			}
			if(cats_rs!=null) {
				try {
					cats_rs.close();
				} catch (SQLException e) {}
				cats_rs = null;
			}
			if(states_rs!=null) {
				try {
					states_rs.close();
				} catch (SQLException e) {}
				states_rs = null;
			}
			if(currentRowsRs!=null) {
				try {
					currentRowsRs.close();
				} catch (SQLException e) {}
				currentRowsRs = null;
			}
			if(currentColsRs!=null) {
				try {
					currentColsRs.close();
				} catch (SQLException e) {}
				currentColsRs = null;
			}
		}
	%>


</body>
</html>