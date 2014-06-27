<%@ page language="java" contentType="text/html; charset=ISO-8859-1"  pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<style>
		.pUIMemo
		{
			font-family: Arial;
			font-size: 15px;
			padding: 8px;
			/*display: block;*/
			word-wrap:break-word;
		}
		.divUIMemo
		{
			
			padding-top: 8px;
			padding-bottom: 8px;
			
		}
		.divUIDeleteMemo
		{
			/*position:fixed;*/
			right:15px;
			font-family: Arial;
			color: white;
			padding: 8px;
			margin: -8px;
			
			background-color: coral;
		}
	</style>

	<script lang="javascript" src="./js"></script> <!-- RESTEasy -->
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> <!-- jquery -->
	<script>
		var username = "";	//stores the name of the current user
		var users = [];		//list of users on the 
		var colors = ['lightgreen', 'pink', 'lightsalmon', 'yellow','lightcoral'];
		function User(name,color)
		{
			this.name=name;
			this.color=color;
		}
	
		var localIDPointer;
		function UIMemo(id, value, time, owner)
		{
			this.id=id;
			this.value=value;
			this.time=time;
			this.owner=owner;
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
				return "<div onclick='memoClicked(this.id)' id='" + this.id + "' class='divUIMemo' style='background-color:" + users[this.owner].color +"'> <label class='pUIMemo'>" + this.value + "</label> <!--<label class='divUIDeleteMemo'>X</label>-->  </div><p/>";
			}
		};
		function generateguid() 
		{
		    function _p8(s) {
		        var p = (Math.random().toString(16)+"000000000").substr(2,8);
		        return s ? "-" + p.substr(0,4) + "-" + p.substr(4,4) : p ;
		    }
		    return _p8() + _p8(true) + _p8(true) + _p8();
		}
		
		var UIMemos = [];
	
		function memoClicked(id)
		{ //TODO: change the behaviour to show options. But for now, deletes the memo item
			deleteMemo(id, null);
		}
		
		var opCount=0;		
		function addMemo()
		{
			if (!($('#txtInput').val() == "New Memo..." || $('#txtInput').val().trim() == ""))
			{
				//create locally
				var guid=generateguid();
				if (UIMemos.length == 0)
				{
					UIMemos[0]=new UIMemo(guid,$('#txtInput').val(), new Date().getTime(), 0);
				}
				else
				{
					UIMemos[UIMemos.length]=new UIMemo(guid,$('#txtInput').val(), UIMemos[UIMemos.length-1].time + 1, 0);
				}
				
				//add to screen with fade in animation
				$("#memoDiv").append(UIMemos[UIMemos.length-1].generateHTML());
				$("#" + guid).css("opacity","0");
				$("#" + guid).fadeTo(400 , 1, function() {});
				scrollToBottom();
				
				opCount++;
				
				//try to add to the database
				addToServer($('#txtInput').val(), guid);
				
				//clear the input
				$("#txtInput").val("");
				$("#txtInput").focus();
			}
		}
		
		function addToServer(value, guid)
		{
			playSyncAnim();
			
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "http://localhost:8080/MemoPad/memo/addMemo?user=" + username + "&value=" + value + "&guid=" + guid, true);
			xhr.addEventListener('load', function()
					{
						if (xhr.status!=200)
						{ //we have an error. try again
							setTimeout(function(){addToServer(value, guid);},100);		
						}
						else
						{ //add was successful
							opCount--;
							tryStopSyncAnim();
						}
					}, false);
			
			xhr.send();	
		}
		
		function deleteMemo(id)
		{ //delete the memo of specified id
			//find the associated UIMemo object
			var thisUIMemo=new UIMemo(null,null,null,null);
			for (var i=0; i<UIMemos.length; i++)
			{
				if (UIMemos[i].id==id)
				{
					thisUIMemo = UIMemos[i];
				}
			}
			
			//Memos are read-only to other users, so only delete the memo if it's owned by the current user
			if (thisUIMemo.owner==0)
			{ 
				//delete locally
				console.log("here");
				playSyncAnim();
				
				thisUIMemo.deleted = true;
				displayMemos();
					
				//try to delete from server
				tryDelete(thisUIMemo.id);
				opCount++;				
			}
		}
		
		function tryDelete(guid)
		{
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "http://localhost:8080/MemoPad/memo/deleteMemo?user=" + username + "&memoID=" + guid, true);
			
			xhr.addEventListener('load', function()
					{
						if (xhr.status!=200)
						{ //something else went wrong. Try again
							setTimeout(function(){tryDelete(guid);},100);
						}
						else
						{ //delete was successful
							opCount--;
							tryStopSyncAnim();
						}
					}, false);
			
			xhr.send();
		}
		
		var syncStage=0;
		var syncAnim;
		var synching=false;
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
			if (synching)
			{
				return 'Not all changes have been synchronised with the server. If you continue, some changes will be lost';
			}
		};
		function playSyncAnim()
		{
			if (!synching)
			{
				syncStage=0;
				syncAnim = setInterval(function(){syncAnimate();},500);
				synching=true;
			}
		}
		function tryStopSyncAnim()
		{
			if (opCount == 0 && !getSynching)
			{
				clearInterval(syncAnim);
				synching=false;
				$('#synclabel').text('');
				//getMemos(); //ok to poll for update now
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
			
			//UIMemos=[];
			//get memos for each user
			newUIMemos = [];
			//console.log("call");
			for (var k=0; k < users.length; k++)
			{			
				asyncGetCount++;
				tryGetMemos(k);
			}	
		}
		
		var asyncGetCount=0; //the number of asynchronousy running tryGetMemos() threads
		var newUIMemos = [];
		var getSynching=false;
		function tryGetMemos(k)
		{
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "http://localhost:8080/MemoPad/memo/getMemos?user=" + users[k].name, true);
			
			xhr.addEventListener('load', function()
					{
						if (xhr.status!=200)
						{ //something else went wrong. Try again
							setTimeout(function(){tryGetMemos(user);},100);
						}
						else
						{ //success!
							asyncGetCount--;
								
							//parse the newly received memos and add these to the list of new memos
							//get the memos from the server in JSON format
							//console.log(xhr.response);
							var servletresponse = xhr.response;
							//parse the JSON
							var parsedresponse = JSON.parse(servletresponse);
							//create the UIMemo objects from the parsed JSON
							for (var i = 0; i < parsedresponse.length; i++)
							{
								newUIMemos[newUIMemos.length] = new UIMemo(parsedresponse[i].Guid, parsedresponse[i].Value, parsedresponse[i].TimeMS, k);
							}
							
							//console.log(UIMemos.length);
							//console.log(newUIMemos.length);
							
							//if the asnycCetCount is zero, then update the display
							if (asyncGetCount == 0)
							{
								
								UIMemos = newUIMemos;
								
								//sort the UIMemo objects by Date/Time added
								UIMemos.sort(function(a,b)
										{
											return a.time - b.time;
										});
																
								displayMemos();
								
								getSynching = false;
								tryStopSyncAnim();
							}
						}
					}, false);
			
			xhr.send();
		}
		
		function poll()
		{
			if (!synching && asyncGetCount == 0)
			{
				getMemos();
			}
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
			resize();
			
			//set up polling to run every 10s
			setInterval(poll, 10000);
			
			scrollToBottom();
        }
		window.onresize=function()
		{ 
			resize();
		};
		function resize()
		{ //resize the button and input to fit screen
			$("#txtInput").css("width", $(window).width()-100);
			$("#users").css("width", $(window).width()-100);	
			$("#topspace").css("height", 15 + parseInt($("#titlebar").css("height")));
			
			var size='1.5em';
				
			if (parseInt($(window).width()) < 640)
			{
				//console.log(parseInt($(window).width()));
				size="1.2em";
				if ($(window).width() < 320)
				{
					size="1em";
				}
			}
				
			$("#titlebar").css("font-size", size);
		}
		
		function signIn()
		{
			//hide sign in
			$('#user').css("display","none");
			//show main page, transition with fade
			$('#main').css("display","inline");
			$( "#main" ).fadeTo( "fast" , 1, function() {});
			
			//set up users
			username = $('#username').val();
			users[0]=new User(username, "lightblue");
			$('#title').html("<b>Memos</b> for");
			
			for (var i=0; i<users.length; i++)
			{
				if(i!=0)
				{
					$('#title').append(",");
				}
				
				$('#title').append("<font color='" + users[i].color + "'> " + users[i].name + "</font>");
			}
			
			resize();
			
			getSynching = true;
			playSyncAnim();
			getMemos();
		}
		
		function editUsers()
		{
			//display the current list of users in the users input
			for (var i = 1; i < users.length; i++)
			{
				$("#users").append(", " + users[i].name);
			}
						
			$( "#users" ).fadeTo("fast" , 1, function() {});	
			$( "#cmdEditUsers" ).fadeTo("fast" , 0, function() {});
			$( "#cmdDoneEditUsers" ).fadeTo("fast" , 1, function() {});
			$( "#users" ).focus();
			
		}
		function doneEditUsers()
		{
			//build up the desired list of users from the input field
			var usernames = $('#users').val().split(",");
			users=[];
			users[0]=new User("Alexander", "lightblue");
			for (var i=0; i<usernames.length; i++)
			{
				if (usernames[i].trim() != "")
				{
					users[i+1]=new User(usernames[i].trim(), colors[i % colors.length]);
				}
			}
			signIn();
			getMemos();
			
			$( "#users" ).fadeTo("fast" , 0, function() {});	
			$( "#cmdEditUsers" ).fadeTo("fast" , 1, function() {});
			$( "#cmdDoneEditUsers" ).fadeTo("fast" , 0, function() {});
		}
	</script>
</head>

<body onload="pageLoad()">
	<div id="user">	
		<input id="username" value="Alexander"></input>
		<button onclick="signIn()">Go</button>
	</div>
	
	<div id="main" style="display: none; opacity:0;">
		<div id="titlebar" style="padding-top:10px; padding-left:5px; padding-bottom:10px; font-size:1.5em; opacity:0.9; position:fixed; top:0; left:0; width:100%; background-color:white;">
			<label  id='title' style="margin-before:0.83em; margin-after:0.83em; font-weight:normal; margin-start:0; margin-end:0; font-family:Arial; padding-left:5px;"></label> 
			<button id="cmdEditUsers" onclick="editUsers()" style="margin-right:10px; float:right;">Edit</button>
			<input  id="users"  style="margin-left:5px; opacity:0;"></input>
			<button id="cmdDoneEditUsers" style="opacity:0; width:50px; margin-left:0.14cm" type="button" onclick="doneEditUsers()">Done</button>
		</div>
	
		<div id="topspace" style="height:0px"></div> <!-- create space below title bar -->
		<div id="memoDiv"></div> <!-- on screen space for the memo objects -->
	
		<div style="position:fixed; width:100%; height:30px; opacity:0.95; background-color:white; padding:5px; bottom:0px; ">	
			<input  style="color: silver;" type="text" id="txtInput" value="New Memo..." onfocus="clearTxtInputDefault()" onblur="txtInputBlurred()" onkeypress="txtInputKeyPress(event)"/>
			<button style="width:50px; margin-left:0.14cm" type="button" onclick="addMemo()">Add</button>
			<label  style="font-family:Arial;" id="synclabel"></label>
		</div>
	
		<div style="height:30px"></div> <!-- create space above New Memo Bar -->
	</div>
	
</body>
</html> 



