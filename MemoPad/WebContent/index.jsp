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
		var localIDvalue=0;
		var localIDPointer;
		function UIMemo(id, value, time)
		{
			this.id=id;
			this.value=value;
			this.time=time;
			this.deleted=false;
		}
		UIMemo.prototype.generateHTML = function()
		{
			if (this.deleted)
			{
				return "";	
			}
			else
			{
				return "<div onclick='memoClicked(this.id)' id='" + this.id + "' class='divUIMemo'> <div class='pUIMemo'>" + this.value + "</div>  </div><p/>";
			}
		};
		
		var UIMemos = [];
	
		function memoClicked(id)
		{ //TODO: change the behaviour to show options. But for now, deletes the memo item
			//ask the server to delete this item
			//MemoService.deleteMemo({user: "testuser", memoID: id});
			deleteMemo(id, null);
			
			//TODO: remove this (changes should happen locally)
			//getMemos();
		}
		
		var addqueue = [];		
		function addMemo()
		{
			if (!($('#txtInput').val() == "New Memo...")) //  && !($("#txtInput").attr("value")))
			{
				//create locally
				if (UIMemos.length == 0)
				{
					UIMemos[0]=new UIMemo(0,$('#txtInput').val(), new Date().getTime());
				}
				
				UIMemos[UIMemos.length]=new UIMemo(localIDvalue,$('#txtInput').val(), UIMemos[UIMemos.length-1].time + 1);
				localIDvalue+=1;
				
				//add to screen
				$("#memoDiv").append(UIMemos[UIMemos.length-1].generateHTML());
				scrollToBottom();
				
				//if the async server push routine is not running, start it.				
				addqueue.push(UIMemos[UIMemos.length-1]);
				if (addqueue.length == 1)
				{
					pushToServer();
				}
				
				//clear the input
				$("#txtInput").val("");
				$("#txtInput").focus();
			}
		}
		function pushToServer()
		{
			playSyncAnim();
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "http://localhost:8080/MemoPad/memo/addMemo?user=testuser&value=" + addqueue[0].value, true);
			
			xhr.addEventListener('load', function()
					{
						console.log(xhr.response);
						if (xhr.status == 200)
						{ //success! Remove item from queue and try next item, if exists
							addqueue.shift();
							
							UIMemos[localIDPointer].id=xhr.response;
							localIDPointer+=1;
							displayMemos();
							if (addqueue.length > 0)
							{
								pushToServer();
							}
							else
							{
								tryStopSyncAnim();
							}
						}
						else
						{ //we have an error. Alert user and try again
							//console.log("add memo error"); //TODO: create a UI alert
							
							//try again in 100ms. This prevents the client becoming unresponsive if the server is unavailable
							setTimeout(function(){pushToServer();},100);
							//pushToServer();
						}
						//getMemos();
					}, false);
			
			xhr.send();
		}
		
		var deleteCount=0;
		function deleteMemo(id, latestPointer) //call by setting latestPointer to null
		{ //delete the memo of specified id
			//if the memo is in the queue to be sent to the server (ie it only exists locally) just delete it
			for (var j=1; j<addqueue.length; j++)
			{
				if (addqueue[j].id == id)
				{
					//delete from addqueue
					addqueue.splice(j,1);
					return;
				}
			}
			
			//if we hit this line the item is not in addqueue, or is at position 0 of addqueue
			//Assume not in addqueue for now TODO: don't assume this!
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "http://localhost:8080/MemoPad/memo/deleteMemo?user=testuser&memoID=" + id, true);
			
			if (latestPointer==null)
			{
				if (addqueue.length > 0)
				{
					if (addqueue[0].id == id)
					{
						latestPointer=localIDPointer;
					}
				}
			}
			
			for (var i=0; i<UIMemos.length; i++)
			{
				if (UIMemos[i].id==id)
				{
					UIMemos[i].deleted=true;
				}
			}
			displayMemos();
			
			xhr.addEventListener('load', function()
					{
						//console.log(xhr.status);
						if (xhr.status!=200)
						{ //we have an error. Check for more info:
							if (xhr.status==404)
							{ //requested item not in database;
								//TODO: if add request in progress try again else treat as code 200
								console.log('error 404!');
								
								if (latestPointer!=null)
								{ //try again: we need to delete an item which is in the process of being added to the database
									setTimeout(function(){deleteMemo(UIMemos[latestPointer].id, latestPointer);},100);
								}
								else
								{ //no action required?
									deleteCount--;
									tryStopSyncAnim();
								}
							}
							else
							{ //something else went wrong. Try again
								setTimeout(function(){deleteMemo(id, null);},100);
							}
						}
						else
						{ //delete was successful
							deleteCount--;
							tryStopSyncAnim();
						}
					}, false);
				
			deleteCount++;
			playSyncAnim();
			xhr.send();
		}
		
		var syncStage=0;
		var syncAnim;
		var syncAnimating=false;
		function syncAnimate()
		{
			syncStage++;
			switch(syncStage)
			{
				case 1:
					$('#synclabel').text('.');
					break;
				case 2:
					$('#synclabel').text('..');
					break;
				case 3:
					$('#synclabel').text('...');
					break;
				case 4:
					$('#synclabel').text('');
					break;
			}
			
			if (syncStage >= 3)
			{
				syncStage=0;
			}
		}
		window.onbeforeunload = function(e)
		{ //if synchronisation is incomplete ask the user if they really want to cllose the page
			if (syncAnimating)
			{
				return 'Not all changes have been synchronised with the server. If you continue, some changes will be lost';
			}
		};
		function playSyncAnim()
		{
			if (!syncAnimating)
			{
				syncStage=0;
				syncAnim = setInterval(function(){syncAnimate();},500);
				syncAnimating=true;
			}
		}
		function tryStopSyncAnim()
		{
			if (addqueue.length == 0 /*&& TODO: not deleting*/)
			{
				clearInterval(syncAnim);
				syncAnimating=false;
				$('#synclabel').text('');
			}
		}
		
		function scrollToBottom()
		{ //animate auto scroll to bottom of page
			$('html, body').stop();
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
			
			//TODO:comment
			localIDPointer=UIMemos.length;
			
			
			displayMemos();
			
			scrollToBottom();
		}
		
		function displayMemos()
		{
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
	<div style="opacity:0.9; position:fixed; top:0; left:0; width:100%; background-color:white;"><h2 style="font-family:Arial; padding-left:5px;">Memos</h2></div>
	
	
	<div style="height:70px"></div> <!-- create space below title bar -->
	<div id="memoDiv"></div> <!-- on screen space for the memo objects -->
	
	<div style="position:fixed; width:100%; height:30px; opacity:0.95; background-color:white; padding:5px; bottom:0px; ">	
		<input  style="color: silver;" type="text" id="txtInput" value="New Memo..." onfocus="clearTxtInputDefault()" onblur="txtInputBlurred()" onkeypress="txtInputKeyPress(event)"/>
		<button style="width:50px; margin-left:0.14cm" type="button" onclick="addMemo()">Add</button>
		<label  style="font-family:Arial;" id="synclabel"></label>
	</div>
	
	<div style="height:30px"></div> <!-- create space above New Memo Bar -->
	
	
	<div id="output"></div>
	
	
</body>
</html> 