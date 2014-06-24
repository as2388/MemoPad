package as2388.MemoPad;

import java.net.UnknownHostException;
import java.util.Date;

import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;

@Path("/memo")
public class MemoService 
{
	DB db; //database containing the memos
	
	@POST
	@Path("/addMemo")
	public void addMemo(@QueryParam("user") String user, @QueryParam("value") String value)
	{
		//TODO: Add the memo to the user's database collection
		
		//get the user's collection from the database
		DBCollection userMemos = db.getCollection(user);
		
		//prepare the new memo for insertion
		BasicDBObject newMemo = new BasicDBObject();
		newMemo.put("DateTime", new Date());
		newMemo.put("Value", value);
		newMemo.put("Priority", 2); //use 0: very low, 2: medium (default for now), 4: very high		
		
		//insert the new memo into the user's collection
		userMemos.insert(newMemo);
	}
	
	@POST
	@Path("/getMemos")
	public Response getMemos(@QueryParam("user") String user)
	{
		//get the user's collection from the database
		DBCollection userMemos = db.getCollection(user);
			
		DBObject memo = userMemos.findOne();s
		
		return Response.ok().entity(memo.toString()).build();
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
