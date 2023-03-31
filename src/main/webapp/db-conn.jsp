<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	// Test Database Connectivity
	//
	// WARN: You would need to add your database JDBC driver jar into the WebServer
	// in order to test this JSP page!
	//
	// If you want to use this project maven to download the JDBC, you may use the profile
	// setup for it. For example, to get MySQL, run: mvn package -Pmysql
	//
	// Or for Oracle, run: mvn package -Poracle
	//
	// NOTE: If you use IntelliJ and use exploded mode deployment on Tomcat, then it will work
	// inside IDE after the command above.
	//
	// NOTE: To test Oracle use:
	//   ?driverClass=oracle.jdbc.driver.OracleDriver&url=jdbc:oracle:thin:@mydbserver:1521:mydb&props=user:scott;password:tiger&sql=SELECT CURRENT_TIMESTAMP FROM DUAL;
	//
	HashMap<String, String> result = new LinkedHashMap<>();
	Properties props = new Properties();
	props.setProperty("user", "root");
	props.setProperty("password", "");

	String driverClass = request.getParameter("driverClass");
	if (driverClass == null || "".equals(driverClass)) {
		driverClass = "com.mysql.cj.jdbc.Driver";
	}

	String url = request.getParameter("url");
	if (url == null || "".equals(url)) {
		url = "jdbc:mysql://localhost:3306/mysql?serverTimezone=America/New_York";
	}

	String sql = request.getParameter("sql");
	if (sql == null || "".equals(sql)) {
		sql = "SELECT 1 + 1";
	}

	result.put("driverClass", driverClass);
	result.put("url", url);
	result.put("sql", sql);

	String propsStr = request.getParameter("props");
	if (!(propsStr == null || "".equals(propsStr))) {
		String[] pairs = propsStr.split(";");
		for (int i = 0; i < pairs.length; i++) {
			String[] items = pairs[i].split(":");
			if (items.length >= 2) {
				props.put(items[0], items[1]);
				if (!"password".equals(items[0])) {
					result.put("props." + items[0], items[1]);
				}
			}
		}
	}

	try {
		Class.forName(driverClass).getDeclaredConstructor().newInstance();
		Connection conn = DriverManager.getConnection(url, props);
		Statement stmt = conn.createStatement();
		boolean stmtResult = stmt.execute(sql);
		result.put("stmtResult", "" + stmtResult);
		ResultSet rs = stmt.getResultSet();
		int colCount = rs.getMetaData().getColumnCount();
		while (rs.next()) {
			for (int i = 0; i < colCount; i++) {
				Object rsResult = rs.getObject(i + 1);
				result.put("rsResult", "" + rsResult);
			}
		}
		rs.close();
		stmt.close();
		conn.close();
	} catch (Exception e) {
		throw new RuntimeException("Failed to connect to DB: url=" +
				url + ", user=" + props.get("user"), e);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<title>ClassFinder</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://unpkg.com/bulma@0.9.4/css/bulma.min.css">
    <script src="https://unpkg.com/vue@3.2.47/dist/vue.global.prod.js"></script>	
</head>
<body>
<div class="section">
	<div class="container">
		<h1 class="title">JDBC Database Connection Test</h1>
		<p class="subtitle">Use 'sql', 'url' or 'props, 'driverClass' query parameters.</p>
	<%
	for (Map.Entry<String, String> entry : result.entrySet()) {
		String key = entry.getKey();
		String value = entry.getValue();
		out.println("<p class='is-size-5'>" + key + "</p>");
		out.println("<pre>" + value + "</pre>");
	}
	%>
	</div>
</div>
</body>
</html>
