<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<script lang="javascript" src="./js"></script> <!-- RESTEasy -->
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> <!-- jquery -->
	<script>		
		function addMemo() 
		{ //adds a memo to the database if the entered string is valid
			if (!($('#txtInput').val() == "New Memo...")) //  && !($("#txtInput").attr("value")))
			{		
				//tell the servlet to add the memo
				MemoService.addMemo({user: "testuser", value: document.getElementById("txtInput").value});	//register the new memo with the server
				
				//clear the input
				$("#txtInput").val("");
				$("#txtInput").focus();
				
				scrollToBottom();
			}
			
			//TODO: delete this when memos are added locally
			getMemos();
		}
		function scrollToBottom()
		{ //animate scroll to bottom of page
			$('html, body').animate({ 
				   scrollTop: $(document).height()-$(window).height()+30}, 
				   500, 
				   "swing"
				);
		}		
		function getMemos()
		{ //gets the user's memos from the servlet and displays the values on screen
			var servletresponse = MemoService.getMemos({user: "testuser"});
			var parsedresponse = JSON.parse(servletresponse);
			$("#memoDiv").html("");
			for (var i = 0; i < parsedresponse.length; i++)
			{
				$("#memoDiv").append("<p>" + parsedresponse[i].Value + "</p>");
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
		{ //try to add memo to database when enter key pressed
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
		function clearTxtInputDefault()
		{ //clear "New Memo..." message
			if ($("#txtInput").attr("value") == "New Memo...")
			{
				$("#txtInput").css("color","black");
				$("#txtInput").val("");
			}
		}
		function pageLoad()
		{
			getMemos();
			resize();
			scrollToBottom();
		}
		window.onresize=function()
		{ 
			resize();
		};
		function resize()
		{ //resize the button and input to fit screen
			$("#txtInput").css("width", $(window).width()-100);
		}
	</script>
</head>

<body onload="pageLoad()">
	<div  style="opacity:0.95; position:fixed; top:0; left:0; width:100%; background-color:paleturquoise;"><h2 style="font-family:Arial; padding-left:5px;">Memos</h2></div>
	
	<div style="height:70px"></div> <!-- create space below title bar -->
	<div id="memoDiv"></div> <!-- on screen space for the memo objects -->
	
	<div style="position:fixed; width:100%; height:30px; opacity:0.95; background-color:white; padding:5px; bottom:0px; ">	
		<input  style="color: silver;" type="text" id="txtInput" value="New Memo..." onfocus="clearTxtInputDefault()" onblur="txtInputBlurred()" onkeypress="txtInputKeyPress(event)"/>
		<button style="width:50px; margin-left:0.1cm" type="button" onclick="addMemo()">Add</button>
	</div>
	
	<div style="height:30px"></div> <!-- create space above New Memo Bar -->
	
	
	<div id="output"></div>
	
	
</body>
</html> 






