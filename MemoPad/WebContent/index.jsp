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
			padding-right: 50px;
			word-wrap:break-word;
		}
		.divUIMemo
		{
			
			padding-top: 8px;
			padding-bottom: 8px;
			margin: 0px;
		}
		.divUIDeleteMemo
		{
			opacity:0;
			
			/*position:fixed;*/
		
			padding-left:15px;
			padding-right:15px;
			
			margin: -8px;
			margin-right:0px;
				
			font-family: Arial;
			color: white;
			float: right;
			
			background-color: coral;
		}
	</style>

	<script lang="javascript" src="./js"></script> <!-- RESTEasy -->
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> <!-- jquery -->
	<script>
		var username = "";	//stores the name of the current user
		var users = [];		//list of users whose stats are to be viewed
		var colors = ['lightgreen', 'pink', 'lightsalmon', 'yellow','lightcoral']; //used to assign a color to addititonal users
		function User(name,color)
		{ //maintain basic user details
			this.name=name;
			this.color=color;
		}
	
		var localIDPointer;
		function UIMemo(id, value, time, owner, checked)
		{
			this.id=id;
			this.value=value;
			this.time=time;
			this.owner=owner;
	 		this.checked=checked;
	 		console.log("init with " + checked);
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
				/*var output = "<div style='";
				if (this.checked)
				{
					output += "opacity:0.5; ";
				}
				output += "background-color:" + users[this.owner].color +"' onclick='memoClicked(this.id)' id='" + this.id + "' onmousedown='memoMouseDown(this.id)' id='" + this.id + "' onmouseup='memoMouseUp(this.id)' id='" + this.id + "' class='divUIMemo'> <table><tr> <label class='pUIMemo' id=p'" + this.id + "'>" + this.value + "</label></tr><tr> <label id='delete" + this.id + "' class='divUIDeleteMemo'>X</label> </tr> </table>  <!--<label class='divUIDeleteMemo'>X</label>-->  </div><p/>";
				return output;*/
				return "<div onclick='memoClicked(this.id)' id='" + this.id + "'onmousedown='memoMouseDown(this.id)' onmouseup='memoMouseUp(this.id)' class='divUIMemo' style='background-color:" + users[this.owner].color +"'> <label class='pUIMemo'>" + this.value + "</label> <!--<label class='divUIDeleteMemo'>X</label>-->  </div><p/>";
			}
		};
		UIMemo.prototype.showMemoChecked = function()
		{ 
			console.log("prototype checked" + this.checked);
			if (this.checked == "true")
			{
				console.log("set true");
				$("#" + this.id).css("opacity","0.5");
			}
			else
			{
				console.log("set false");
				$("#" + this.id).css("opacity","1");
			}
			console.log($("#" + this.id).css("opacity"));
		};
		UIMemo.prototype.changeChecked = function(checked)
		{ //update memo checked status and animate transition to the new status
			//update status
			this.checked=Boolean(checked);
			console.log("this.checked was changed to " + checked);
		
			//animate transititon
			if (checked)
			{ //fade out
				console.log("fade out");
				$("#" + this.id).fadeTo("fast" , 0.5, function() {});
			}
			else
			{ //not checked, so fade in
				console.log('fade in');
				$("#" + this.id).fadeTo("fast" , 0.9, function() {});
			}
		};		
		var UIMemos = [];	//stores an array of UIMemo objects as defined above
		
		function generateguid() 
		{
		    function _p8(s) {
		        var p = (Math.random().toString(16) + "000000000").substr(2,8);
		        return s ? "-" + p.substr(0,4) + "-" + p.substr(4,4) : p ;
		    }
		    return _p8() + _p8(true) + _p8(true) + _p8();
		}
	
		function memoClicked(id)
		{ //Invert the checked status of the object			
			//find the UIMemo object associated with the id
			var thisUIMemo=new UIMemo(null,null,null,null,null);
			for (var i=0; i<UIMemos.length; i++)
			{
				if (UIMemos[i].id==id)
				{
					thisUIMemo = UIMemos[i];
				}
			}
			
			//Invert checked status
			//console.log("reqest will be " + !thisUIMemo.checked);
			if (thisUIMemo.checked=="false")
			{
				changeChecked(id, thisUIMemo.owner, true);
			}
			else
			{
				changeChecked(id, thisUIMemo.owner, !thisUIMemo.checked);
			}
			
		}
		
		var deleteTimerFun;
		function memoMouseDown(id)
		{
			deleteTimerFun = setTimeout(function(){deleteMemo(id);},500);		
		}
		function memoMouseUp(id)
		{
			clearTimeout(deleteTimerFun);		
		}
		
		var opCount=0;		
		function addMemo()
		{ //create a memo locally and try to add to server
			if (!($('#txtInput').val() == "New Memo..." || $('#txtInput').val().trim() == ""))
			{
				//create locally
				var guid=generateguid();
				if (UIMemos.length == 0)
				{
					UIMemos[0]=new UIMemo(guid,$('#txtInput').val(), new Date().getTime(), 0, false);
				}
				else
				{
					UIMemos[UIMemos.length]=new UIMemo(guid,$('#txtInput').val(), UIMemos[UIMemos.length-1].time + 1, 0, false);
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
		{ //try to add a memo to the server
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
			var thisUIMemo=new UIMemo(null,null,null,null, null);
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
				animateDeleteMemo(thisUIMemo.id);
				//displayMemos();
					
				//try to delete from server
				tryDelete(thisUIMemo.id);
				opCount++;				
			}
		}
		function tryDelete(guid)
		{ //try to delete the memo on the server
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
		
		function changeChecked(id, user, checked)
		{
			console.log("request will be " + checked);
			
			//find the associated UIMemo object
			var thisUIMemo=new UIMemo(null,null,null,null, null);
			for (var i=0; i<UIMemos.length; i++)
			{
				if (UIMemos[i].id==id)
				{
					thisUIMemo = UIMemos[i];
				}
			}
			
			//update its checked status locally
			thisUIMemo.changeChecked(checked);
			
			//syrchronise the checked change with the server
			opCount++;
			playSyncAnim();
			tryChangeChecked(id, user, checked);
			
		}
		function tryChangeChecked(id, user, checked)
		{ //try to update the memo's new checked status with the server
			var xhr = new XMLHttpRequest();
			xhr.open("POST", "http://localhost:8080/MemoPad/memo/setChecked?user=" + users[user].name + "&memoID=" + id + "&checked=" + checked, true);
			
			xhr.addEventListener('load', function()
					{
						console.log("request was " + xhr.response);
						//setInterval(getMemos(), 500);
						if (xhr.status == 200)
						{ //status change was ok, report no longer synchronising the change
							opCount--;
							tryStopSyncAnim();
						}
						else
						{ //something went wrong so try again
							setTimeout(function(){tryChangeChecked(id, user, checked);},100);
						}
					}, false);
			
			xhr.send();
		}
		
		var syncStage=0;
		var syncAnim;
		var synching=false;
		function syncAnimate()
		{ //advance the "synching" indicator animation
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
		{ //if synchronisation is incomplete ask the user if they really want to close/reload/navigate from the page
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
			//console.log("get request");
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
								newUIMemos[newUIMemos.length] = new UIMemo(parsedresponse[i].Guid, parsedresponse[i].Value, parsedresponse[i].TimeMS, k, parsedresponse[i].Checked);
								console.log("response was " + parsedresponse[i].Checked);
							}
							
							//if the asnycCetCount is zero, then update the display
							if (asyncGetCount == 0)
							{						
								var oldUIMemos = UIMemos;
								UIMemos = newUIMemos;
								
								//sort the UIMemo objects by Date/Time added
								UIMemos.sort(function(a,b)
										{
											return a.time - b.time;
										});
																
								displayMemos();
								
								
								
								//animate in new memos
								for (var i=0; i<UIMemos.length; i++)
								{
									var found=false;
									for (var j=0; j<oldUIMemos.length; j++)
									{
										if (UIMemos[i].id == oldUIMemos[j].id)
										{
											found=true;
										}
									}
									if (!found)
									{
										$("#" + UIMemos[i].id).css("opacity","0");
										if (UIMemos[i].checked == "true")
										{
											console.log("get fade out");
											$("#" + UIMemos[i].id).fadeTo(400 , 0.5, function() {});
										}
										else
										{
											console.log("get fade in");
											$("#" + UIMemos[i].id).fadeTo(400 , 1, function() {});
										}
									}
								}
								
								//animate out deleted memos
								for (var i=0; i<oldUIMemos.length; i++)
								{
									var found=false;
									for (var j=0; j<UIMemos.length; j++)
									{
										if (oldUIMemos[i].id == UIMemos[j].id)
										{
											found=true;
										}
									}
									if (!found)
									{
										//animateDeleteMemo(oldUIMemos[i].id);
										
									}
								}
								
								//console.log("UIMemos status is " + UIMemos[0].checked);
								
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
		
		function animateDeleteMemo(id)
		{
			//$("#" + UIMemos[i].id).fadeTo(400 , 0, function() {});
			
			$("#" + id).animate({
				opacity: 0,
				height: '0px',
				margin: '-8px',
				padding: '0px'
			}, 400);
			
			setTimeout(displayMemos, 400);
		}
		
		function displayMemos()
		{
			//get each UIMemo to generate its HTML, and put this on the page
			$("#memoDiv").html("");
			for (var i = 0; i < UIMemos.length; i++)
			{
				$("#memoDiv").append(UIMemos[i].generateHTML());
				console.log("HTML Render");
				UIMemos[i].showMemoChecked();
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
			//getMemos();
			
			$( "#users" ).fadeTo("fast" , 0, function() {});	
			$( "#cmdEditUsers" ).fadeTo("fast" , 1, function() {});
			$( "#cmdDoneEditUsers" ).fadeTo("fast" , 0, function() {});
		}
	</script>
</head>

<body onload="pageLoad()">
	<div id="user" style="margin:auto; width:300px; margin-top:120px;">	 
		<div style="font-weight:normal; font-family:Arial; font-size:1.8em; padding:5px; margin-left:75px;"><b>Memo</b>Pad</div>
		<label  style="font-family:Arial; margin-left:30px;">Username:</label>
		<input id="username" value=""></input>
		<button onclick="signIn()">Go</button>
	</div>
	
	<span id="main" style="display: none; opacity:0;">
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
	</span>
	
</body>
</html> 



