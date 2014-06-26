package as2388.MemoPad;

import static org.junit.Assert.*;

import java.net.UnknownHostException;
import java.util.List;

import org.junit.Ignore;
import org.junit.Test;

import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;

public class MemoServiceTest
{

	@Test
	public void testAddMemo() throws UnknownHostException 
	{
		MemoService tester = new MemoService();
		
		//reset the '_testuser' collection
		tester.db.getCollection("_testuser").remove(new BasicDBObject());

		//add an item with value '_testvalue' to '_testuser''s collection
		int rstatus=tester.addMemo("_testuser", "_testvalue").getStatus();
		
		//test that the return status is correct
		assertEquals("Response status should be 200",200,rstatus); 
		
		//test that only one item has been added to '_testuser''s collection
		DBCursor myCursor = tester.db.getCollection("_testuser").find();
		List<DBObject> docArr = myCursor.toArray();
		assertEquals("Only one item should be in the user's collection", 1, docArr.size());
		
		//test to see if adding the new memo added the correct value into the Value field
		assertEquals("'_testvalue' should be in '_testuser''s collection", "_testvalue", docArr.get(0).get("Value")); 
	}
}
