<cfcomponent hint="Handles DB Interaction Functions">

	<!--- Get Databases from MySQL --->
	<cffunction name="getMySQLDatasources" 	returnType="struct" access="remote" hint="Returns query of mysql databases">
		<cfargument name="db" type="string" required="true">
		<cfquery name="getDBs" datasource="#arguments.db#">
			show databases;
		</cfquery>
		<cfreturn getDBS>
	</cffunction>


	<!--- Get MySQL Datasource Tables --->
	<cffunction name="getMySQLTables" returnType="query" access="remote" hint="Gets tables in a MySQL datasource" >
		<cfargument name="datasource" type="string" required="true">
			<cfquery name="dbTables" datasource="#arguments.datasource#">
				show tables;
			</cfquery>
			<cfreturn dbTables>
	</cffunction>




	<!--- Create CFIDE Datasource --->
	<cffunction name="createDatasource" access="remote" returnType="struct" hint="Creates CF Datasource so we can query for data" >
		<cfargument name="CFname" type="string" required="true">
		<cfargument name="DBName" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="username" type="string" default="admin">
		<cfargument name="drive" type="string" default="mysql5">
		<cfargument name="port" type="numeric" default="3306">
		<cfargument name="host" type="string" default="localhost">
			<cfset result = structNEw()>
			<cftry>
				<cfscript>
				dsnAPI = createObject( 'component', 'cfide.adminapi.datasource' );
				dsn = {
					driver = 'mysql5',
					name = '#arguments.CFname#',
					host = '#arguments.host#',
					port = '#arguments.port#',
					database = '#arguments.dbName#',
					username = '#aguments.username#',
					password = '#arguments.password#',
					args = 'allowMultiQueries=true'
				};
				// save the new datasource
				dsnAPI.setMySQL5( argumentCollection = dsn );
				</cfscript>
				<cfset result.error = "">
				<cfset result.status = "Created">

				<cfcatch>
					<cfset result.error = structCopy(catch)>
					<cfset result.status = "fail">
				</cfcatch>
			</cftry>
			<cfreturn resut>
	</cffunction>



	<!--- Get Databases From CFIDE ---->
	<cffunction name="getCFDatasources" returnType="struct" access="remote" hint="Gets list of datasources from CFIDE">
		<cfargument name="password" type="string" required="true">
		<cfset result = structNew()>
		<!--- Try to use password to query CFIDE for dbs ---->
		<cftry>
			<Cfset adminObj = createObject("component","cfide.adminapi.administrator")>
			<cfset createObject("component","cfide.adminapi.administrator").login("#arguments.password#")>
			<cfset myObj = createObject("component","cfide.adminapi.datasource")>
			<cfset result.databases = myObj.getDatasources()>
			<cfset result.status = true>
			<cfset result.error = "">
			<!--- If fails return error code to user --->
			<cfcatch>
				  <cfset result.status = false>
				  <cfset result.error = cfcatch.errorCode>
			</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>


	<!--- Decrypt CFIDE Datasource Password --->
	<cffunction name="decryptCFIDEPassword" returnType="String" access="remote" hint="Decrypts a CFIDE Datasources Password">
		 <cfargument name="text" type="string" required="true">
		 <cfset result = "">
	      <cftry>
	        <cfset result = decrypt(arguments.text, generate3DesKey("0yJ!@1$r8p0L@r1$6yJ!@1rj"), "DESede", "Base64")>
		      <cfcatch>
		        <cfset result = "Error, not encoded in a standard format">
			  </cfcatch>
		  </cftry>
     	<cfreturn result>
	</cffunction>





</cfcomponent>
