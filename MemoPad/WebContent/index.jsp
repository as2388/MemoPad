<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<script lang="javascript" src="./js"></script>
	<script>
		function printInput() 
		{
			var message = MemoService.spitBack({d: document.getElementById("txtInput").value});
    		document.getElementById("output").innerHTML = message;
		}
	</script>
</head>

<body>
	<p>Enter Text:</p>
	<input type="text" id="txtInput"/>
	<button type="button" onclick="printInput()">Try it</button>
	<p id="output" />
</body>
</html> 