package as2388.MemoPad;

import java.net.UnknownHostException;
import java.util.Date;
import java.util.List;
import java.util.Random;

import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import org.bson.types.ObjectId;

import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;

@Path("/memo")
public class MemoService 
{
	DB db; //database containing the memos
	int latencyMS = 4000;
	private void delay()
	{
		if (latencyMS!=0)
		{
			try {
				Thread.sleep(latencyMS);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	
	@POST
	@Path("/addMemo")
	public Response addMemo(@QueryParam("user") String user, @QueryParam("value") String value)
	{ // Adds the memo to the user's database collection
		
		//one in 3 chance of failure
		Random randomizer = new Random();
		if (randomizer.nextInt(3) == 0)
		{
			return Response.status(500).build();
		}		
		else{
		//get the user's collection from the database
		DBCollection userMemos = db.getCollection(user);
		
		//simulate high latency
		delay();
		
		//prepare the new memo for insertion
		BasicDBObject newMemo = new BasicDBObject();
		newMemo.put("TimeMS", new Date().getTime());
		newMemo.put("Value", value);
		newMemo.put("Priority", 2); //use 0: very low, 2: medium (default for now), 4: very high		
		
		//insert the new memo into the user's collection
		userMemos.insert(newMemo);
		
		return Response.status(200).build();}
	}
	
	@POST
	@Path("/getMemos")
	public Response getMemos(@QueryParam("user") String user)
	{ //returns all the items in the user's collection in JSON format
		//get the user's collection from the database
		DBCollection userMemos = db.getCollection(user);
			
		//create a list containing all the documents in the user's collection
		DBCursor myCursor = userMemos.find();
		List<DBObject> docArr = myCursor.toArray();
			
		//return this list in JSON format
		return Response.ok().entity(docArr.toString()).build();
	}
	
	@POST
	@Path("/deleteMemo")
	public Response deleteMemo(@QueryParam("user") String user, @QueryParam("memoID") String memoID)
	{ //delete's the memo of the specified id from the specified user's collection
		delay();
		
		//get the user's collection from the database
		DBCollection userMemos = db.getCollection(user);
	
		try
		{
		//delete the item from the user's collection
		DBObject toDelete = new BasicDBObject("_id", new ObjectId(memoID));
		userMemos.remove(toDelete);
		
		return Response.status(200).build();
		}
		catch(java.lang.IllegalArgumentException e)
		{
			return Response.status(404).build();
		}
	}
	
	//Initialise database
	public MemoService() throws UnknownHostException
	{
		//Create mongo client
		MongoClient mongoInstance = new MongoClient("localhost", 27017);
		
		//Access/create database
		db = mongoInstance.getDB("Memos");
	}
}
