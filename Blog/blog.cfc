<cfcomponent hint="Handles Blog Post Related Functions">

	<!--- Example Blog CFC  Handles most blogging related functions, will need MySQL Database to function --->

	<cfset application.blogDB = "blog">
	<!--- Create Struct Of Blog Data ---->
	<cfset application.blogData = structNew()>
	<cfset application.blogData.newPostURL = "">

	<!--- Get Categories --->
	<cffunction name="getCategories" access="remote" hint="returns query or structure, depending on request, of blog categories">
		<cfargument name="sortBy" type="string" default="alphaAsc">
		<cfargument name="returnFormat" type="string" default="query">
			<cfquery name="categories" datasource="#application.blogDB#">
				select categories.categoryName, categories.categoryID, categories.createDate, categories.description, categories.seoURL, categories.seoDescription,
				categories.modified, count(posts.postID) as postCount
				from categories
				inner join posts on categories.categoryID = posts.postCatID

				group by categories.categoryID
					<cfif arguments.sortBy eq "alphaAsc">
					order by categoryName asc
				<Cfelseif arguments.sortBy eq "posts">
					order by postCount desc
				</cfif>
			</cfquery>
			<cfif arguments.returnFormat EQ "query">
				<cfreturn categories>
			<!--- Convert query to struct --->
			<cfelse>
				<cfset result = structNew()>
				<cfloop query="categories">
					<cfif !structKeyExists(result, categories.categoryID)>
						<cfset result[categories.categoryID] = structNew()>
						<cfset result[categories.categoryID].categoryName = categories.categoryName>
						<cfset result[categories.categoryID].categoryID = categories.categoryID>
						<cfset result[categories.categoryID].createDate = categories.createDate>
						<cfset result[categories.categoryID].description = categories.description>
						<cfset result[categories.categoryID].seoURL = categories.seoURL>
						<cfset result[categories.categoryID].seoDescription = categories.seoDescription>
						<cfset result[categories.categoryID].modified = categories.modified>
						<cfset result[categories.categoryID].postCount = categories.postCount>
					</cfif>
				</cfloop>
				<cfif arguments.returnFormat EQ "json">
					<cfreturn serializeJson(result)>
				<cfelse>
					<cfreturn result>
				</cfif>
			</cfif>
	</cffunction>


	<!--- Get Single Category Info --->
	<cffunction name="getCategoryInfo" access="remote" hint="returns a structure or query (depending on request) of information about the requested category">
		<cfargument name="categoryID" type="numeric" required="true" hint="ID of category to get info">
		<cfargument name="returnFormat" type="string" default="query">
		<cfquery name="categoryInfo" datasource="#application.blogDB#">
			SELECT categories.categoryName, categories.categoryID, categories.createDate, categories.description, categories.seoURL,
			categories.seoDescription, categories.modified, COUNT(posts.postID) AS postCount
			FROM categories
			INNER JOIN posts ON categories.categoryID = posts.postCatID
			WHERE categoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryID#">
		</cfquery>

		<cfif arguments.returnformat EQ "query">
			<cfreturn categoryInfo>
		<cfelse>

			<cfset result = structNew()>
			<cfset result.categoryID = categoryINfo.categoryID>
			<cfset result.categoryName = categoryInfo.categoryName>
			<cfset result.createDate = categoryInfo.createDate>
			<cfset result.description = categoryINfo.description>
			<cfset result.seoURL = categoryInfo.seoURL>
			<cfset result.seoDescription = categoryInfo.seoDescription>
			<cfset result.modified = categoryINfo.modified>
			<cfset result.postCount = categoryInfo.postCount>

			<cfif arguments.returnformat EQ "json">
				<cfreturn serializeJSON(result)>
			<cfelse>
				<cfreturn result>
			</cfif>
		</cfif>
	</cffunction>



	<!--- Create Category --->
	<cffunction name="createCategory" access="remote" hint="creates new category">
		<cfargument name="redirect" default="true" type="string">
		<cfargument name="name" type="string" required="true">
		<cfargument name="description" type="string" default="">
		<!--- Check if Category Exists --->
		<cfquery name="checkCat" datasource="blog">
			select categoryID
			from categories
			where categoryName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
		</cfquery>
		<cfset result = structNew()>
		<!--- Create Category --->
		<cfif checkCat.recordCount EQ 0>
		<cfset seoURL = "">

		<cfquery name="insertCategory" datasource="blog" result="newCat">
			insert into categories
			(categoryName, description, createDate, modified,  seoURL )
			values
			(
			<Cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
			<Cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
			<Cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<Cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<Cfqueryparam cfsqltype="cf_sql_varchar" value="#seoURL#">
			)
		</cfquery>

		<cfset result.catID = newCat.generated_key>
		<cfset result.status  = true>

		<!--- If Category Exists --->
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Category already exists">

		</cfif>
		<cfreturn result>
	</cffunction>



	<!--- Link Post to Category --->
	<cffunction name="linkPostToCategory" access="remote" hint="Links a PostID to a category ID">
		<cfargument name="postID" type="numeric" required="true">
		<cfargument name="catID" type="numeric" required="true">
		<cfset result = structNew()>

		<!--- Check if postID is valid --->
		<cfinvoke component="blog" method="checkPostID" result="validPost">
			<cfinvokeargument name="postID" value="#arguments.postID#">
		</cfinvoke>

		<cfif validPost eq false>
			<cfset result.status = false>
			<cfset result.message = "Post ID Not Valid">
			<cfreturn result>
		</cfif>

		<!--- Check if Cat is valid --->
		<cfinvoke component="blog" method="checkCatID" result="validCat">
			<cfinvokeargument name="catID"value="#arguments.catID#">
		</cfinvoke>

		<cfif validCat EQ false>
			<cfset result.status = false>
			<cfset result.message = "Cat ID Not Valid">
			<cfreturn result>
		</cfif>

		<!--- If Both ID's are valid, create link ---->
		<cfif validPost EQ true and validCat EQ true>
			<!--- Insert Link ---->
			<cfquery name="updatePost" datasource="#application.blogDB#">
				update posts
				set postCatID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.catID#">
				where postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">
			</cfquery>
			<cfset result.message  = true>
		</cfif>
		<cfreturn result>
	</cffunction>



	<!--- Check If Cat Is Valid --->
	<cffunction name="checkCatID" returnType="boolean" access="remote" hint="checks if category id is valid">
		<cfargument name="catID" type="numeric" required="true">
		<cfquery name="checkCat" datasource="#application.blogDB#">
			select categoryID
			from categories
			where catID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.catID#">
		</cfquery>
		<cfif checkCat.recordCount EQ 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>



	<!--- Create Post ---->
	<cffunction name="createPost" access="remote" hint="Creates a Blog Post">
		<cfargument name="catID" type="numeric" required="true">
		<cfargument name="title" type="string" required="true">
		<cfargument name="content" type="string" required="true">
		<cfargument name="author" type="numeric" required="true">
		<cfargument name="returnType" default="struct" type="string">
		<cfargument name="summary" type="string" default="">

			<!--- Check that post title doesnt exist already --->
			<cfquery name="checkPostTitle" datasource="blog">
				select postTitle
				from posts
				where postTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
			</cfquery>

			<!--- If we dont have a post with this title --->
			<cfif checkPostTitle.recordCount EQ 0 and arguments.title NEQ "" and arguments.content NEQ "">
					<cfset result.status  = true>
					<cfset result.message = "Created Post">

					<cfinvoke component="cfc.seo.seo" method="createSEOstring" returnvariable="seoURL">
						<cfinvokeargument name="string" value="#arguments.title#">
					</cfinvoke>

					<!--- Insert Post --->
					<cfquery name="insertPost" datasource="blog" result="dbPost">
						insert into posts
						(postCatID, postDate, modified, author, postContent, postTitle, postSummary, seoURL, thumbnail)
						values
						(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CatID#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.author#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.content#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summary#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#seoURL#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="">
						)
					</cfquery>







					<!--- Loop Arguments to check for tags --->
					<cfloop collection="#arguments#" item="argument">

						<cfif left(argument, 3) EQ "tag">




						</cfif>

					</cfloop>



			<!--- If we have a post with this title --->
			<cfelseif arguments.title NEQ "">
				<cfset result.status = false>
				<cfset result.message = "Post Exists with Same Title">
			<cfelseif arguments.title EQ "">
				<cfset result.status = false>
				<cfset result.message = "Post Must have a title">
			<cfelseif arguments.content EQ "">
				<cfset result.status = false>
				<cfset result.message = "Post Must have content">
			</cfif>

			<cfif arguments.returnType EQ "redirect">
				<cfreturn result>
			<cfelseif arguments.returnType EQ "json">
				<cfreturn serializeJson(result)>
			<!--- Redirect to New post --->
			<cfelse>
				<cfif result.status EQ "success">
					<cflocation url="/index.cfm?mf=blog.editPost&postID=#dbPost.generated_key#">
				<cfelse>
					<cfhttp method="post" url="#application.blogData.createPostURL#">
						<cfhttpparam type="formfield" name="content" value="#arguments.content#" >
						<cfhttpparam type="formfield" name="title" value="#arguments.title#">
						<cfhttpparam type="formfield" name="category" value="#arguments.catID#">
					</cfhttp>
				</cfif>
			</cfif>
	</cffunction>


	<!--- Check post ID --->
	<cffunction name="checkPostID" access="remote" hint="Checks if Post ID is valid">
		<cfargument name="postID" type="numeric" required="true">
		<cfquery name="checkPost" datasource="#application.blogDB#">
			select postID
			from posts
			where postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">
		</cfquery>

		<cfif checkPost.recordCount EQ 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>



	<!--- Update Post ---->
	<cffunction name="updatePost" access="remote" hint="Updates a Posts Info">
		<cfargument name="postID" type="numeric" required="true">
		<cfargument name="catID" type="numeric" required="true">
		<cfargument name="title" type="string" required="true">
		<cfargument name="content" type="string" required="true">
		<cfargument name="summary" type="string" required="true">

		<cfset result = structNew()>

		<!--- Check if postID is valid --->
		<cfinvoke component="blog" method="checkPostID" result="validPost">
			<cfinvokeargument name="postID" value="#arguments.postID#">
		</cfinvoke>

		<cfif validPost eq false>
			<cfset result.status = false>
			<cfset result.message = "Post ID Not Valid">
			<cfreturn result>
		</cfif>

		<!--- Check if Cat is valid --->
		<cfinvoke component="blog" method="checkCatID" result="validCat">
			<cfinvokeargument name="catID"value="#arguments.catID#">
		</cfinvoke>

		<cfif validCat EQ false>
			<cfset result.status = false>
			<cfset result.message = "Cat ID Not Valid">
			<cfreturn result>
		</cfif>

		<!--- Check if Seo Name Changed --->
		<cfquery name="getTitle" datasource="#application.blogDB#">
			select postTitle
			from posts
			where postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#" >
		</cfquery>

		<cfif getTitle.postTitle EQ arguments.title>
			<cfset seoURL = getTitle.seoURL>

		<!--- Create New SEO URL --->
		<cfelse>

			<cfset seoURL = "">


			<!--- Store Old URL --->
		</cfif>


		<cfquery name="updatePost" datasource="#application.blogDB#">
			update posts
			set postContent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.content#">,
				postTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
				postSummary = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
				seoURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#seoURL#">,
				postCatID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.catID#">,
				modified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		</cfquery>


		<cfset result.message = "Updated Post">

		<cfreturn result>


	</cffunction>



	<!--- Get Post Info ---->
	<cffunction name="getPostInfo" returnType="query" hint="returns query of info about post">
		<cfargument name="postID" type="numeric" required="true">
		<cfquery name="postINfo" datasource="#application.blogDB#">
			select *
			from posts
			where postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">
		</cfquery>
		<cfreturn postInfo>
	</cffunction>

	<!--- Get All Posts --->
	<cffunction name="getAllPosts" access="remote" returnType="query" hint="Returns query of all Posts">
		<cfargument name="sortBy" type="string" default="alphaAsc">
		<cfargument name="limit" type="numeric" default="0">

		<cfquery name="getPosts" datasource="#application.blogDB#">
			select postCatID, author, postDate, postID, postContent, postTitle, totalComments, postSummary, seoUrl, thumbnail, postMetaDesc, modified
			from posts
			<!--- If we are sorting --->
			<cfif arguments.sortBy EQ "alphaAsc">
				order by postTitle asc
			<cfelseif arguments.sortBy EQ "latest">
				order by postDate desc
			</cfif>
			<!--- If we have a limit --->
			<cfif arguments.limit NEQ 0>
				limit #arguments.limit#
			</cfif>
		</cfquery>


		<cfreturn getPosts>
	</cffunction>



	<!----	Author Functions

	---->

	<cffunction name="checkAuthor" access="remote" returnType="boolean" hint="Checks if authorID is valid. returns true or false" >
		<cfargument name="authorID" type="numeric" required="true">
		<cfquery name="checkAuthor" datasource="cms_users">
			select userID
			from users
			where authorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.authorID#">
		</cfquery>
		<cfif checkAuthor.recordCount EQ 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>


	<!--- Get Posts from Author --->
	<cffunction name="getPostsFromAuthor" access="remote" returnType="query" hint="Returns query of Posts from Author">
		<cfargument name="authorID" type="numeric" required="true">
		<cfquery name="getPosts" datasource="#application.blogDB#">
			select * from posts
			where author = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.authorID#">
		</cfquery>
		<cfreturn getPosts>
	</cffunction>



	<!--- Change Post Author --->
	<cffunction name="changePostAuthor" access="remote" hint="">
		<cfargument name="postID" type="numeric" required="true">
		<cfargument name="newAuthor" type="numeric" required="true">
		<cfset result = structNew()>
		<!--- check valid author --->
		<cfinvoke component="blog" method="checkAuthor" returnVariable="validAuthor">
			<cfinvokeargument name="authorID" value="#arguments.newAuthor#">
		</cfinvoke>
		<!--- If author is valid, change ---->
		<cfif validAuthor EQ true>
			<cfquery name="updatePost" datasource="#application.blogDB#">
				update posts
				set author = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newAuthor#" >
				where postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">
			</cfquery>
			<cfset result.status = true>
			<cfset result.message = "Changed AuthorID">
		<cfelse>
			<cfset result.status = false>
			<cfset result.mesage = "AuthorID Not Valid. Unable to Change Author">
		</cfif>
		<cfreturn result>
	</cffunction>


	<!--- get author info --->
	<cffunction name="getAuthorInfo" access="remote" returnType="query" hint="Checks if author ID is a valid author" >
		<cfargument name="authorID" type="numeric" required="true">
		<cfquery name="checkUserExists" datasource="cms_users">
			select * from users
			where userID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authorID#">
		</cfquery>
		<cfreturn checkUserExists>
	</cffunction>


	<!--- Get Users --->
	<cffunction name="getAuthors" access="remote" returnType="struct" hint="returns structure of authors and post counts">
		<cfargument name="sortBy" default="posts" type="string">
		<!--- Get All Users --->
		<cfquery name="users" datasource="cms_users">
			select * from users
		</cfquery>
		<cfset result = structNew()>
		<cfset result.users = structNew()>
		<!--- Loop Each User --->
		<cfloop query="users">
			<!--- Get Posts from Author --->
			<cfinvoke component="blog" method="getPostsFromAuthor" returnVariable="authorPosts">
				<cfinvokeargument name="authorID" value="#users.userID#">
			</cfinvoke>
			<cfset result.users[users.userID] = structNew()>
			<cfset result.users[users.userID].posts = authorPosts.recordCount>
			<cfset result.users[users.userID].userName = users.userName>
		</cfloop>
		<cfset result.postSort = ArrayToList( StructSort( result.users, "text", "ASC", "posts") )>
		<cfreturn result>
	</cffunction>




	<!---

				End Of Author Functions
	---->





	<!----

			Post Tag Functions

	---->


	<!--- Create Post Tag --->
	<cffunction name="createPostTag" access="remote" hint="Creates a Tag that can be linked to posts">
		<cfargument name="name" type="string" required="true">
		<cfargument name="returnType" type="string" default="struct" hint="struct or json">

			<cfquery name="checkTag" datasource="blog">
				select tagID
				from post_tags
				where tagName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
			</cfquery>
			<cfset result = structNew()>

			<cfif checkTag.recordCount EQ 0>
				<!--- Create Seo Slug ---->
				<cfset seoSlug = "">
				<cfquery name="createTag" datasource="blog" result="tagID">
					insert into post_tags
					(tagName, count, tagSlug, createDate)
					values
					(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#seoSlug#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					)
				</cfquery>
				<cfset result.message = "Created Tag">
				<cfset result.tagID = tagID.generated_key>
			<cfelse>
				<cfset result.message = "Tag Exists">
			</Cfif>

			<cfif arguments.returnType EQ "struct">
				<cfreturn result>
			<cfelseif arguments.returnType EQ "json">
				<cfreturn serializeJson(result)>
			<cfelse>
				<cfif structKeyExists(arguments, "postID")>
					<cflocation url="index.cfm?mf=blog.editPost&postID=#arguments.postID#" addtoken="false">
				<cfelse>
					<cflocation url="index.cfm?mf=blog.tags" addtoken="false">
				</cfif>
			</cfif>
	</cffunction>



	<!--- Add Tag to Post ---->
	<cffunction name="addTagToPost" access="remote"  hint="adds a tag to a post">
			<cfargument name="tagID" type="numeric" required="true">
			<cfargument name="postID" type="numeric" required="true">
			<cfargument name="userID" type="numeric" required="true">

			<cfset result= structNew()>

			<!--- Check if post is valid --->
			<cfinvoke component="blog" method="checkPostID" returnvariable="validPost">
				<cfinvokeargument name="postID" value="#arguments.postID#">
			</cfinvoke>

			<cfif validPost eq false>
				<cfset result.message = "Post ID not Valid">
				<cfset result.status = false>
				<cfreturn result>
			</cfif>

			<!--- Check if Tag is valid --->
			<cfinvoke component="blog" method="checkTagID" returnvariable="validTag">
				<cfinvokeargument name="tagID" value="#arguments.tagID#">
			</cfinvoke>

			<cfif validTag eq false>
				<cfset result.message = "Tag ID not Valid">
				<cfset result.status = false>
				<cfreturn result>
			</cfif>
			<!--- Check that Post doesnt have tag already --->
			<cfquery name="checkPostTag" datasource="#application.blogDB#">
				select tagID
				from post_tag_link
				where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
				and postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">
			</cfquery>

			<cfif checkPostTag.recordCount NEQ 0>
				<cfset result.message = "Post already has this Tag">
				<cfset result.status = false>
				<cfreturn result>
			</cfif>

			<!---  If we made it this far, get current Count ---->
			<Cfset postTagOrder = "1">
			<cfquery name="insertTagLink" datasource="blog" result="link">
				insert into post_tag_link
				(tagID, postID, tagOrder, linkDate, linkedBy)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#postTagOrder#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
				)
			</cfquery>

			<cfset result.status = true>
			<cfset result.message = "Created Post Tag link">
			<cfreturn result>
	</cffunction>


	<!--- Combine Tag ---->
	<cffunction name="combineTag" access="remote" hint="Combines 2 tags into 1">
		<cfargument name="removedTag" type="numeric" required="true" hint="Tag to be removed">
		<cfargument name="linkTag" type="numeric" required="true" hint="Tag to replace removed Tag">

		<cfset result = structNew()>

		<!--- Check that remove tag and link tag are valid --->
		<cfinvoke component="blog" method="checkTagID" returnVariable="validRemoveTag">
			<cfinvokeargument name="tagID" value="#arguments.removedTag#">
		</cfinvoke>

		<cfinvoke component="blog" method="checkTagID" returnVariable="validLinkTag">
			<cfinvokeargument name="tagID" value="#arguments.linkTag#">
		</cfinvoke>

		<cfif validRemoveTag and validLinkTag>
			<cfquery name="postLink" datasource="#application.blogDB#">
				update post_tag_link
				set tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.linkTag#" >
				where tagID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.removedTag#">
			</cfquery>
			<cfquery name="removeTag" datasource="#application.blogDB#">
				delete from post_tags
				where tagID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.removedTag#">
			</cfquery>

			<cfset result.status  = true>
			<cfset result.message = "Updated Posts to New Tag">
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Link and Remove Tag Must be Valid">
		</cfif>
		<cfreturn result>
	</cffunction>


	<!--- Get All Post Tags --->
	<cffunction name="getAllPostTags" returnType="query" access="remote" hint="returns query of post tags">
		<cfargument name="sortBy" default="alphaAsc">
		<cfquery name="getTags" datasource="#application.blogDB#">
			select post_tags.tagName, post_tags.tagID, post_tags.tagSlug, count(post_tag_link.linkID) as postCount
			from post_tags
			inner join post_tag_link on post_tags.tagID = post_tag_link.tagID
			group by post_tags.tagID
			<cfif sortBy EQ "alphaAsc">
				order by tagName asc
			<cfelseif sortBy EQ "posts">
				order by postCount desc
			</cfif>
		</cfquery>
		<cfreturn getTags>
	</cffunction>


	<!--- Get Single Post Tags --->
	<cffunction name="getPostTags" access="remote" hint="returns tags for a post in specified format">
		<cfargument name="postID" type="numeric" required="true">

		<cfquery name="getTags" datasource="#application.blogDB#">
			select post_tags.tagName, post_tags.tagID, post_tags.tagSlug
			from post_tags
			inner join post_tag_link on post_tags.tagID = post_tag_link.tagID
			where postID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.postID#">
		</cfquery>

		<cfreturn getTags>
	</cffunction>




	<!--- Check IF TagID is valid --->
	<cffunction name="checkTagID" access="remote" returnType="boolean" hint="Checks if TagID is valid">
		<cfargument name="tagID" type="numeric" required="true">
		<cfquery name="checkTag" datasource="#application.blogDB#">
			select tagID
			from post_tags
			where tagID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.tagID#">
		</cfquery>
		<cfif checkTag.recordCount GT 0>
			<cfset result = true>
		<cfelse>
			<cfset result = false>
		</cfif>
		<cfreturn result>
	</cffunction>


	<!--- Update Tag ---->
	<cffunction name="updateTagData" access="remote" hint="Updates a tags data attributes">
		<cfargument name="tagID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="name" type="numeric" required="true">

		<cfset result = structNew()>

		<!--- Check if Tag is valid --->
		<cfinvoke component="blog" method="checkTagID" returnvariable="validTag">
			<cfinvokeargument name="tagID" value="#arguments.tagID#">
		</cfinvoke>

		<cfif validTag eq false>
			<cfset result.message = "Tag ID not Valid">
			<cfset result.status = false>
			<cfreturn result>
		</cfif>

		<!--- Get Current Name ---->
		<cfquery name="postName" datasource="#application.blogDB#">
			select tagName
			from post_tags
			where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
		</cfquery>


		<cfif postName.tagName EQ arguments.Name>
			<cfset result.status = false>
			<cfset result.message = "Info hasnt changed">
			<cfreturn result>
		</cfif>


		<!--- Get New Seo Slug --->
		<cfinvoke component="seo.seo" method="createSEOstring" returnVariable="seoString">
			<cfinvokeargument name="string" value="#arguments.name#">
		</cfinvoke>


		<!--- Update Tag --->
		<cfquery name="updateTag" datasource="#application.blogDB#">
			update post_tags
			set tagName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				tagSlug = <cfqueryparam cfsqltype="cf_sql_varchar" value="#seoString#">
			where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#" >
		</cfquery>

		<cfset result.status = true>
		<cfset result.message = "Updated Tag INfo">
		<cfreturn result>
	</cffunction>



	<!--- Get Tag INfo --->
	<cffunction name="getTagInfo" access="remote" hint="returns query of tag INfo">
		<cfargument name="tagID" type="numeric" required="true">
		<cfquery name="getTag" datasource="#application.blogDB#">
			select * from post_tags
			where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
		</cfquery>
		<cfreturn getTag>
	</cffunction>




	<!--- Get Posts Linked to Tag --->
	<cffunction name="getPostsLinkedToTag" access="remote" hint="returns posts linked to tag">
		<cfargument name="tagID" type="numeric" required="true">

		<!--- Check if Tag is valid --->
		<cfinvoke component="blog" method="checkTagID" returnvariable="validTag">
			<cfinvokeargument name="tagID" value="#arguments.tagID#">
		</cfinvoke>
		<cfif validTag eq false>
			<cfset result.message = "Tag ID not Valid">
			<cfset result.status = false>
			<cfreturn result>
		</cfif>
		<!--- Get Posts --->
		<cfquery name="getPosts" datasource="#application.blogDB#">
			select * from post_tags
			inner join posts on post_tags.postID = posts.postID
			where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
		</cfquery>
		<cfreturn getPosts>
	</cffunction>


	<!--- Get Dashboard INfo --->
	<cffunction name="getDashboardStats" access="remote" returnType="struct" hint="returns structure dashboard info">
		<cfset result = structNew()>
		<cfinvoke component="blog" method="getAllPosts" returnvariable="result.posts" >
			<cfinvokeargument name="sortBy" value="latest">
		</cfinvoke>
		<!--- Get Authors --->
		<cfinvoke component="blog" method="getAuthors" returnvariable="result.authors" >
			<cfinvokeargument name="sortBy" value="posts">
		</cfinvoke>
		<!--- Get Categories --->
		<cfinvoke component="blog" method="getCategories" returnvariable="result.categories" >
			<cfinvokeargument name="sortBy" value="posts">
		</cfinvoke>
		<!--- Get Tags --->
		<cfinvoke component="blog" method="getAllPostTags" returnvariable="result.tags" >
			<cfinvokeargument name="sortBy" value="posts">
		</cfinvoke>
		<cfreturn result>
	</cffunction>


	<!--- Search Blogs --->
	<cffunction name="searchBlog" access="remote" returnType="query">
		<cfargument name="q" type="string" required="true">



	</cffunction>






	<!--- Render Post in WIZY  [CKeditor] Editor [FOR IFRAME]--->
	<cffunction name="renderPostEditor" access="remote" returnFormat="plain">
		<cfargument name="postID" type="numeric" required="true">

		<!---- Get Blog Info --->
		<cfinvoke component="blog" method="getPostInfo" returnVariable="postInfo">
			<cfinvokeargument name="postID" value="#arguments.postID#">
			<cfinvokeargument name="returnType" value="struct">
		</cfinvoke>

		<cfinvoke component="blog" method="renderEditor" returnVariable="editor">
			<cfinvokeargument name="html" value="#postINfo.postContent#">
		</cfinvoke>

		<cfreturn editor>
	</cffunction>




		<!--- Render Post in WIZY  [CKeditor] Editor [FOR IFRAME]--->
		<cffunction name="renderEditor" access="remote" returnFormat="plain">
			<cfargument name="html" type="string" default="">

			<cfsavecontent variable="htmlPage">
	      <script src="/bower_components/jquery/jquery.min.js"></script>
	      <textarea class="ckeditor" id="editor" name="editor" rows="25" style="display:none;">
	            <cfoutput>#arguments.html#</cfoutput>
	      </textarea>
	      <script type="text/javascript">
          $(document).ready(function(){
                var editor = CKEDITOR.replace('editor', {
                    language: 'en',
                      height:700,
                      width: 840,
                      allowedContent: true,
                      forcePasteAsPlainText: false,
                      autoParagraph: false,
                      fillEmptyBlocks: function (element) {
                      return true; //
                }
                });
                $('#ckEditorContainer').toggle();
                console.log('Replaced Editor');
          });
	      </script>
				<script src="/bower_components/ckeditor/ckeditor.js"></script>
			</cfsavecontent>
			<cfreturn htmlPage>
		</cffunction>


</cfcomponent>
