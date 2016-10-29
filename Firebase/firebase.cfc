<!--- CFC for interacting with Firebase.io
  Very Simple Proof of concept
 --->

<cffunction name="init" access="remote" returnFormat="plain">
  <cfset application.firebase = structNew()>
  <cfset application.firebase.dataURL =  "https://YOUR-FIREBASE-DB.firebaseio.com/">
  <cfset application.firebase.authKey = "YOUR-FIREBASE-AUTHKEY">
</cffunction>

<!--- push Data --->
<cffunction name="pushData" access="remote" returnFormat="plain">
  <cfargument name="url" type="string" required="true">
  <cfargument name="returnType" type="string" default="json">
  <cfargument name="data" type="struct" required="true">
  <cfargument name="id" type="numeric" default="0">

    <cfset data = serializeJson(arguments.data)>
    <cfif structKeyExists(arguments, "id")>
      <cfset arguments.url = "#arguments.url#/#arguments.id#.json">
      <cfset arguments.method = "put">
    <cfelse>
      <cfset arguments.url = "#arguments.url#.json">
      <cfset arguments.method = "post">
    </cfif>

    <cfhttp method="#arguments.method#" url="#arguments.URL#" result="firebaseResponse">
      <cfhttpparam type="body" value="#arguments.data#">
    </cfhttp>

    <cfreturn firebaseResponse>
</cffunction>


<!--- Get Data --->
<cffunction name="getData" access="remote" returnFormat="plain">
  <cfargument name="url" type="string" required="true">
  <cfargument name="returnType" type="string" default="json">

  <cfhttp method="get" url="#arguments.URL#" result="firebaseResponse">
  <cfset fireBaseData = deserializeJson(firebaseResponse.fileContent)>

  <cfreturn firebaseData>
</cffunction>

<!--- Update Data --->
<cffunction name="updateData" access="remote" returnFormat="plain">
  <cfargument name="url" type="string" required="true">
  <cfargument name="returnType" type="string" default="json">
  <cfargument name="data" type="struct" required="true">

    <cfset data = serializeJson(arguments.data)>

    <cfhttp method="put" url="#arguments.URL#.json" result="firebaseResponse">
      <cfhttpparam type="body" value="#arguments.data#">
    </cfhttp>

  <cfset fireBaseData = firebaseResponse.fileContent>
  <cfreturn firebaseData>
</cffunction>
