import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Scanner;
import java.util.Vector;
import java.util.Set;
import java.util.Iterator;
import java.util.HashSet;
import java.io.File;
import java.lang.Math;
import java.io.PrintWriter;
import java.io.FileWriter;
import java.io.IOException;

public class DataGenerator {
	private final static String[] CATEGORIES = { "chair", "table", "computer",
			"keyboard", "burger", "french fries", "bike", "helmet", "couch",
			"mouse", "dog", "cat", "fish", "cell phone", "sweater", "pants",
			"shirt", "underwear", "sandwich", "bagel", "glove", "hat", "wheel",
			"car", "jacket", "coat", "monitor", "pen", "pencil", "paper",
			"notebook", "backpack", "umbrella", "surfboard", "box", "cabinet",
			"trunk", "shoe", "sandal", "glasses", "hoodie", "flowers",
			"sponge", "myster object", "spaghetti sauce", "beef", "fish",
			"pork", "shrimp", "scallops" };

	private final static String[] ADJECTIVES = { "smelly", "old", "antiquated",
			"tall", "short", "narrow", "wide", "hoodrat", "turrible",
			"indestructible", "sexy", "invisible", "barf-inducing", "rustic",
			"slimy", "hairy", "new", "sparkly", "ugly", "pretty", "perfect",
			"impeccable", "scratched", "moldy", "wet", "ancient", "modern",
			"cheap", "expensive", "strong", "weak", "boring", "best", "worst",
			"good", "bad", "large", "fast", "strange", "sleek", "smooth",
			"bumpy", "rough", "jagged", "spikey", "warped", "pointy", "tiny",
			"microscopic", "giant" };
	private final static String[] COLORS = { "white", "blue", "green", "red",
			"yellow", "black", "brown", "purple", "teal", "orange", "beige",
			"tan", "maroon", "burgundy", "crimson", "amber", "bronze",
			"fuchsia", "ruby", "aqua", "grey", "pink", "olive", "violet",
			"chartreuse", "chestnut", "salmon", "khaki", "coral", "magenta",
			"lavender", "indigo", "navy", "rose", "silver", "bronze", "gold",
			"copper", "plum", "turquoise", "periwinkle" };

	private final static String[] STATES = { "AL", "AK", "AZ", "AR", "CA",
			"CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS",
			"KY", "LA", "ME", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT",
			"NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR",
			"PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV",
			"WI", "WY" };

    private static int M = 10000;

    public static void setM(int m)
    {
        M = m;
    }
    
	private static int getDaysInMonth(int m) {
		assert (m >= 1 && m <= 12);

		if (m == 1 || m == 3 || m == 5 || m == 7 || m == 9 || m == 10
				|| m == 12)
			return 31;
		else if (m == 4 || m == 6 || m == 8 || m == 11)
			return 30;
		else
			return 28;
	}

	private static void getNames(String path, Vector<String> vec) {
		try {
			Scanner reader = new Scanner(new File(path));
			while (reader.hasNextLine()) {
				vec.add((String) reader.nextLine().trim());
			}
		} catch (Exception e) {
			System.out.println("Couldn't getNames for file: " + path);
		}
	}

	private static void createCategoriesTable(Connection conn)
			throws SQLException {
		/*
		PreparedStatement createCategoriesPS = conn
				.prepareStatement("CREATE TABLE Categories (id SERIAL PRIMARY KEY, name TEXT NOT NULL, description TEXT);");
		if (createCategoriesPS != null) {
			createCategoriesPS.execute();
			createCategoriesPS.close();
		}
		*/



		PreparedStatement insertCategoryPS = conn
				.prepareStatement("INSERT INTO Categories (name, description) VALUES (?, ?)");
		if (insertCategoryPS != null) {
			for (int i = 0; i < CATEGORIES.length; i++) {
				insertCategoryPS.setString(1, CATEGORIES[i]);
				insertCategoryPS.setString(2, CATEGORIES[i] + " description");
				insertCategoryPS.executeUpdate();
			}
			insertCategoryPS.close();
		}
	}

	private static Object[] createProductsTable(Connection conn)
			throws SQLException {
		final int NUM_PRODUCTS = 10000;
		final int MAX_PRICE = 100000; // 1000 dollars
		/*
		PreparedStatement createProductsPS = conn
				.prepareStatement("CREATE TABLE Products (sku SERIAL PRIMARY KEY, name VARCHAR(200) NOT NULL UNIQUE, cat_id INT NOT NULL REFERENCES Categories (id), price INT NOT NULL);");
		if (createProductsPS != null) {
			createProductsPS.execute();
			createProductsPS.close();
		}
		 */
		
		Set<Product> ps = new HashSet();
		while (ps.size() < NUM_PRODUCTS) {
			int catId = (int) (Math.random() * CATEGORIES.length);
			String cat = CATEGORIES[catId];
			String adj = ADJECTIVES[(int) (Math.random() * ADJECTIVES.length)];
			String color = COLORS[(int) (Math.random() * COLORS.length)];
			String name = adj + " " + color + " " + cat;
			int price = (int) (Math.random() * MAX_PRICE);

			// +1 bc db will index from 1
			Product p = new Product(name, catId + 1, price);

			int suffix = 1;
			while (ps.contains(p)) {
				p.name = p.name + " " + Integer.toString(suffix++);
			}

			ps.add(p);
		}

		Object[] pArray = ps.toArray();

		PreparedStatement insertProductPS = conn
				.prepareStatement("INSERT INTO Products (name, cat_id, price) VALUES (?, ?, ?);");
		if (insertProductPS != null) {
			for (int i = 0; i < pArray.length; i++) {
				Product p = (Product) pArray[i];
				insertProductPS.setString(1, p.name);
				insertProductPS.setInt(2, p.catId);
				insertProductPS.setInt(3, p.price);
				insertProductPS.executeUpdate();
			}
			insertProductPS.close();
		}

		return pArray;
	}

	private static void createCustomersTable(Connection conn,
			Vector<String> firstNames, Vector<String> lastNames, int N)
			throws SQLException {
		/*
		PreparedStatement createCustomersPS = conn
				.prepareStatement("CREATE TABLE Customers (id SERIAL PRIMARY KEY, name TEXT NOT NULL, age INT NOT NULL, state CHARACTER(2) NOT NULL);");
		if (createCustomersPS != null) {
			createCustomersPS.execute();
			createCustomersPS.close();
		}
		 */
		

		int totalCustomers = M * N;
		final int MAX_AGE = 120;
		Set<Customer> customers = new HashSet<Customer>();

		while (customers.size() < totalCustomers) {
			// create a customer
			String fname = firstNames.get((int) (Math.random() * firstNames
					.size()));
			String mname = lastNames.get((int) (Math.random() * lastNames
					.size()));
			String lname = lastNames.get((int) (Math.random() * lastNames
					.size()));
			String name = fname + " " + mname + " " + lname;
			String st = STATES[(int) (Math.random() * STATES.length)];
			int age = (int) (Math.random() * MAX_AGE);

			Customer c = new Customer(name, st, age);
			int suffix = 1;
			while (customers.contains(c)) {
				c.name = c.name + " " + Integer.toString(suffix++);// change
																	// name to
																	// have a
																	// unique
																	// number
			}

			customers.add(c);
		}

		Iterator<Customer> iter = customers.iterator();
		PreparedStatement insertCustomerPS = conn
				.prepareStatement("INSERT INTO Customers (name, age, state) VALUES (?, ?, ?)");
		if (insertCustomerPS != null) {
			while (iter.hasNext()) {
				Customer c = iter.next();
				insertCustomerPS.setString(1, c.name);
				insertCustomerPS.setInt(2, c.age);
				insertCustomerPS.setString(3, c.state);
				insertCustomerPS.executeUpdate();
			}
			insertCustomerPS.close();
		}
	}

	// needs productsLength, needs customersLength
	private static void createSalesTable(Connection conn, Object[] pArr, int N) throws SQLException {
		final int MAX_QUANT = 10;
		final int NUM_MONTHS = 12;
		final int NUM_SALES = N * M * 100;
		final int NUM_PRODUCTS_PER_CUSTOMER = 20;
		final int NUM_SALES_PER_PRODUCT_PER_CUSTOMER = 5;

		/*
		PreparedStatement createSalesPS = conn
				.prepareStatement("CREATE TABLE Sales (id SERIAL PRIMARY KEY, product_id INT NOT NULL REFERENCES Products (sku) , customer_id INT NOT NULL REFERENCES Customers (id) , day INT NOT NULL, month INT NOT NULL, quantity INT NOT NULL, total_cost INT NOT NULL);");
		if (createSalesPS != null) {
			createSalesPS.execute();
			createSalesPS.close();
		}
		*/
		


		int numQueries = 0;
		PreparedStatement insertSalePS = conn
				.prepareStatement("INSERT INTO Sales (product_id, customer_id, day, month, quantity, total_cost) VALUES (?, ?, ?, ?, ?, ?)");
		if (insertSalePS != null) {
			for (int curCustomer = 1; curCustomer <= N * M; curCustomer++) {
				for (int i = 0; i < NUM_PRODUCTS_PER_CUSTOMER; i++) {
					int pId = (int) (Math.random() * pArr.length);
					Product product = (Product) pArr[pId];

					for (int j = 0; j < NUM_SALES_PER_PRODUCT_PER_CUSTOMER; j++) {
						int month = (int) (Math.random() * NUM_MONTHS) + 1;
						int day = (int) (Math.random() * getDaysInMonth(month)) + 1;
						int quantity = (int) (Math.random() * MAX_QUANT) + 1;

						int totalPrice = product.price * quantity;

						insertSalePS.setInt(1, pId + 1);
						insertSalePS.setInt(2, curCustomer);
						insertSalePS.setInt(3, day);
						insertSalePS.setInt(4, month);
						insertSalePS.setInt(5, quantity);
						insertSalePS.setInt(6, totalPrice);

						insertSalePS.executeUpdate();

                        if(numQueries % 1000 == 0) conn.commit();
						numQueries++;
					}
				}
			}
			insertSalePS.close();
		}
		assert (numQueries == NUM_SALES);
	}
	
	
	private static void createTables(Connection conn,
			Vector<String> firstNames, Vector<String> lastNames, int N)
			throws SQLException {
		
		PreparedStatement createCustomersPS = conn
				.prepareStatement("CREATE TABLE Customers (id SERIAL PRIMARY KEY, name TEXT NOT NULL, age INT NOT NULL, state CHARACTER(2) NOT NULL, INDEX(age), INDEX(state));");
		if (createCustomersPS != null) {
			createCustomersPS.execute();
			createCustomersPS.close();
		}
		
		PreparedStatement createCategoriesPS = conn
				.prepareStatement("CREATE TABLE Categories (id SERIAL PRIMARY KEY, name TEXT NOT NULL, description TEXT);");
		if (createCategoriesPS != null) {
			createCategoriesPS.execute();
			createCategoriesPS.close();
		}
		
		PreparedStatement createProductsPS = conn
				.prepareStatement("CREATE TABLE Products (sku SERIAL PRIMARY KEY, name VARCHAR(200) NOT NULL UNIQUE, cat_id INT NOT NULL REFERENCES Categories (id), price INT NOT NULL, INDEX(cat_id));");
		if (createProductsPS != null) {
			createProductsPS.execute();
			createProductsPS.close();
		}
		
		PreparedStatement createcartPS = conn
				.prepareStatement("CREATE TABLE cart (id SERIAL PRIMARY KEY, user text NOT NULL, product INT NOT NULL REFERENCES Products(sku), amount int not null);");
		if (createcartPS != null) {
			createcartPS.execute();
			createcartPS.close();
		}
		
		PreparedStatement createSalesPS = conn
				.prepareStatement("CREATE TABLE Sales (id SERIAL PRIMARY KEY, product_id INT NOT NULL REFERENCES Products (sku), customer_id INT NOT NULL REFERENCES Customers (id), day INT NOT NULL, month INT NOT NULL, quantity INT NOT NULL, total_cost INT NOT NULL, INDEX(customer_id), INDEX(product_id));");
		if (createSalesPS != null) {
			createSalesPS.execute();
			createSalesPS.close();
		}
			
		PreparedStatement createProductSumPS = conn
				.prepareStatement("create table Product_Sum(product_id int not null references Products(sku), quarter enum(\"fall\",\"winter\",\"spring\",\"summer\") not null,  order_count int default 0, total_cost int default 0, INDEX(product_id));");
		if (createProductSumPS != null) {
			createProductSumPS.execute();
			createProductSumPS.close();
		}
		
		PreparedStatement createCustomerSumPS = conn
				.prepareStatement("create table Customer_Sum(customer_id int not null references Customers(id) , quarter enum(\"fall\",\"winter\",\"spring\",\"summer\") not null,  order_count int default 0, total_cost int default 0, INDEX(customer_id));");
		if (createCustomerSumPS != null) {
			createCustomerSumPS.execute();
			createCustomerSumPS.close();
		}
		
		
		
		
		/* TRIGGERS */ 
		
		PreparedStatement createNewCustomerTriggerPS = conn
				.prepareStatement("create trigger new_customer after insert on Customers "
									+ "for each row "
									+ "begin "
									+ "Insert into Customer_Sum values (NEW.id, \"fall\", 0, 0); "
									+ "Insert into Customer_Sum values (NEW.id, \"winter\", 0, 0); "
									+ "Insert into Customer_Sum values (NEW.id, \"spring\", 0, 0); "
									+ "Insert into Customer_Sum values (NEW.id, \"summer\", 0, 0); "
									+ "end;");
		if (createNewCustomerTriggerPS != null) {
			createNewCustomerTriggerPS.execute();
			createNewCustomerTriggerPS.close();
		}
					
		PreparedStatement createNewProductTriggerPS = conn
				.prepareStatement("create trigger new_product after insert on Products "
						+ "for each row "
						+ "begin "
						+ "Insert into Product_Sum values (NEW.sku, \"fall\", 0, 0); "
						+ "Insert into Product_Sum values (NEW.sku, \"winter\", 0, 0); "
						+ "Insert into Product_Sum values (NEW.sku, \"spring\", 0, 0); "
						+ "Insert into Product_Sum values (NEW.sku, \"summer\", 0, 0); "
						+ "end;");
		if (createNewProductTriggerPS != null) {
			createNewProductTriggerPS.execute();
			createNewProductTriggerPS.close();
		}
			
		
		
		PreparedStatement createNewSaleTriggerPS = conn
				.prepareStatement("create trigger new_sale after insert on Sales "
						+ "for each row "
						+ "begin "
						+ "IF (NEW.month >= 9 and NEW.month <=11) THEN"
						+ "		UPDATE Product_Sum SET Product_Sum.total_cost = Product_Sum.total_cost + NEW.total_cost, Product_Sum.order_count=Product_Sum.order_count + 1 "
						+ 		"where Product_Sum.product_id= NEW.product_id and quarter=\"fall\"; "
						+ "		UPDATE Customer_Sum SET Customer_Sum.total_cost = Customer_Sum.total_cost + NEW.total_cost, Customer_Sum.order_count=Customer_Sum.order_count + 1 "
						+ 		"where Customer_Sum.customer_id = NEW.customer_id and quarter=\"fall\"; "
						+ "ELSEIF (NEW.month = 12 or NEW.month <=2) THEN"
						+ "		UPDATE Product_Sum SET Product_Sum.total_cost = Product_Sum.total_cost + NEW.total_cost, Product_Sum.order_count=Product_Sum.order_count + 1 "
						+ 		"where Product_Sum.product_id= NEW.product_id and quarter=\"winter\"; "
						+ "		UPDATE Customer_Sum SET Customer_Sum.total_cost = Customer_Sum.total_cost + NEW.total_cost, Customer_Sum.order_count=Customer_Sum.order_count + 1 "
						+ 		"where Customer_Sum.customer_id = NEW.customer_id and quarter=\"winter\"; "
						+ "ELSEIF (NEW.month >= 3 and NEW.month <=5) THEN"
						+ "		UPDATE Product_Sum SET Product_Sum.total_cost = Product_Sum.total_cost + NEW.total_cost, Product_Sum.order_count=Product_Sum.order_count + 1 "
						+ 		"where Product_Sum.product_id= NEW.product_id and quarter=\"spring\"; "
						+ "		UPDATE Customer_Sum SET Customer_Sum.total_cost = Customer_Sum.total_cost + NEW.total_cost, Customer_Sum.order_count=Customer_Sum.order_count + 1 "
						+ 		"where Customer_Sum.customer_id = NEW.customer_id and quarter=\"spring\"; "
						+ "ELSEIF (NEW.month >= 6 and NEW.month <=8) THEN"
						+ "		UPDATE Product_Sum SET Product_Sum.total_cost = Product_Sum.total_cost + NEW.total_cost, Product_Sum.order_count=Product_Sum.order_count + 1 "
						+ 		"where Product_Sum.product_id= NEW.product_id and quarter=\"summer\"; "
						+ "		UPDATE Customer_Sum SET Customer_Sum.total_cost = Customer_Sum.total_cost + NEW.total_cost, Customer_Sum.order_count=Customer_Sum.order_count + 1 "
						+ 		"where Customer_Sum.customer_id = NEW.customer_id and quarter=\"summer\"; "
						+ "END IF; "
						+ "end;");
		if (createNewSaleTriggerPS != null) {
			createNewSaleTriggerPS.execute();
			createNewSaleTriggerPS.close();
		}
		
	
	}

	// Math.random() * 5
	/*
	 * a customer table with N * 1M tuples with uniform and independent
	 * distribution over age groups and states 50 product categories a product
	 * table with 10K products a sales table with N * 100M columns (Product,
	 * Customer, Date, Quantity), with dates uniformly distributed over last
	 * year, quantity uniformly distributed over 1-10. Each customer purchases
	 * only 20 randomly selected products and makes 5*20 purchases during the
	 * year (5*20 = 100M / 1M)
	 */
	public static void main(String[] args) {
		Vector<String> firstNames = new Vector<String>();
		Vector<String> lastNames = new Vector<String>();
		String outDir = new String("");

		getNames("C:\\Users\\Nick\\Code\\DataGenerator\\FirstNames.txt", firstNames);
		getNames("C:\\Users\\Nick\\Code\\DataGenerator\\LastNames.txt", lastNames);

		int n = -1;
        int m = -1;
		String server = null;
		int port = -1;
		String dbName = null;
		String username = null;
		String password = null;

		System.out.println("size of CATEGORIES: " + CATEGORIES.length);
		System.out.println("size of ADJECTIVES: " + ADJECTIVES.length);
		System.out.println("size of COLORS:" + COLORS.length);
		System.out.println("size of firstNames:" + firstNames.size());
		System.out.println("size of lastNames:" + lastNames.size());

		Scanner reader = new Scanner(System.in);
		while (n < 0) {
			System.out.println("Please specify an N value, where #Customers = N * M and #Sales = N * M * 100:");
			try {
				n = Integer.parseInt(reader.nextLine().trim());
			} catch (Exception e) {
				System.out.println("Try again.");
			}
		}
		System.out.println("n was chosen to be: " + n);

		while (m < 0) {
			System.out.println("Please specify an M value, where #Customers = N * M and #Sales = N * M * 100:");
			try {
				m = Integer.parseInt(reader.nextLine().trim());
			} catch (Exception e) {
				System.out.println("Try again.");
			}
		}
		System.out.println("m was chosen to be: " + m);
		
		System.out.println("Please specify a server [localhost]:");
		String serverString = reader.nextLine().trim();
		if(serverString.length() == 0) 
			server = "nacolias.com";
		else
			server = serverString;
		
		System.out.println("Please specify a port [5432]:");
		String portString = reader.nextLine().trim();
		if(portString.length() == 0) 
		{
			port = 3306;
		}
		else
		{
			try
			{
				port = Integer.parseInt(portString);
			}
			catch(NumberFormatException e)
			{
				port = 3306;
			}
		}
		
		System.out.println("Please specify a database name [cse135]:");
		String dbNameString = reader.nextLine().trim();
		if(dbNameString.length() == 0) 
			dbName = "cse135_test";
		else
			dbName = dbNameString;
		
		System.out.println("Please specify a user name [postgres]:");
		String userNameString = reader.nextLine().trim();
		if(userNameString.length() == 0) 
			username = "admin135";
		else
			username = userNameString;
		
		System.out.println("Please specify a password [postgres]:");
		String passwordString = reader.nextLine().trim();
		if(passwordString.length() == 0) 
			password = "admin135";
		else
			password = userNameString;
		
		String connString = "jdbc:mysql://" + server + ":" + Integer.toString(port) + "/" + dbName;
		
		System.out.println("connection string: " + connString);
		System.out.println("username: " + username);
		System.out.println("password: " + password);
		
		Connection conn = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(connString, username, password);

            conn.setAutoCommit(false);
            DataGenerator.setM(m);
            createTables(conn, firstNames, lastNames, n);
			createCustomersTable(conn, firstNames, lastNames, n);
            conn.commit();
			createCategoriesTable(conn);
            conn.commit();
			Object[] ps = null;
			ps = createProductsTable(conn);
			assert (ps != null);

            conn.commit();
			createSalesTable(conn, ps, n);

            conn.commit();

			System.out.println("Success...?");
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Failed.");
		}
	}
}
