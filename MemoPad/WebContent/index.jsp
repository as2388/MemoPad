<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<style>
		.pUIMemo
		{
			font-family: Arial;
			font-size: 15px;
			padding: 8px;
			word-wrap:break-word;
		}
		.divUIMemo
		{
			background-color: lightblue;
			
		}
		.divUIDeleteMemo
		{
			/*position:fixed;
			right:0px;
			display:inline-block;*/
		}
	</style>

	<script lang="javascript" src="./js"></script> <!-- RESTEasy -->
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> <!-- jquery -->
	<script>
		function UIMemo(id, value, time)
		{
			this.id=id;
			this.value=value;
			this.time=time;
		}
		UIMemo.prototype.generateHTML = function()
		{
			return "<div onclick='memoClicked(this.id)' id='" + this.id + "' class='divUIMemo'> <div class='pUIMemo'>" + this.value + "</div>  </div><p/>";
		};
		
		var UIMemos = [];
	
		function memoClicked(id)
		{ //TODO: change the behaviour to show options. But for now, deletes the memo item
			//ask the server to delete this item
			MemoService.deleteMemo({user: "testuser", memoID: id})
			
			//TODO: remove this (changes should happen locally)
			getMemos();
		}
		
		
		function addMemo() 
		{ //adds a memo to the database if the entered string is valid
			if (!($('#txtInput').val() == "New Memo...")) //  && !($("#txtInput").attr("value")))
			{		
				//tell the servlet to add the memo
				//MemoService.addMemo({user: "testuser", value: document.getElementById("txtInput").value});
				
				var xhr = new XMLHttpRequest();
				xhr.open("POST", "http://localhost:8080/MemoPad/memo/addMemo?user=testuser&value=" + document.getElementById("txtInput").value, false);
				xhr.send();
				console.log(xhr.status);
				
				if (xhr.status != 200)
				{ //we had some sort of error so report this to user. 
					
				}
				
				//clear the input
				$("#txtInput").val("");
				$("#txtInput").focus();
				
				scrollToBottom();
			}
			
			//TODO: delete this when memos are added locally
			getMemos();
		}
		function scrollToBottom()
		{ //animate auto scroll to bottom of page
			$('html, body').animate({ 
				   scrollTop: $(document).height()-$(window).height()+46}, 
				   500, 
				   "swing"
				);
		}		
		function getMemos()
		{ //gets the user's memos from the servlet and displays the values on screen
			//get the memos from the server in JSON format
			var servletresponse = MemoService.getMemos({user: "testuser"});
		
			//parse the JSON
			var parsedresponse = JSON.parse(servletresponse);
			
			//create the UIMemo objects from the parsed JSON
			UIMemos=[];
			for (var i = 0; i < parsedresponse.length; i++)
			{
				UIMemos[UIMemos.length] = new UIMemo(parsedresponse[i]._id.$oid, parsedresponse[i].Value, parsedresponse[i].TimeMS);
			}
			
			//sort the UIMemo objects by Date/Time added
			UIMemos.sort(function(a,b)
					{
						return a.time - b.time;
					});
			
			//get each UIMemo to generate its HTML, and put this on the page
			$("#memoDiv").html("");
			for (var i = 0; i < UIMemos.length; i++)
			{
				$("#memoDiv").append(UIMemos[i].generateHTML());
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
	<div  style="opacity:0.95; position:fixed; top:0; left:0; width:100%; background-color:white;"><h2 style="font-family:Arial; padding-left:5px;">Memos</h2></div>
	
	<div style="height:70px"></div> <!-- create space below title bar -->
	<div id="memoDiv"></div> <!-- on screen space for the memo objects -->
	
	<div style="position:fixed; width:100%; height:30px; opacity:0.95; background-color:white; padding:5px; bottom:0px; ">	
		<input  style="color: silver;" type="text" id="txtInput" value="New Memo..." onfocus="clearTxtInputDefault()" onblur="txtInputBlurred()" onkeypress="txtInputKeyPress(event)"/>
		<button style="width:50px; margin-left:0.14cm" type="button" onclick="addMemo()">Add</button>
	</div>
	
	<div style="height:30px"></div> <!-- create space above New Memo Bar -->
	
	
	<div id="output"></div>
	
	
</body>
</html> 






