<cfcomponent>
	<!---
		Google Maps CFC that Calculates Distance between points using Google Distance Matrix Json API
	--->

	<cfset application.googleDistanceMatrix = structNew()>
	<cfset application.googleDistanceMatrix.URL = "https://maps.googleapis.com/maps/api/distancematrix/json?">


	<!--- Get Distance --->
	<cffunction name="getDistance" access="remote" returnFormat="plain" hint="gets distance between points with google distance matrix">
		<cfargument name="origins" type="array" default="#arrayNew(1)#">
		<cfargument name="destinations" type="array" default="#arrayNew(1)#">
		<cfargument name="returnType" default="json" type="string">

		<cfset result = structNew()>
		<cfset result.origin = structNew()>
		<cfset result.destination = structNew()>

		<cfset originsFull = "origins=">
		<cfset originCount = 0>
		<cfset destinationsFull = "destinations=">
		<cfset destinationCount = 0>

		<!--- Loop origins and create full string --->
		<cfloop from="1" to="#arrayLen(origins)#" index="i">
			<cfset originCount++>
			<cfset fixedAddress = replace(origins[i], " ", "+", "all")>
			<cfset fixedAddress = replace(fixedAddress, "&", "")>
			<cfif originCount EQ 1>
				<cfset originsFull = "#originsFull##fixedAddress#">
			<cfelse>
				<cfset originsFull = "#originsFull#|#fixedAddress#">
			</cfif>
			<cfset result.origin[originCount] = structNew()>
			<cfset result.origin[originCount].Address = fixedAddress>
			<cfset result.origin[originCount].index = originCount>
		</cfloop>

		<!--- Loop Destinations and create full string --->
		<cfloop from="1" to="#arrayLen(destinations)#" index="i">
			<cfset destinationCount++>
			<cfset fixedAddress = replace(destinations[i], " ", "+", "all")>
			<cfset fixedAddress = replace(fixedAddress, "&", "")>
			<cfif destinationCount EQ 1>
				<cfset destinationsFull = "#destinationsFull##fixedAddress#">
			<cfelse>
				<cfset destinationsFull = "#destinationsFull#|#fixedAddress#">
			</cfif>
			<cfset result.destination[destinationCount] = structNew()>
			<cfset result.destination[destinationCount].Address = fixedAddress>
			<cfset result.destination[destinationCount].index = destinationCount>
		</cfloop>

		<cfset result.urlToGet = "#application.googleDIstanceMatrix.URL##originsFull#&#destinationsFull#">

		<!--- Hit Distance Matrix API --->
		<cfhttp method="post" url="#result.urlToGet#" result="distanceResult">
			<cfhttpparam type="formfield" name="mode" value="driving" >
		</cfhttp>

		<!--- Return Distance --->
		<cfset result.distances = #deserializeJson(distanceREsult.fileContent)#>
		<cfset result.distances = result.distances.rows>

		<cfif arguments.returnType EQ "json">
		<cfreturn serializeJson(result)>
		<cfelse>
		<cfreturn result>
		</cfif>
	</cffunction>

</cfcomponent>
