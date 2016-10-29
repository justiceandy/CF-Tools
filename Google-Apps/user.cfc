<cfcomponent hint="handles functions that request google user information">

<!--- Component Handles Fetching User Profile Information using OAuth Token [Simple Request]--->


<!--- Get User Profile --->
<cffunction access="public" name="getProfile" returntype="any" returnformat="json">
	<cfargument name="accesstoken"  required="yes" type="any">

	<cfhttp url="https://www.googleapis.com/oauth2/v1/userinfo" method="get" resolveurl="yes" result="httpResult">
		<cfhttpparam type="header" name="Authorization" value="OAuth #arguments.accesstoken#">
		<cfhttpparam type="header" name="GData-Version" value="3">
	</cfhttp>

	<cfreturn DeserializeJSON(httpResult.filecontent.toString())>
</cffunction>


</cfcomponent>
