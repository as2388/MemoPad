package as2388.MemoPad;

import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

@Path("/memo")
public class MemoService 
{
	@POST
	public Response spitBack(@QueryParam("d") String data)
	{
		return Response.ok().entity(data).build();
	}
}
