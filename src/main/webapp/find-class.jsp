<%@ page import="java.util.*" %>
<%@ page import="java.util.jar.*" %>
<%@ page import="java.util.zip.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.security.*" %>
<%
	// Given a className string, search in web server classpath for jar that
	// contains it, and prints its MANIFEST.MF file if found.
	HashMap<String, String> result = new LinkedHashMap<>();
	try {
		String className = request.getParameter("className");
		if (className == null || className.equals("")) {
			className = "javax.servlet.Servlet";
		}
		result.put("className: ", className.toString());

		Class<?> cls = this.getClass().getClassLoader().loadClass(className);
		result.put("class", cls.toString());

		CodeSource codeSource = cls.getProtectionDomain().getCodeSource();
		URL loc = codeSource.getLocation();
		if (loc == null) {
			result.put("classLocation", "Not Found.");
		} else {
			result.put("classLocation:", loc.toString());
		}

		if (loc != null) {
			JarFile jar = new JarFile(loc.getFile());
			ZipEntry entry = jar.getEntry("META-INF/MANIFEST.MF");
			if (entry != null) {
				StringBuilder sb = new StringBuilder();
				InputStream inStream = jar.getInputStream(entry);
				BufferedReader reader =
					new BufferedReader(new InputStreamReader(inStream));
				String line = null;
				while ((line = reader.readLine()) != null) {
					sb.append(line + "\n");
				}
				result.put("META-INF/MANIFEST.MF", sb.toString());
			}
			jar.close();
		}
	} catch (Exception e) {
		result.put("ERROR: ", e.toString());
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
		<h1 class="title">ClassFinder</h1>
		<p class="subtitle">Use 'className' parameter search for jar location.</p>
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
