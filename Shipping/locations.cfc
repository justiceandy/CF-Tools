<cfcomponent>


	 <!--- Get Closest Shipping Point --->
    <cffunction name="getClosestProductShippingPoint" access="remote" hint="Returns closest product shipping point to destination" returnFormat="plain" >
		<cfargument name="partID" type="numeric" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.destination = arguments.destination>
		<cfset result.shippingPoints = arrayNew(1)>

		<!--- Get Products Shipping Points --->
		<cfinvoke component="locations" method="getModelShippingLocations" returnVariable="shippingLocations">
			<cfinvokeargument name="partID" value="#arguments.partID#">
			<cfinvokeargument name="returnType" value="struct">
		</cfinvoke>

		<cfif arrayLen(shippingLocations.locations)>
			<cfset result.status = true>
			<cfset result.statusCode = 200>
		</cfif>

		<cfif result.status>
			<cfset locations = arrayNew(1)>
			<cfloop from="1" to="#arrayLen(shippingLocations.locations)#" index="i">
				<cfset string = "#shippingLocations.locations[i].address1# #shippingLocations.locations[i].address2# #shippingLocations.locations[i].city# #shippingLocations.locations[i].state# #shippingLocations.locations[i].zip#">
				<cfset arrayAppend(locations, string)>
			</cfloop>

			<cfset destinations = arrayNew(1)>
			<cfset destinations[1] = arguments.destination>

			<!--- Send Address & Destination to Google Maps Distance API --->
			<cfinvoke component="cfc.google.maps" method="getDistance" returnVariable="distanceResult">
				<cfinvokeargument name="origins" value="#locations#">
				<cfinvokeargument name="destinations" value="#destinations#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>

			<cfset result.shortOrder = "">

			<!--- Create Sorted ---->
			<cfloop from="1" to="#arrayLen(locations)#" index="i">
				<cfset result.shippingPoints[i] = structNew()>
				<cfif !structKeyExists(variables, "lowest")>
					<cfset lowest = distanceResult.distances[i].elements[1].distance.value>
					<cfset result.shortOrder = listprepend(result.shortOrder, i - 1)>
				<cfelseif lowest GTE distanceResult.distances[i].elements[1].distance.value>
					<cfset result.shortOrder = listprepend(result.shortOrder, i - 1)>
				<cfelseif lowest LTE distanceResult.distances[i].elements[1].distance.value>
					<cfset lowest = distanceResult.distances[i].elements[1].distance.value>
					<cfset result.shortOrder = listAppend(result.shortOrder, i - 1)>
				</cfif>

				<cfset result.shippingPoints[i].distanceText = distanceResult.distances[i].elements[1].distance.text>
				<cfset result.shippingPoints[i].distance = distanceResult.distances[i].elements[1].distance.value>
				<cfset result.shippingPoints[i].durationText = distanceResult.distances[i].elements[1].duration.text>
				<cfset result.shippingPoints[i].duration = distanceResult.distances[i].elements[1].duration.value>
				<cfset result.shippingPoints[i].fullAddress = locations[i]>
				<cfset result.shippingPoints[i].ID = shippingLocations.locations[i].locationID>
				<cfset result.shippingPoints[i].name = shippingLocations.locations[i].name>
				<cfset result.shippingPoints[i].address1 = shippingLocations.locations[i].address1>
				<cfset result.shippingPoints[i].address2 = shippingLocations.locations[i].address2>
				<cfset result.shippingPoints[i].city = shippingLocations.locations[i].city>
				<cfset result.shippingPoints[i].state = shippingLocations.locations[i].state>
				<cfset result.shippingPoints[i].zip = shippingLocations.locations[i].zip>
				<cfset result.shippingPoints[i].streetImage = shippingLocations.locations[i].streetImage>
			</cfloop>
		</cfif>

		<cfif arguments.returnType EQ "Json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>



</cfcomponent>
