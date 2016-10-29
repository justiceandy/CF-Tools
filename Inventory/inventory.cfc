<cfcomponent>

	<!---
	{ Component Handles all Inventory Related Database Interactions}

	Inventory Manager Example. Requires MySQL Tables to Function

	//Stock item Functions
		Add Stock item
		Remove Stock Item
		Update Stock item
		updateQty
		linkToWebModel
		getStockItems


	// Tag Functions
		Create Tag
		Rename Tag
		Remove Tag
		Link product to Tag
		Get Products in Tag
		Remove link to Tag
		*Get Tags

	//Stock Location Functions
		Add Stock Location
		Delete Stock Location
		Get Stock Locations
		Update Stock Location


	//Stat Functions
		getTotalInventoryCount
		getTotalInventoryCost

	// Search Functions
		searchInventoryItems

	---->

	<!--- Global Settings --->
	<cfset spreadsheetSaveLocation = "E:\htdocs\htdocs\inventory\uploads\">
	<cfset inventoryServerLocation = "E:\htdocs\htdocs\inventory\uploads\">
	<cfset inventoryDB = "inventory">



<!---
		Stock Item Functions
--->

	<!--- Add Stock Item --->
	<cffunction name="addStockItem" access="remote" hint="adds stock item to database">
		<cfargument name="locationID" type="numeric" default="1" required="true" hint="location item is stocked at">
		<cfargument name="modelNo" type="string" required="true" hint="model number of stocked item">
		<cfargument name="color" type="string" default="" hint="Color of Inventory item">
		<cfargument name="description" type="string" default="" hint="Decription of item">
		<cfargument name="category" type="string" default="" hint="Materialflow.com Category Item is Featured In">
		<cfargument name="manufacturer" type="numeric" default="0" hint="Manufacturer ID of product">
		<cfargument name="stockCount" type="numeric" default="1" hint="Initial Stock Count of item">
		<cfargument name="weight" type="numeric" default="0" hint="Weight of item">
		<cfargument name="caseCount" type="numeric" default="1" hint="If Item comes in case qty's, indicate">
		<Cfargument name="notes" type="string" default="" hint="additional notes about the product">
		<cfargument name="userID" type="numeric" required="true" hint="userID logging product into inventory">
		<cfargument name="tagList" type="string" default="" hint="List of Stock Tag ID's to assign for quick sorting">

		<cfif !isNumeric(arguments.caseCount)>
			<cfset arguments.caseCount = 1>
		</cfif>

		<cfset returnStruct = structNew()>
			<!--- Check if Model Number Matches CMS database --->
			<cfquery name="getModel" datasource="cms">
				select * from part
				where lcase(name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(lcase(arguments.modelNo))#">
			</cfquery>

			<!--- if we have model match, set manufacturer, category if not assigned  --->
			<cfif getModel.recordCount NEQ 0>
				<cfset returnStruct.modelMatch = "true">
				<!--- Get Manufacturer --->
				<cfquery name="getManu" datasource="cms">
					select * from part_class
					where classID = "#getModel.classID#"
				</cfquery>
				<cfset variables.partID = getModel.partID>
				<cfset arguments.manufactID = getManu.manufactID>
			<cfelse>
				<cfset returnStruct.modelMatch = "false">
				<cfset variables.partID = "">
			</cfif>

			<cfquery name="insertStockItem" datasource="inventory" result="stockID">
				insert into stock_items
				(
					stockLocation,
					stockModelName,
					color,
					description,
					<cfif arguments.category NEQ "">
					category,
					</cfif>
					<cfif arguments.manufacturer NEQ 0>
					manufacturer,
					</cfif>
					stockCount,
					weight,
					dateRecieved,
					<cfif variables.partID NEQ "">
					linkedPartID,
					</cfif>
					notes,
					caseCount
				)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.locationID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.modelNo#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.color#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
				<cfif arguments.category NEQ "">
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#">,
				</cfif>
				<cfif arguments.manufacturer NEQ 0>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.manufacturer#">,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockCount#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.weight#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfif variables.partID NEQ "">
					<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.PartID#">,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.notes#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.caseCount#">
				)
			</cfquery>
			<!--- Set Return StockID --->
			<cfset returnStruct.stockID = stockID.generated_key>
			<!--- If we have tag ids to add --->
			<cfif listLen(arguments.tagList) Gt 0>
				<!--- loop each Tag ID in list --->
				<cfloop list="#arguments.tagList#" index="i">
					<!--- Hit Add Tag function --->
					<cfinvoke component="inventory" method="createTagItemLink">
						<cfinvokeargument name="stockItemID" value="#returnStruct.stockID#">
						<cfinvokeargument name="stockTagID" value="#i#">
						<cfinvokeargument name="userID" value="#arguments.userID#">
					</cfinvoke>
				</cfloop>
				<cfset returnStruct.tagIDList = arguments.tagList>
			<cfelse>
				<cfset returnStruct.tagList = "">
			</cfif>
			<cfreturn returnStruct>
	</cffunction>


	<!--- Update Stock Item --->
	<cffunction name="updateStockItem" access="remote" hint="updates stock information about an item">
		<cfargument name="stockID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="locationID" type="numeric" required="true">
		<cfargument name="modelNo" type="string" required="true">
		<cfargument name="color" type="string" default="">
		<cfargument name="description" type="string" default="">
		<cfargument name="manufacturer" type="numeric" default="">
		<cfargument name="stockCount" type="numeric" default="">
		<cfargument name="weight" type="numeric" default="">
		<cfargument name="caseCount" type="numeric" default="">
		<Cfargument name="notes" type="string" default="">
		<cfargument name="linkedPartID" type="numeric" default="">
		<cfargument name="tagList" type="string" default="">

		<!--- Check that stock id is valid --->
		<cfinvoke component="inventory" method="checkStockID" returnVariable="checkID">
			<cfinvokeargument name="stockID" value="#arguments.stockID#">
 		</cfinvoke>

		<!--- If stock ID exists in database --->
 		<cfif checkID.recordCount NEQ 0>
		 	<!--- Update info ---->
		 	<cfquery name="updateStockInfo" datasource="inventory">
			 	update stock_items
			 	set stockLocation = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.locationID#">,
			 		stockModelName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.modelNo#">,
			 		color = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.color#">,
			 		description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
			 		category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#">,
			 		manufacturer = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.manufacturer#">,
			 		stockCount = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockCount#">,
			 		weight = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.weight#">,
			 		dateRecieved = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			 		linkedPartID = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.linkedPartID#">,
			 		notes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.notes#">,
			 		caseCount = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.caseCount#">
				where stockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockID#">
			 </cfquery>

			<!--- Delete all Tag Links not in list --->
			 <cfset message = "Updated Stock Item Info">
		 <cfelse>
		 	 <cfset message = "StockID doesnt exist in database">
		 </cfif>

			<cfreturn message>
	</cffunction>


	<!--- Delete Stock Item --->
	<cffunction name="deleteStockItem" access="remote" hint="removes Stock item from database">
		<cfargument name="stockID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">

		<!--- Check that stock id is valid --->
		<cfinvoke component="inventory" method="checkStockID" returnVariable="checkID">
			<cfinvokeargument name="stockID" value="#arguments.stockID#">
 		</cfinvoke>

 		<!--- If stock ID exists in database --->
 		<cfif checkID.recordCount NEQ 0>
			<!--- Delete Record --->
			<cfquery name="removeItem" datasource="inventory">
				delete from stock_items
				where stockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockID#">
			</cfquery>
			<cfset message ="Removed StockID: #arguments.stockID# from database">
		<cfelse>
			<cfset message ="StockID Doesnt exist in database">
		 </cfif>
		<cfreturn message>
	</cffunction>

	<!--- Update Quick Count --->
	<cffunction name="updateQuickCount" access="remote" hint="updates qty of a stocked model number">
		<cfargument name="stockID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="newStockCount" type="numeric" required="true">

		<!--- Check that stock id is valid --->
		<cfinvoke component="inventory" method="checkStockID" returnVariable="checkID">
			<cfinvokeargument name="stockID" value="#arguments.stockID#">
 		</cfinvoke>

 		<!--- If stock ID exists in database --->
 		<cfif checkID.recordCount NEQ 0>
		 	<cfif arguments.newStockCount LT 0>
				<cfset message = "Qty cannot be negative">
			<cfelse>
			 	<!---- update count --->
			 	<cfquery name="updateCount" datasource="inventory">
				 	update stock_items
				 	set qty = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newStockCount#">
					 where stockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockID#">
				 </cfquery>

				<cfset message = "Updated StockID: #arguments.stockID# with qty: #arguments.qty#">
		 	</cfif>
		 <!--- If stockID check came back invalid --->
		  <cfelse>
		 	 <cfset message = "Stock ID is invalid">
		 </cfif>

		<cfreturn message>
	</cffunction>

	<!--- Check that ID is valid ---->
	<cffunction name="checkStockID" access="remote" hint="checks if stockID is valid">
		<cfargument name="stockID" type="numeric" required="true">
		<cfquery name="checkID" datasource="inventory">
			select *
			from stock_items
			where stockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockID#">
		</cfquery>
		<cfreturn checkID>
	</cffunction>


	<!--- Link Web Site Product To Inventory Model Number --->
	<cffunction name="linkWebModel" access="remote" hint="Links a inventory model number with a web site model number">
		<cfargument name="stockItemID" type="numeric" required="true">
		<cfargument name="partID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">

		<!--- Check Stock ID --->
		<cfinvoke component="inventory" method="checkStockID" returnVariable="checkStockID">
			<cfinvokeargument name="stockID" value="#arguments.stockItemID#">
		</cfinvoke>

		<!--- Check Part ID --->
		<cfinvoke component="cfc.products.partFunctions" method="checkPartID" returnVariable="checkPartID">
			<cfinvokeargument name="partID"value="#arguments.partID#">
		</cfinvoke>

		<!--- If both ID's are valid, create link --->
		<CFIF checkStockID.recordCount NEQ 0 and checkPartID.recordCount NEQ 0>
			<cfquery name="updateStockItem" datasource="inventory">
				update stock_items
				set linkedPartID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partID#">
				where stockID = <Cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockItemID#">
			</cfquery>
			<cfset message = "Created Link For Model: #arguments.partID# and stockID: #arguments.stockItemID#">
		<cfelse>
			<cfset message = "StockItemID and or PartID couldnt be found in database">
		</cfif>

		<cfreturn message>
	</cffunction>


	<!--- Check Unlinked --->
	<cffunction name="checkUnlinkedModels" access="remote" hint="">



		<!--- Get Colors --->
		<cfinvoke component="cfc.products.colors" method="getAllColors" returnvariable="colorWheel">
			<cfinvokeargument name="returnType" value="struct">
		</cfinvoke>

		<!--- Get Stock Items --->
		<cfinvoke component="cfc.inventory.inventory" method="getStockItems" returnvariable="stockItems">
			<cfinvokeargument name="returnType" value="struct">
		</cfinvoke>

		<cfset models = structNew()>

		<cfloop collection="#stockItems.items#" item="i">
			<cfif stockItems.items[i]['linkedPartID'] EQ "">
				<cfset stockName = stockItems.items[i]['stockModelName']>
				<cfset models[stockName] = structNew()>
				<cfset models[stockName].stockID = i>
			</cfif>
		</cfloop>

		<cfset colorModels = structNew()>

		<!--- Loop Models and Check for Colors in Name --->
		<cfloop collection="#models#" item="i">
			<cfloop collection="#colorWheel#" item="x">
				<cfif findNoCase(x, i)>
					<cfset models[i].color = x>
					<cfset newName = replaceNoCase(i, x, "", "all")>
					<cfset newName =  newName.replaceAll("\\(.+\\)", "")>
					<cfset colorModels[newName] = structCopy(models[i])>
				</cfif>
			</cfloop>
		</cfloop>

		<!---
		<cfset stockName = replace(stockItems.items[i]['stockModelName'], " ", "", "all")>
		--->

		<!--- Get Models --->
		<cfinvoke component="cfc.products.partFunctions" method="getAllModels" returnvariable="validModels">
			<cfinvokeargument name="returnType" value="struct">
		</cfinvoke>

		<!--- Get All Colors to Parse from Name if possible --->

		<cfset modelsToLink = structNew()>

		<!--- Loop Each Model and see If Found in Stock Name --->

			<!--- If Found, Add to Models to link [CLAIMED] with original Text to verify

				Check if Claimed already,
					If Claimed if linked model text is longer. Take Longest Matching model String
					as to be linked
			--->

		<cfloop collection="#models#" item="i">
			<cfif structKeyExists(validModels, ucase(i))>
				<cfset modelsToLink[i] = structNew()>
				<cfset modelsToLink[i].partID = validModels[i].partID>
				<cfset modelsToLink[i].stockID = models[i].stockID>
				<cfset modelsToLink[i].stockName = i>
				<cfset modelsToLink[i].model = validModels[i].name>
			</cfif>
		</cfloop>

		<cfloop collection="#colorModels#" item="i">
			<cfif structKeyExists(validModels, ucase(i))>
				<cfset modelsToLink[i] = structNew()>
				<cfset modelsToLink[i].partID = validModels[i].partID>
				<cfset modelsToLink[i].stockID = colorModels[i].stockID>
				<cfset modelsToLink[i].stockName = i>
				<cfset modelsToLink[i].model = validModels[i].name>
			</cfif>
		</cfloop>
		<cfdump var="#modelsToLink#">


	</cffunction>



	<!--- Get Stock items --->
	<cffunction name="getStockItems" access="remote" hint="returns Stock items">
		<cfargument name="returnType" default="json" type="string">

		<cfset result = structNew()>

		<cfquery name="getStockItems" datasource="inventory">
			SELECT stock_items.stockID, stockModelName, color, description, category, manufacturer, weight,
			linkedPartID, notes, purchasePrice, caseCount, dateCreated, lastUpdated, SUM(COUNT) AS invCount
			FROM stock_items
			LEFT JOIN stock_location_count ON stock_items.stockID = stock_location_count.stockID
			GROUP BY stock_items.stockID
		</cfquery>

		<cfset result.count = getStockItems.recordCount>
		<cfset result.items = structNew()>

		<cfloop query="getStockItems">
			<cfset result.items[getStockItems.stockID] = structNew()>
			<cfloop list="#getStockItems.columnList#" index="i">
				<cfset result.items[getStockItems.stockID][i] = getStockItems[i][getStockItems.currentRow]>
			</cfloop>
		</cfloop>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>





<!---

	Spreadsheet Functions

--->

	<!--- Create Save Locations --->
	<cffunction name="createSaveLocations" access="remote" hint="Creates Save Locations of XLS uploads on the web server">
		<cfif !directoryExists(inventoryServerLocation)>
			<cfset directoryCreate(inventoryServerLocation)>
		</cfif>

		<cfif !directoryExists(spreadsheetSaveLocation)>
			<cfset directoryCreate(spreadsheetSaveLocation)>
		</cfif>
	</cffunction>



	<!--- Upload Spreadsheet --->
	<cffunction name="uploadSpreadsheet" access="remote" hint="Uploads an inventory spreadsheet">
		<cfargument name="xlsFile" required="true">
		<cfargument name="StockListName" required="false" default="#createUUID()#" hint="stock list uploaded items are linked to">
		<cfargument name="stockLocation" required="true" default="1" hint="stocking location that list is stocked at">


		<cfif !directoryExists(spreadsheetSaveLocation)>
			<cfinvoke component="inventory" method="createSaveLocations">
		</cfif>

		<!--- Declare Parse Result Struct --->
		<cfset parseResults = structNew()>
        <cfset parseResults.spreadRows = arrayNew(1)>
		<cfset parseResults.uniqueColList = "">
		<cfset parseResults.uniqueID = createUUID()>
		<cfset parseResults.uploadDate = now()>
		<cfset parseResults.dbStockListName = "">
		<cfset parseResults.initialCount = 0>
		<cfset parseResults.importCount = 0>
		<cfset parseResults.importedIDs = "">


		<!--- Upload File ---->
   		 <cffile action="upload" destination="#spreadsheetSaveLocation#" filefield="xlsfile" result="upload" nameconflict="makeunique">

		<!--- If File was successfully uploaded --->
	    <cfif upload.fileWasSaved>
	        <cfset theFile = upload.serverDirectory & "/" & upload.serverFile>
	        <cfif isSpreadsheetFile(theFile)>
	            <cfspreadsheet action="read" src="#theFile#" query="data" headerrow="1">
	            <cffile action="delete" file="#theFile#">
	            <cfset showForm = false>
	        <cfelse>
	            <cfset errors = "The file was not an Excel file.">
	            <cffile action="delete" file="#theFile#">
	        </cfif>
	    <cfelse>
	        <cfset errors = "The file was not properly uploaded.">
	    </cfif>

     	<!--- Save Output Table --->
		    <cfif structKeyExists(variables, "errors")>  _gaq.push(['_trackPageview']);
		        <cfoutput>
		        <p><b>Error: #variables.errors#</b></p>
		        </cfoutput>
		    </cfif>

		    <cfset metadata = getMetadata(data)>
		    <cfset colList = "">
		    <cfloop index="col" array="#metadata#">
		        <cfset colList = listAppend(colList, col.name)>
				<cfif left(col.name, 3) NEQ  "col">
					<cfset parseResults.uniqueColList = listAppend(parseResults.uniqueColList, "#col.name#")>
				<cfelse>
				</cfif>
		    </cfloop>

		   <cfif data.recordCount is 1>
		        <p>This spreadsheet appeared to have no data.</p>
		    <cfelse>

		            <cfoutput query="data" startRow="2">
						<cfset itemStruct = structNew()>
						<!--- Create Structure Variables --->
		                <cfloop index="c" list="#colList#">
							<cfif len(data[c][currentRow]) GT 0>
								<cfset itemStruct["#c#"] = #data[c][currentRow]#>
							</cfif>
		                </cfloop>

		              	<!--- Append Struct to parsed result array --->
						<cfset arrayAppend(parseResults.spreadRows, itemStruct)>
		            </cfoutput>
		    </cfif>

		<cfset parseResults.initialCount = arrayLen(parseResults.spreadRows)>


		<!--- loop each item imported --->
		<cfloop from="1" to="#arrayLen(parseResults.spreadRows)#" index="i">

			<!---If Model Number exists --->
			<cfif structKeyExists(parseResults.spreadRows[i], "MODEL NUMBER")>
			<!--- Create Notes String --->
			<cfset notes = "">
			<cfloop collection=#parseResults.spreadRows[i]# item="dataColumn">
		        <cfif dataColumn contains "col">
		        	<cfset notes = listAppend(notes, #dataColumn#)>
		        </cfif>
		    </cfloop>

			<!--- Check if Tags Name Exist for Manu or category ---->
			<cfset addTagList = "">

			<!--- if manu is defined --->
			<cfif structKeyExists(parseResults.spreadRows[i], "MANU")>
				<cfset variables.manu = parseResults.spreadRows[i]['MANU']>
				<cfinvoke component="inventory" method="checkTagName" returnVariable="tagResult">
					<cfinvokeargument name="name" value="#parseResults.spreadRows[i]['MANU']#">
				</cfinvoke>
				<!--- Create tag if doesnt exist --->
				<cfif tagResult.recordCount EQ 0>
					<cfinvoke component="inventory" method="createStockTag" returnVariable="tagResult">
						<cfinvokeargument name="Name" value="#parseResults.spreadRows[i]['MANU']#">
						<cfinvokeargument name="userID" value="#arguments.userID#">
						<cfinvokeargument name="description" value="">
					</cfinvoke>
					<cfset tagID = tagResult.tagID>
				<cfelse>
					<cfset tagID = tagResult.tagID>
				</cfif>
				<cfif !listContains(addTagList, tagID)>
				 <cfset addTagList = listAppend(addTagList, tagID)>
				</cfif>
			</cfif>
			<!--- Append Tag to Tag List --->

			<!--- if cat is defined --->
			<cfif structKeyExists(parseResults.spreadRows[i], "CAT.")>
				<cfset variables.cat = parseResults.spreadRows[i]['CAT.']>
				<cfinvoke component="inventory" method="checkTagName" returnVariable="tagResult">
					<cfinvokeargument name="name" value="#parseResults.spreadRows[i]['CAT.']#">
				</cfinvoke>
				<!--- Create tag if doesnt exist --->
				<cfif tagResult.recordCount EQ 0>
					<cfinvoke component="inventory" method="createStockTag" returnVariable="tagResult">
						<cfinvokeargument name="Name" value="#parseResults.spreadRows[i]['CAT.']#">
						<cfinvokeargument name="userID" value="#arguments.userID#">
						<cfinvokeargument name="description" value="">
					</cfinvoke>
					<cfset tagID = tagResult.tagID>
				<cfelse>
					<cfset tagID = tagResult.tagID>
				</cfif>
				<!--- Append Tag to Tag List --->
				<cfif !listContains(addTagList, tagID)>
					<cfset addTagList = listAppend(addTagList, tagID)>
				</cfif>
			</cfif>

			<!--- Set weight --->
			<cfif structKeyExists(parseResults.spreadRows[i], "WHT") and isNumeric(parseResults.spreadRows[i]['WHT'])>
				<cfset variables.weight = parseResults.spreadRows[i]['WHT']>
			<cfelse>
				<cfset variables.weight = 0>
			</cfif>

			<!--- set case qty --->
			<cfif structKeyExists(parseResults.spreadRows[i], "CSE QTY") and isNumeric(parseResults.spreadRows[i]['CSE QTY'])>
				<cfset variables.caseQty = parseResults.spreadRows[i]['CSE QTY']>
			<cfelse>
				<cfset variables.caseQty = 1>
			</cfif>

			<!--- Set Date --->
			<cfif structKeyExists(parseResults.spreadRows[i], "DATE")>
				<cfset variables.date = parseResults.spreadRows[i]['DATE']>
			<cfelse>
				<cfset variables.date = now()>
			</cfif>

			<!--- Set Stk Qty --->
			<cfif structKeyExists(parseResults.spreadRows[i], "STK") and isNumeric(parseResults.spreadRows[i]['STK'])>
				<cfset variables.stk = parseResults.spreadRows[i]['STK']>
			<cfelse>
				<cfset variables.stk = 1>
			</cfif>


			<!--- Set Descr --->
			<cfif structKeyExists(parseResults.spreadRows[i], "DESCRIPTION")>
				<cfset variables.description = parseResults.spreadRows[i]['DESCRIPTION']>
			<cfelse>
				<cfset variables.description = "">
			</cfif>

			<!--- Add Item To Stock Inventory --->
			<cfinvoke component="inventory" method="addStockItem" returnVariable="addResult">
				<cfinvokeargument name="locationID" value="#arguments.stockLocation#">
				<cfinvokeargument name="modelNo" value="#parseResults.spreadRows[i]['MODEL NUMBER']#">
				<cfinvokeargument name="color" value="">
				<cfinvokeargument name="description" value="#variables.description#">
				<cfinvokeargument name="stockCount" value="#variables.stk#">
				<cfinvokeargument name="weight" value="#variables.weight#">
				<cfinvokeargument name="caseCount" value="#variables.caseQty#">
				<cfinvokeargument name="notes" value="#notes#">
				<cfinvokeargument name="userID" value="#arguments.userID#">
				<cfinvokeargument name="stockDate" value="#variables.date#">
				<cfinvokeargument name="tagList" value="#addTagList#">
			</cfinvoke>

			<!--- Add Created Stock ID's to List to create Database Record of Import --->
			<cfset parseResults.importCount = parseResults.importCount + 1>
			<cfset parseResults.importedIDs = listAppend(parseResults.importedIDs, addResult.stockID)>

			<!--- If no model Number column in this row, log row number to error row list --->
			<cfelse>

			</cfif>
		</cfloop>


		<!--- Log SpreadSheet Bulk Upload For Easy Removal if something Fucked Up --->
		<cfquery name="insertUploadLog" datasource="inventory">
			insert into stock_uploads
			(uploadDate, uploadedBy, uploadedIDs)
			values
			(
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#parseResults.importedIDs#">
			)
		</cfquery>

		<cfreturn parseResults>
	</cffunction>


	<!--- Revert Upload Import --->
	<cffunction name="revertUploadImport" access="remote" hint="Removes all inserted Model Numbers from a SpreadSheet Upload">
		<cfargument name="uploadID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">


		<cfquery name="getUploadINfo" datasource="inventory">
			select * from stock_uploads
			where uploadID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadID#">
		</cfquery>

		<!--- Loop each Uploaded ID and remove it from DB --->
		<cfloop list="#getUploadINfo.uploadIDs#" index="i">

			<!--- Hit Remove Function --->
			<cfinvoke component="inventory" method="deleteStockItem">
				<cfinvokeargument name="stockID" value="#i#">
				<cfinvokeargument name="userID" value="#arguments.userID#">
			</cfinvoke>

		</cfloop>

		<cfset message = "Removed #listLen(getUploadINfo.uploadIDs)# Imported Stock Items from UploadID: #arguments.uploadID#">

		<cfreturn message>
	</cffunction>




<!----

	Tag Functions

---->

	<!--- Create Stock Tag ---->
	<cffunction name="createStockTag" access="remote" hint="creates stock list tag for grouping stock products">
		<cfargument name="Name" type="string" required="true" hint="Name of Tag to create">
		<cfargument name="Description" type="string" required='true' hint="Description of tag to create">
		<cfargument name="userID" type="numeric" hint="UserID creating tag" required="true">


		<!--- Check that Tag Name doesnt exist already --->
		<cfquery name="checkTags" datasource="inventory">
			select tagName
			from stock_tags
			where tagName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Name#">
		</cfquery>
		<cfset returnStruct = structNew()>
		<!--- If not, create record --->
		<cfif checkTags.recordCount EQ 0>

			<cfquery name="insertTag" datasource="inventory" result="tag">
				insert into stock_tags
				(
				tagName,
				tagDescription,
				createdBy,
				createDate
				)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Name#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>

			<!--- Set Return Vars --->
			<cfset returnStruct.Name = arguments.name>
			<cfset returnstruct.tagID = tag.generated_key>
			<cfset returnstruct.description = arguments.description>
			<cfset returnStruct.message = "Tag Created Successfully">
		<!--- If we already have tag, return error --->
		<cfelse>
			<cfset returnStruct.message = "Tag Already Exists">

		</cfif>

			<!--- Return Structure --->
			<cfreturn returnStruct>
	</cffunction>


	<!--- Delete Stock Tag --->
	<cffunction name="deleteStockTag" access="remote" hint="Removes Stock Tag from database">
		<cfargument name="tagID" required="true" type="numeric" hint="ID of tag to remove">
		<!--- check tag ID --->
		<cfquery name="checkID" datasource="inventory">
			select * from stock_tags
			where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
		</cfquery>

		<!--- if tag ID exists, delete --->
		<cfif checkID.recordCount NEQ 0>

			<!--- Delete Main Tag ---->
			<cfquery name="deleteTag" datasource="inventory">
				delete from stock_tags
				where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
			</cfquery>
			<!--- Delete Tag Links --->
			<cfquery name="deleteLinks" datasource="inventory">
				delete from stock_tags_links
				where stockTagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tagID#">
			</cfquery>
			<cfset message = "Removed tag: #checkID.name# and all model references to it">
		<cfelse>
			<cfset message = "Tag ID is invalid">
		</cfif>
		<cfreturn message>
	</cffunction>



	<!--- Rename Stock Tag --->
	<cffunction name="renameStockTag" access="remote" hint="rename a stock tag">
		<cfargument name="stockTagID" type="numeric" required="true">
		<cfargument name="newName" type="string" required="true">


		<!--- Check that new name doesnt exist already --->
		<cfquery name="checkName" datasource="inventory">
			select * from stock_tags
			where tagName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newName#">
		</cfquery>

		<!--- if new name doesnt exist already --->
		<cfif checkName.recordCount EQ 0>
			<cfquery name="updateTagName" datasource="inventory">
				update stock_tags
				set tagName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newName#">
				where tagId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockTagID#">
			</cfquery>

			<cfset message = "Updated Tag Name">
		<cfelse>
			<cfset message = "Failed: cannot rename tag, tag already exists with that name.">
		</cfif>
		<cfreturn message>
	</cffunction>

	<!--- Create Tag to Item Link --->
	<cffunction name="createTagItemLink" access="remote" hint="Creates a link between a stocked item and a stock tag">
		<cfargument name="stockItemID" required="true" type="numeric" hint="stockItem to link to tag">
		<cfargument name="stockTagID" required="true" type="numeric" hint="tagID to link stock item to">
		<cfargument name="userID" required="true" type="numeric" hint="userID creating link">

		<!--- Check that stock tag is legit --->
		<cfquery name="checkStockTag" datasource="inventory">
			select * from stock_tags
			where tagID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stocktagID#">
		</cfquery>

		<!--- Check that stock item is legit --->
		<cfquery name="checkStockItem" datasource="inventory">
			select * from stock_items
			where stockID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockItemID#">
		</cfquery>

		<!--- if both Id's are valid --->
		<cfif checkStockItem.recordCount NEQ 0 and checkStockTag.recordCount NEQ 0>

			<!--- Create link --->
			<cfquery name="createStockTagLink" datasource="inventory">
				insert into stock_tags_links
				(
				stockTagID,
				stockItemID,
				linkedBy,
				created
				)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stocktagID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockItemID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>

			<cfset message = "Created Stock Item and Tag Link Between StockID: #arguments.stockItemID# and tagID: #arguments.stockTagID#">
		<cfelse>
			<cfset message = "Unable to create Link due to Invalid ID's">
		</cfif>
		<cfreturn message>
	</cffunction>

	<!--- Delete Tag to Item Link --->
	<cffunction name="deleteTagItemLink" access="remote" hint="Deletes Link between stock item and stock tag">
		<cfargument name="stockLinkID" required="true" type="numeric" hint="link ID to remove">

		<cfquery name="removeID" datasource="inventory">
			delete from stock_tags_links
			where stockLinkID = <Cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockLinkID#">
		</cfquery>

	</cffunction>


	<!--- Check Tag name ---->
	<cffunction name="checkTagName" access="remote" hint="checks if tag name exists in db">
		<cfargument name="name" required="true" type="string" hint="name of tag to check">

		<cfquery name="checkTag" datasource="inventory">
			select * from stock_tags
			where tagName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
		</cfquery>

		<cfreturn checkTag>
	</cffunction>


<!----

	Stock Location Functions

---->


	<!--- Create Stock Location --->
	<cffunction name="createStockLocation" access="remote" hint="Creates a Stock Location record in database">
		<cfargument name="description" type="string" default="">
		<cfargument name="gps" type="string" default="">
		<cfargument name="name" type="string" required="true">


		<!--- Check that Location doesnt already exist --->
		 <cfquery name="checkLocs" datasource="inventory">
		 	 select * from stock_locations
			  where locationName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Name#">,
		 </cfquery>
		 <cfset returnStruct = structNew()>
		<!---- If not, insert --->
		<cfif checkLocs.recordCount EQ 0>

			<cfquery name="insertLocation" datasource="inventory" result="location">
				insert into stock_locations
				(locationDescription,
				gps,
				dateAdded,
				locationName
				)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.gps#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Name#">
				)
			</cfquery>
			<!--- Set Return Vars --->
			<cfset returnStruct.Name = arguments.name>
			<cfset returnstruct.locationID = location.generated_key>
			<cfset returnstruct.description = arguments.description>
			<cfset returnStruct.message = "location Created Successfully">
		<cfelse>
			<cfset returnStruct.message = "Location Already Exists">

		</cfif>

		<!--- Return Structure --->
		<cfreturn returnStruct>
	</cffunction>


	<!--- Delete Stock Location ---->
	<cffunction name="deleteStockLocation" access="remote" hint="Removes a stock location and all items associated with it">
		<cfargument name="stockLocationID" required="true" type="numeric" hint="location ID of stock facility to remove">

		<cfquery name="checkID" datasource="inventory">
			select * from stock_locations
			where stockLocationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockLocationID#">
		</cfquery>
		<cfif checkId.recordCount NEQ 0>
			<cfquery name="deleteID" datasource="inventory">
				delete from stock_locations
				where stockLocationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockLocationID#">
			</cfquery>
			<cfset message = "Deleted Stock Location">
		<cfelse>
			<cfset message = "StockID doesnt Exist in database">
		</cfif>
		<cfreturn message>
	</cffunction>

	<!--- Update Stock Location Info --->
	<cffunction name="updateStockLocation" access="remote" hint="updates information about a stocking facility">
		<cfargument name="stockLocationID" required="true" type="numeric" hint="location ID to update">
		<cfargument name="description" required="true" type="string">
		<cfargument name="name" required="true"	 type="string">
		<cfargument name="gps" type="string" default="">

		<!--- check locationID ---->
		<cfquery name="checkID" datasource="inventory">
			select * from stock_locations
			where stockLocationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockLocationID#">
		</cfquery>

		<cfif checkID.recordCount NEQ 0>
			<!--- Update INfo --->
			<cfquery name="updateLocationInfo" datasource="inventory">
				update stock_locations
				set locationDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#">,
					gps = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.gps#"> ,
					locationName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
				where stockLocationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stockLocationID#">
			</cfquery>
			<cfset message = "Updated Stock Location Information">
		<cfelse>
			<cfset message = "Invalid Location ID">
		</cfif>
		<cfreturn message>
	</cffunction>


	<!--- Get Stock Locations --->
	<cffunction name="getStockLocations" access="remote" hint="Returns Query of Stock Locations">
		<cfquery name="getStockLocations" datasource="inventory">
			select * from stock_location
		</cfquery>
		<cfreturn getStockLocations>
	</cffunction>




<!----

	Statistic Functions


---->











</cfcomponent>
