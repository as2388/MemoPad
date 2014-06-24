<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<script lang="javascript" src="./js"></script>
	<script>
		function addMemo() 
		{
			MemoService.addMemo({memo: document.getElementById("txtInput").value});	//register the new memo with the server
			//clear the input
			document.getElementById("txtInput").value = "";
			document.getElementById("txtInput").focus();
		}
		function clearTxtInputDefault()
		{	//clear "New Memo..." message
			if (document.getElementById("txtInput").value == "New Memo...")
			{
				document.getElementById("txtInput").style.color = "black";
				document.getElementById("txtInput").value = "";
			}
		}
		function txtInputBlurred()
		{
			if (document.getElementById("txtInput").value == "")
			{
				setTxtInputDefault();	
			}
		}
		function txtInputKeyPress(e)
		{
			if (e.keyCode == 13)
			{
				addMemo();
			}
		}
		function setTxtInputDefault()
		{
			document.getElementById("txtInput").style.color = "silver";
			document.getElementById("txtInput").value = "New Memo...";
		}
	</script>
</head>

<body>
	<p>Memos</p>
	<input style="color: silver" type="text" id="txtInput" value="New Memo..." onfocus="clearTxtInputDefault()" onblur="txtInputBlurred()" onkeypress="txtInputKeyPress(event)"/>
	<button type="button" onclick="addMemo()">Add</button>
	<p id="output" />
</body>
</html> 