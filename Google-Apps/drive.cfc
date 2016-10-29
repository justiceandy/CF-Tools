<cfcomponent>


	
	<!--- Get Drive File --->
	<cffunction name="getDriveFile" access="remote" hint="Gets Root Drive Info">
		<cfargument name="fileName" default="" type="string">
		<cfhttp url="https://www.googleapis.com/drive/v2/files/#arguments.fileName#" method="get" resolveurl="yes" result="httpResult"> 
			<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.refreshToken#"> 
			<cfhttpparam type="header" name="GData-Version" value="3"> 
		</cfhttp> 
		<cfset response = DeserializeJSON(httpResult.filecontent.toString())>
		<!--- If invalid credentials --->
		<cfif response.error.message EQ "invalid credentials">
			<cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
				<cfinvokeargument name="userRefreshToken" value="#session.googleToken.refreshToken#">
			</cfinvoke>
			<cfhttp url="https://www.googleapis.com/drive/v2/files/root/" method="get" resolveurl="yes" result="httpResult"> 
				<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.access_token#"> 
				<cfhttpparam type="header" name="GData-Version" value="3"> 
			</cfhttp> 
			<cfset response = DeserializeJSON(httpResult.filecontent.toString())>
		</cfif>
		<cfreturn response> 
	</cffunction>

	
	
	<!--- Get Users Root Drive --->
	<cffunction name="getDriveRoot" access="remote" hint="Gets Drive Root Folders" >
		<Cfargument name="refresh" type="string" default="true">
		
		<cfif !structKeyExists(session.googleToken, "driveRoot")>
			<Cfset arguments.refresh = "true">
		</cfif>
		<!--- If we are refreshing Contents --->
		<cfif arguments.refresh EQ "true">
			
		<!--- Structs to Hold Specific Files --->
		<cfset session.googleToken.driveRoot = structNew()>	
		
		<cfhttp url="https://www.googleapis.com/drive/v2/files/root/children/" method="get" resolveurl="yes" result="httpResult"> 
			<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.access_token#"> 
			<cfhttpparam type="header" name="GData-Version" value="3"> 
		</cfhttp> 
		
		<cfset rootResponse = DeserializeJSON(httpResult.filecontent.toString())>
		
		<!--- If invalid credentials --->
		<cfif structKeyExists(rootResponse, "error") and structKeyExists(rootResponse.error, "message") and rootResponse.error.message EQ "invalid credentials">
			<cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
				<cfinvokeargument name="userRefreshToken" value="#session.googleToken.refreshToken#">
			</cfinvoke>
			<cfhttp url="https://www.googleapis.com/drive/v2/files/root/children/" method="get" resolveurl="yes" result="httpResult"> 
				<cfhttpparam type="header" name="Authorization" value="Bearer #session.googleToken.access_token#"> 
				<cfhttpparam type="header" name="GData-Version" value="3"> 
			</cfhttp> 
			<cfset rootResponse = DeserializeJSON(httpResult.filecontent.toString())>
		</cfif>
		
		<!--- Root items are Child References Objects for Folders in the Drive API --->
		<cfset returnStruct.rootItems = rootResponse.items>
		
		<!--- Loop Each Item --->
		<cfloop from="1" to="#arrayLen(returnStruct.rootItems)#" index="i">
		
			<!--- Get Info About Item --->
		
			<cfhttp url="#returnStruct.rootItems[i].childLink#?key=#application.googleApi.publicApiKey#" method="get" resolveurl="yes" result="rootItemResult"> 
					<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.access_token#"> 
					<cfhttpparam type="header" name="GData-Version" value="3"> 
			</cfhttp> 
				
				
				<cfset rootItemResultParsed = DeserializeJSON(rootItemResult.filecontent.toString())>
				
				<cfif structKeyExists(rootItemResultParsed, "title")>
				<cfset session.googleToken.driveRoot["#rootItemResultParsed.title#"] = structCopy(rootItemResultParsed) />
				
				<!--- Convert Modified Date --->
				<cfinvoke component="cfc.internal.dates" method="ISOToDateTime" returnvariable="cfConvertedDate">
					<cfinvokeargument name="date" value="#rootItemResultParsed.modifiedDate#">
				</cfinvoke> 
				
				<cfset session.googleToken.driveRoot[rootItemResultParsed.title].modifiedDate = cfConvertedDate>
				</cfif>
		<!--- If Mime Type IS Folder, List --->
		</cfloop>
		</cfif>
		
	
		
	</cffunction>


	<!--- Get Info About Users Drive, Capacity, Current Use Etc --->
	<cffunction name="getDriveInfo" access="remote" hint="Gets Info About Users Drive">
		<cfhttp url="https://www.googleapis.com/drive/v2/about" method="get" resolveurl="yes" result="httpResult"> 
			<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.refreshToken#"> 
			<cfhttpparam type="header" name="GData-Version" value="3"> 
		</cfhttp> 
		<cfset response = DeserializeJSON(httpResult.filecontent.toString())>
		<!--- If invalid credentials --->
		<cfif response.error.message EQ "invalid credentials">
			<cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
				<cfinvokeargument name="userRefreshToken" value="#session.googleToken.refreshToken#">
			</cfinvoke>
			<cfhttp url="https://www.googleapis.com/drive/v2/about" method="get" resolveurl="yes" result="httpResult"> 
				<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.refreshToken#"> 
				<cfhttpparam type="header" name="GData-Version" value="3"> 
			</cfhttp> 
			<cfset response = DeserializeJSON(httpResult.filecontent.toString())>
		</cfif>
		<cfreturn response> 
	</cffunction>

	
	<!--- Get Users Shared With Me Folder --->

	



</cfcomponent>