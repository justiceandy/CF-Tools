<cfcomponent hint="Handles Logic for checking for Wordpress Data">

	<!--- Component Handles Exporting Wordpress Post Data to Required Format for your New CMS --->

	<!--- Check Single Datasource for WP Install --->
	<cffunction name="checkForWP"  access="remote" hint="checks datasource name for WP install">
		<cfargument name="db" type="string" required="true" hint="Name of database to check">
		<cftry>
			<cfinvoke component="wp" method="getInstallInfo" returnVariable="wpInfo">
				<cfinvokeargument name="db" value="#arguments.db#">
			</cfinvoke>
		<cfcatch>
			<cfdump var="#catch#">
		</cfcatch>
		</cftry>
	</cffunction>

	<!--- Check List of Datasources For WP Install --->
	<cffunction name="checkListForWP" access="remote" hint="Checks CSV String of Datasource Names for WP Install Data">
		<cfargument name="list" type="string" required="true">
		<cfset result = StructNew()>
		<cfset result.installData = StructNew()>
		<!--- If we have list items to check --->
		<cfif listLen(arguments.list) GT 0>
			<cfset result.status= "Searched List Items">
			<!--- Loop Items in list --->
			<cfloop list="#arguments.list#" index="i">
				<!--- Hit Check function --->
				<cfinvoke component="wp" method="checkForWP" returnvariable="wpStatus">
					<cfinvokeargument name="name" value="#i#">
				</cfinvoke>
				<cfset result.installData[i] = structCopy(wpStatus)>
			</cfloop>
		<!--- If list of datasources isnt supplied --->
		<cfelse>
			<cfset result.status = "Datasource List is Empty">
		</cfif>
		<cfreturn result>
	</cffunction>


	<!--- Get Existing Posts --->
	<cffunction name="getPosts" hint="Returns structure of existing posts for a wordpress database including meta info">
		<cfargument name="db" type="string" required="true" hint="Name of database to check">

		<!--- Returns Post Data, Title, Seo, Tag Info, user --->
		<cfquery name="getPosts" datasource="#arguments.db#">
			SELECT * FROM wp_posts
			INNER JOIN wp_postmeta ON wp_posts.ID = wp_postmeta.post_id
			where post_date_gmt != "0000-00-00 00:00:00"
		</cfquery>

		<cfset result = structNew()>
		<!--- If we have posts --->
		<cfif getPosts.recordCount GT 0>
			<cfset result.status = "success">

			<!--- Create Dynamic Column list incase user added anything --->
			<cfset cols = getMetadata(getPosts)>
			<cfset colList = "">
			<cfloop from="1" to="#arrayLen(cols)#" index="x">
			    <cfset colList = listAppend(colList, cols[x].name)>
			</cfloop>

			<!--- Loop Posts and add to return result --->
			<cfloop query="getPosts">
				<!--- If user doesnt exists in result struct already --->
				<cfif !structKeyExists(result, getPosts.id)>
					<cfset result.posts[getPosts.id] = structNew()>
				    <cfloop index="col" list="#collist#">
				        <cfset result.posts[getPosts.id][col] = getPosts[col][currentRow] >
				    </cfloop>
			    <!--- Struct was found matching id, add User data item  --->
			    <cfelse>
					<cfset result[users.user_login][users.meta_key] = meta_value>
				</cfif>
			</cfloop>

		<!--- If no posts were found --->
		<cfelse>
			<cfset result.error = "No Posts found">
			<cfset result.status = "fail">
		</cfif>
		<cfreturn result>
	</cffunction>



	<!--- Get Users --->
	<cffunction name="getUsers" hint="returns a strcture of users for a wordpress database">
		<cfargument name="db" type="string" required="true" hint="Name of database to check">
		<!--- Get Users from DB --->
		<cfquery name="users" datasource="#arguments.db#">
			select * from wp_users
			inner join wp_usermeta on wp_users.ID = wp_usermeta.user_ID
		</cfquery>
		<cfset result = structNew()>
		<!--- Create Dynamic Column list incase user added anything --->
		<cfset cols = getMetadata(users)>
		<cfset colList = "">
		<cfloop from="1" to="#arrayLen(cols)#" index="x">
		    <cfset colList = listAppend(colList, cols[x].name)>
		</cfloop>
		<!--- Loop All Users --->
		<cfloop query="users">
			<!--- If user doesnt exists in result struct already --->
			<cfif !structKeyExists(result, users.user_login)>
				<cfset result[users.user_login] = structNew()>
			    <cfloop index="col" list="#collist#">
			        <cfset result[users.user_login][col] = users[col][currentRow] >
			    </cfloop>
		    <!--- Struct was found matching id, add User data item  --->
		    <cfelse>
				<cfset result[users.user_login][users.meta_key] = meta_value>
			</cfif>
		</cfloop>
		<cfreturn result>
	</cffunction>



	<!--- Get Included Plugins --->
	<cffunction name="getPlugins" access="remote" returnType="struct" hint="Gets list of installed plugins">
		<cfargument name="db" type="string" required="true" hint="Name of database to check">

		<cfquery name="optionsMeta" datasource="#arguments.db#">
			select * from wp_options
			where option_name = "active_plugins"
		</cfquery>
		<cfset result = structNew()>
		<cfset result.plugins = optionsMeta.option_value>
		<cfset result.blogID = optionsMeta.blogID>
		<cfset result.optionID = optionsMeta.option_id>
		<cfreturn result>
	</cffunction>


	<!--- Get Meta Info about Install --->
	<cffunction name="getInstallInfo" access="remote" returnType="struct" hint="gets Options table info from wordpress install">
		<cfargument name="db" type="string" required="true" hint="Name of database to check">
		<cfquery name="optionsMeta" datasource="#arguments.db#">
			select * from wp_options
		</cfquery>
		<cfreturn optionsMeta>
	</cffunction>



	<!--- Get Existing Post Tags --->
	<cffunction name="getPostTags" access="remote" returnType="struct" hint="gets tags from a wordpress db">
		<cfargument name="db" type="string" required="true" hint="Name of database to check">

		<cfquery name="getPostTags" datasource="#arguments.db#">
			SELECT * FROM wp_term_taxonomy
			INNER JOIN wp_terms ON wp_term_taxonomy.`term_id` = wp_terms.term_ID
			WHERE taxonomy = "post_tag"
		</cfquery>

		<cfset result = structNew()>

		<!--- If we found tags --->
		<cfif getPostTags.recordCount NEQ 0>

			<cfset result.tags = structNew()>

			<cfloop query="getPostTags">
				<cfset result.tags[term_id] = structNew()>
				<cfset result.tags[term_id].name = getPostTags.name>
				<cfset result.tags[term_id].slug = getPostTags.slug>
				<cfset result.tags[term_id].termID = getPostTags.term_id>
				<cfset result.tags[term_id].count = getPostTags.count>
			</cfloop>
			<cfset result.status = "success">
		<!--- If no tags were found --->
		<cfelse>
			<cfset result.message = "No Post Tags Found">
			<cfset result.status = "fail">
		</cfif>
		<cfreturn result>
	</cffunction>


	<!--- Get Comments --->
	<cffunction name="getPostComments" access="remote" returnType="struct" hint="gets post comments">
		<cfargument name="db" type="string" required="true" hint="Name of DB to check">

		<cfquery name="getComments" datasource="#arguments.db#">
			select * from wp_comments
		</cfquery>
		<cfset result = structNew()>
		<cfset result.comments = structNew()>

		<--- If we found comments --->
		<cfif getComments.recordCount NEQ 0>
			<cfloop query="getComments">
				<cfset result.comments[getComments.comment_ID] = structNew()>
				<cfset result.comments[getComments.comment_ID].authorEmail = getComments.comment_author_email>
				<cfset result.comments[getComments.comment_ID].author = getComments.comment_author>
				<cfset result.comments[getComments.comment_ID].authorURL = getComments.comment_author_url>
				<cfset result.comments[getComments.comment_ID].authorIP = getComments.comment_author_ip>
				<cfset result.comments[getComments.comment_ID].postDate = getComments.comment_content>
				<cfset result.comments[getComments.comment_ID].content = getComments.content>
				<cfset result.comments[getComments.comment_ID].commentAgent = getComments.comment_agent>
				<cfset result.comments[getComments.comment_ID].userID = getCOmments.user_id>
			</cfloop>
		<!--- if no comments were found --->
		<cfelse>
			<cfset result.message = "No Comments Found">
			<cfset result.status = "fail">
		</cfif>
		<cfreturn result>
	</cffunction>






</cfcomponent>
