<!---
	Pallet Calculator CFC

	Attempted to create a way to calculate the number of pallets based on the volume/weight of the shipment. This however is not consistant

	Someone may be able to improve on this concept.
	Written in 2012
--->
<cfcomponent>


	<!---
		get number of pallets for a shopping cart
			- Returns Pallet Structure array
		 --->
	<cffunction name="getNumPallets" access="remote" hint="gets number of pallets required for a online shopping cart">
		<cfargument name="cartID" required="true" type="string" hint="Customers Shopping Cart Unique ID">

		<!--- Fetch Array of Items you want to ship [Based on Internal Business Logic of how your products are stored] --->
		<cfinvoke component="cfc.freight" method="getCartShippingStructure" returnVariable="items">
			<cfinvokeargument name="cartID" value="#arguments.cartID#">
		</cfinvoke>

		<h2>Freight Cart Tester</h2>
		<p>CartID : <cfoutput>#arguments.cartID#</cfoutput></p>
		<p>Cart Contents</p>
		<table>
			<thead>
				<tr>
					<th style="text-align:left; width:300px;">Product</th>
					<th style="text-align:left; width:100px;">Qty</th>
					<th>Stackable</th>
				</tr>
			</thead>
		<tbody>
		<cfloop from="1" to="#arrayLen(items)#" index="x">
			<cfoutput>
			<tr>
				<td>#items[x].partClassName# <br />
					#items[x].model#</td>
				<td>#items[x].qty#</td>
				<td>#items[x].stackable#</td>
			</tr>
			</cfoutput>
		</cfloop>
		</tbody>
		</table>


		<br />
		<br />
		<cfset freightClasses = arrayNew(1)>
		<cfset palletArray = arrayNew(1)>
		<cfset numPallets = 1>

		<cfset physicalPalletHeight = 4>
		<cfset maxHeight = 96>
		<cfset maxPalletHeight = maxHeight - physicalPalletHeight>
		<cfset maxPalletLength = 40>
		<cfset maxPalletWidth = 48>
		<cfset maxCuFeet = maxPalletLength * maxPalletWidth * maxPalletHeight>

		<!--- default pallet dimensions, applies if product doesnt have dimensions in database --->
		<cfset defaultPalletLength = 40>
		<cfset defaultPalletWidth = 48>
		<cfset defaultPalletHeight = 60>

		<!--- create first pallet structure
			- PltNo - Pallet Number
			- PltCuFeet - Cubic Feet of items on pallet
			- PltCuInches - Cubic Inches of items on pallet
			- itemsOnPallet - Theoretical Items on Pallet
			- freightClass - Freight class that pallet is shipped
			- pltHeight - height of items stacked
			- pltDim - Dimensions of pallet (40 * 48 * PltHeight)
			- pctOccupied - Percentage of space occupied
			- remCuFt - Remaining Cubic Ft.
			- remCuIn - Remaining Cubic In.
			- note - info about pallet, if created because of invalid dimensions or unstackable product, indicate.
			--->

		<cfset pallet = structNew()>
		<cfset pallet.pltNo = 1>
		<cfset pallet.pltCuFeet = 0>
		<cfset pallet.itemsOnPallet = arrayNew(1)>
		<cfset pallet.freightClass = "">
		<cfset pallet.pltHeight = 4>
		<cfset pallet.pkgCount = 0>
		<cfset pallet.pltDim = "40 X 48 X #pallet.pltHeight#" />
		<cfset pallet.pctOcc = 0>
		<cfset pallet.errorCode = "201">
		<cfset pallet.totalWeight = 0>
		<cfset pallet.FOBID = "">
		<cfset pallet.remCuFt = maxCuFeet>
		<cfset pallet.note = "Default Pallet">
		<cfset arrayAppend(palletArray, pallet)>

		<!--- loop items in cart --->
		<Cfloop from="1" to="#arrayLen(items)#" index="i">
			<!--- create array of freight classes --->
			<cfset arrayitem = items[i].freightClass>
			<cfif !arrayContains(freightClasses, arrayItem)>
				<cfset arrayAppend(freightClasses, arrayItem)>
			</cfif>
			<cfset packageCuFt = items[i].length * items[i].width * items[i].height>
			<cfif !isdefined("biggestPackage")>
				<cfset biggestPackage = packageCuFt>
			<cfelse>
				<!--- reorder products array by package size --->
				<cfif packageCuFt GT biggestPackage>
					<cfset newPkgStruct = StructCopy(items[i])>
					<cfset biggestPackage = packageCuFt>
					<cfset ArraydeleteAt(items, i)>
					<cfset ArrayInsertAt(items, 1, newPkgStruct)>
				</cfif>
			</cfif>
		</cfloop>

		<cfset remainingPalletSpace = maxCuFeet>
		<cfset packageNumber = 0>

		<!--- loop each freight class --->
		<cfloop from="1" to="#arrayLen(freightClasses)#" index="i">
		<!--- create array of freight classes --->
			<cfset arrayitem = items[i].freightClass>
			<cfif !arrayContains(freightClasses, arrayItem)>
				<cfset arrayAppend(freightClasses, arrayItem)>
			</cfif>
			<cfset packageCuFt = items[i].length * items[i].width * items[i].height>
			<cfif !isdefined("biggestPackage")>
				<cfset biggestPackage = packageCuFt>
			<cfelse>
				<!--- reorder products array by package size --->
				<cfif packageCuFt GT biggestPackage>
					<cfset newPkgStruct = StructCopy(items[i])>
					<cfset biggestPackage = packageCuFt>
					<cfset ArraydeleteAt(items, i)>
					<cfset ArrayInsertAt(items, 1, newPkgStruct)>
				</cfif>
			</cfif>
		</cfloop>


		<cfset remainingPalletSpace = maxCuFeet>
		<cfset packageNumber = 0>

		<!--- loop each freight class --->
		<cfloop from="1" to="#arrayLen(freightClasses)#" index="i">

			<!--- loop each item in cart array --->
			<Cfloop from="1" to="#arrayLen(items)#" index="x">
				<cfset item = structFind(items[x], "freightClass")>

				<!--- if freight class matches array value --->
				<cfif item EQ freightClasses[i]>
					<cfdump var="Pkg #x#.  Freight Class #item#">
					<!--- we now are working with all products in the cart structure that share the same freight class (freightClass[i])  --->
					<cfset product = items[x]>
					<cfset thisItemPackages = items[x].qty / items[x].maxPkgQty>

					<!--- total up freightClass Weight --->
					<cfif !isdefined("totalClassWeight")>
						<cfset totalClassWeight = items[x].productWeight>
					<cfelse>
						<cfset totalClassWeight = totalClassWeight + items[x].productWeight>
					</cfif>
					<!--- if stackable --->
					<cfif items[x].stackable EQ "true">
							<!--- if values are numic calculate package cu ft --->
							<cfif isNumeric(items[x].length) and isNumeric(items[x].width) and isNumeric(items[x].height)>
							<!--- account for shrink wrap and free space --->
								<cfset packageEstLength = items[x].length + 2>
								<cfset packageEstWidth = items[x].width + 2>
								<cfset packageEstHeight = items[x].height + 2>
								<cfset packageCuFeet = packageEstLength * packageEstWidth * packageEstHeight>
							<cfelse>
							<!--- if we values arent numeric, item gets its own pallet --->
								<cfset pallet = structNew()>
								<cfset pallet.pltNo = #arrayLen(palletArray)# + 1>
								<cfset pallet.pltHeight = 65>
								<cfset pallet.pltCuFeet = 40 * 48 * 65>
								<cfset pallet.pkgCount = 1>
								<cfset pallet.itemsOnPallet = arrayNew(1)>
								<cfset pallet.itemsOnPallet[1] = items[x].model>
								<cfset pallet.itemsOnPallet[2] = 1>
								<cfset pallet.totalWeight = items[x].productWeight + 40>
								<cfset pallet.freightClass = freightClass[i]>
								<cfset pallet.pltDim = "40 X 48 X #pallet.pltHeight#" />
								<cfset pallet.remCuFt = maxCuFeet - pallet.pltCuFeet>
								<cfset pallet.pctOcc = (pallet.pltCuFeet / maxCuFeet) * 100>
								<cfset pallet.errorCode = "NPD">
								<cfset pallet.note = "NPD: No Package Dimensions, Item treated as full pallet">
								<cfset arrayAppend(palletArray, pallet)>
							</cfif>

						<!--- get product weight --->
							<cfset packageWeight = items[x].productWeight>

							<!--- create an array and variable to store pallets that contain this same product --->
							<cfset sameProductLocation = arrayNew(1)>
							<cfset productAlreadyOnPallet = "false">
							<cfset numStackablePallets = 0>

							<!---- Loop Current Pallets--->
							<cfloop from="1" to="#arrayLen(palletArray)#" index="z">
								<cfset palletCurrentItemList =  palletArray[z].pctOcc>

									<!--- get Highest Capacity Pallet and re-order Pallet Array by capacity --->
									<cfif !isDefined("HighestCapacityPallet") and palletArray[z].pctOcc NEQ 100  and palletArray[z].errorCode NEQ "PNS">
										<cfset numStackablePallets = numStackablePallets + 1>
										<!--- set vars and re-order array by capacity --->
										<cfset HighestCapacityPallet = palletArray[z].pctOcc>
										<cfset currentPalletSelection = z>
										<cfset currentPalletStruct = StructCopy(palletArray[z])>
										<cfset ArraydeleteAt(palletArray, z)>
										<cfset ArrayInsertAt(palletArray, 1, currentPalletStruct)>
									<cfelse>
										<cfif highestCapacityPallet GT palletArray[z].pctOcc and palletArray[z].pctOcc NEQ 100 and palletArray[z].errorCode NEQ "PNS">
											<cfset numStackablePallets = numStackablePallets + 1>
											<cfset highestCapacityPallet>
											<cfset currentPalletSelection = z>
											<cfset currentPalletStruct = StructCopy(palletArray[z])>
											<cfset ArraydeleteAt(palletArray, z)>
											<cfset ArrayInsertAt(palletArray, 1, currentPalletStruct)>
										</cfif>
									</cfif>

									<!--- check if pallet already contains the same item, if true, add to same product pallet array --->
									<cfloop from="1" to="#arrayLen(palletArray[z].itemsOnPallet)#" index="p">
										<cfif palletArray[z].itemsOnPallet[p].model EQ items[x].model>
												<Cfdump var="Pallet #z# contains #items[x].model#">
												<cfset arrayAppend(sameProductLocation, z)>
										</cfif>
									</cfloop>

									<!--- check if package can fit on remaining pallets --->


							</cfloop>


								<!--- loop through same product array --->
								<cfif arrayLen(sameProductLocation) GT 0>
									<cfloop from="1" to="#arrayLen(sameProductLocation)#" index="o">
										<cfset currentPalletselection = palletArray["#sameProductLocation[o]#"]>
										<cfdump var="#currentPalletSelection#">
										<!--- if package cu feet appears that it will fit --->
										<cfif packageCuFeet LTE currentPalletSelection.remCuFt>
												<cfset variables.placed = "true">
												<cfset currentPalletselection.pltCuFeet = currentPalletselection.pltCuFeet + packageCuFeet>
												<cfset currentPalletSelection.pkgCount = currentPalletSelection.pkgCount + 1>
												<cfset addedItemArray = "false">
												<cfloop from="1" to="#arrayLen(currentPalletselection.itemsOnPallet)#" index="p">
													<cfif StructKeyExists(currentPalletselection.itemsOnPallet[p], "model")>
														<cfset currentPalletselection.itemsOnPallet[p].qty = currentPalletselection.itemsOnPallet[p].qty + 1>
														<cfset addedItemArray = "true">
													</cfif>
												</cfloop>
												<cfif addedItemArray EQ "false">
													<cfset itemOnPalletStruct = structNew()>
													<cfset itemOnPalletStruct.model = #items[x].model#>
													<cfset itemOnpalletStruct.qty = 1>
													<cfset arrayAppend(currentPalletselection.itemsOnPallet, itemOnPalletStruct)>
												</cfif>

												<cfset currentPalletselection.remCuFt = currentPalletselection.remCuFt - packageCuFeet>
												<cfset currentPalletselection.pctOcc = (currentPalletselection.pltCuFeet / maxCuFeet) * 100>
												<cfset currentPalletselection.totalWeight = currentPalletselection.totalWeight + packageWeight>
										</cfif>
									</cfloop>
								</cfif>

							<!---If product is not placed, Loop through remaining pallets --->
							<cfif !isdefined("variables.placed")>

								<cfloop from="1" to="#items[x].estNumPkgs#" index="l">

									<cfloop from="1" to="#arrayLen(palletArray)#" index="z">
											<cfset currentPalletselection = palletArray[z]>
											<cfset addedItemArray = "false">
											<!--- if package cu feet appears that it will fit --->

											<cfif packageCuFeet LTE currentPalletSelection.remCuFt and !isDefined("variables.placed") and currentPalletselection.errorCode NEQ "PNS">

													<cfset currentPalletselection.pltCuFeet = currentPalletselection.pltCuFeet + packageCuFeet>
													<cfset currentPalletSelection.pkgCount = currentPalletSelection.pkgCount + 1>

													<cfloop from="1" to="#arrayLen(currentPalletselection.itemsOnPallet)#" index="p">
														<cfif StructKeyExists(currentPalletselection.itemsOnPallet[p], "model")>
															<cfset currentPalletselection.itemsOnPallet[p].qty = currentPalletselection.itemsOnPallet[p].qty + 1>
															<cfset addedItemArray = "true">
														</cfif>
													</cfloop>
													<cfif addedItemArray EQ "false">
														<cfset itemOnPalletStruct = structNew()>
														<cfset itemOnPalletStruct.model = #items[x].model#>
														<cfset itemOnpalletStruct.qty = 1>
														<cfset arrayAppend(currentPalletselection.itemsOnPallet, itemOnPalletStruct)>
													</cfif>
													<cfset currentPalletselection.remCuFt = currentPalletselection.remCuFt - packageCuFeet>
													<cfset currentPalletselection.pctOcc = (currentPalletselection.pltCuFeet / maxCuFeet) * 100>
													<cfset currentPalletselection.totalWeight = currentPalletselection.totalWeight + packageWeight>

											</cfif>
									</cfloop>

									<cfif isDefined("variables.placed")>
										<cfdump var="#variables.placed#">
										<cfset structDelete(variables, placed)>
									</cfif>

								</cfloop>
							</cfif>

					<!--- if not stackable --->
					<cfelse>
					<!--- Loop for each package required for this item, item requires its own pallet, so
						add to number of pallets --->
						<cfloop from="1" to="#thisItemPackages#" index="y">
							<cfset numPallets = numPallets + 1>
							<!--- create pallet structure --->
								<cfset pallet = structNew()>
								<cfset pallet.pltNo = #arrayLen(palletArray)# + 1>
								<cfset pallet.pltHeight = 4 + items[x].height>
								<cfset pallet.pltCuFeet = 40 * 48 * pallet.pltHeight>
								<cfset pallet.itemsOnPallet = items[x].model>
								<cfset pallet.freightClass = freightClasses[i]>
								<cfset pallet.itemsOnPallet = arrayNew(1)>
								<cfset pallet.estNumPkgs = 1>
								<cfset itemOnPalletStruct = structNew()>
								<cfset itemOnPalletStruct.model = #items[x].model#>
								<cfset itemOnpalletStruct.qty = 1>
								<cfset arrayAppend(pallet.itemsOnPallet, itemOnPalletStruct)>
								<cfset pallet.pltDim = "40 X 48 X #pallet.pltHeight#" />
								<cfset pallet.pctOcc = (pallet.pltCuFeet / maxCuFeet) * 100>
								<cfset pallet.remCuFt = maxCuFeet - pallet.pltCuFeet>
								<cfset pallet.errorCode = "PNS">
								<cfset pallet.note = "PNS: Product not stackable, pallet added">
								<cfset arrayAppend(palletArray, pallet)>
						</cfloop>
					</cfif>
				<cfdump var="#product#">
				<!--- if last row of items, at this point we have the total dimensions and weight for this freight class --->
				<cfif x EQ arrayLen(items)>
					<cfoutput>
					<h2>Num Pallets Needed for class #freightClasses[i]#: #numPallets#</h2>
					<cfdump var="#palletArray#">

					</cfoutput>
				</cfif>
			</cfif>

				<!--- reset loop vars --->
				<cfif isDefined("variables.placed")>
					<cfdump var="#variables.placed#">
					<cfset structDelete(variables, placed)>
				</cfif>
			</cfloop>
		</cfloop>

	</cffunction>



















	<!--- get number of pallets --->
	<cffunction name="getNumPalletsAdv" access="remote" hint="gets number of pallets required for a structure">
		<cfargument name="cartID" required="true" type="string">

		<!--- call shipping structure array function --->
		<cfinvoke component="cfc.freight" method="getCartShippingStructure" returnVariable="items">
			<cfinvokeargument name="cartID" value="#arguments.cartID#">
		</cfinvoke>

		<cfset freightClasses = arrayNew(1)>
		<cfset palletArray = arrayNew(1)>
		<cfset numPallets = 1>

		<cfset physicalPalletHeight = 4>
		<cfset maxHeight = 96>
		<cfset maxPalletHeight = maxHeight - physicalPalletHeight>
		<cfset maxPalletLength = 40>
		<cfset maxPalletWidth = 48>
		<cfset maxCuFeet = maxPalletLength * maxPalletWidth * maxPalletHeight>

		<!--- default pallet dimensions, applies if product doesnt have dimensions in database --->
		<cfset defaultPalletLength = 40>
		<cfset defaultPalletWidth = 48>
		<cfset defaultPalletHeight = 60>

		<!--- create first pallet structure
			- PltNo - Pallet Number
			- PltCuFeet - Cubic Feet of items on pallet
			- itemsOnPallet - Theoretical Items on Pallet
			- freightClass - Freight class that pallet is shipped
			- pltHeight - height of items stacked
			- pltDim - Dimensions of pallet (40 * 48 * PltHeight)
			- pctOccupied - Percentage of space occupied
			- remCuFt - Remaining Cubic Ft.
			- note - info about pallet, if created because of invalid dimensions or unstackable product, indicate.
			--->
		<cfset pallet = structNew()>
		<cfset pallet.pltNo = 1>
		<cfset pallet.pltCuFeet = 0>
		<cfset pallet.itemsOnPallet = 0>
		<cfset pallet.freightClass = "">
		<cfset pallet.pltHeight = 4>
		<cfset pallet.pltDim = "40 X 48 X #pallet.pltHeight#" />
		<cfset pallet.pctOcc = 0>
		<cfset pallet.errorCode = "">
		<cfset pallet.totalWeight = 0>
		<cfset pallet.FOBID = "">
		<cfset pallet.remCuFt = maxCuFeet>
		<cfset pallet.note = "Default Pallet">
		<cfset arrayAppend(palletArray, pallet)>

		<!--- loop items in cart --->
		<Cfloop from="1" to="#arrayLen(items)#" index="i">
			<!--- create array of freight classes --->
			<cfset arrayitem = items[i].freightClass>
			<cfif !arrayContains(freightClasses, arrayItem)>
				<cfset arrayAppend(freightClasses, arrayItem)>
			</cfif>
			<cfset packageCuFt = items[i].length * items[i].width * items[i].height>
			<cfif !isdefined("biggestPackage")>
				<cfset biggestPackage = packageCuFt>
			<cfelse>
				<!--- reorder products array by package size --->
				<cfif packageCuFt GT biggestPackage>
					<cfset newPkgStruct = StructCopy(items[i])>
					<cfset biggestPackage = packageCuFt>
					<cfset ArraydeleteAt(items, i)>
					<cfset ArrayInsertAt(items, 1, newPkgStruct)>
				</cfif>
			</cfif>
		</cfloop>

		<cfset remainingPalletSpace = maxCuFeet>
		<cfset packageNumber = 0>

		<!--- loop each freight class --->
		<cfloop from="1" to="#arrayLen(freightClasses)#" index="i">

			<!--- loop each item in cart array --->
			<Cfloop from="1" to="#arrayLen(items)#" index="x">
				<cfset item = structFind(items[x], "freightClass")>

				<!--- if freight class matches array value --->
				<cfif item EQ freightClasses[i]>
					<cfdump var="Pkg #x#.  Freight Class #item#">
					<!--- we now are working with all products in the cart structure that share the same freight class (freightClass[i])  --->
					<cfset product = items[x]>
					<cfset thisItemPackages = items[x].qty / items[x].maxPkgQty>

					<!--- total up freightClass Weight --->
					<cfif !isdefined("totalClassWeight")>
						<cfset totalClassWeight = items[x].productWeight>
					<cfelse>
						<cfset totalClassWeight = totalClassWeight + items[x].productWeight>
					</cfif>

					<!--- if stackable --->
					<cfif items[x].stackable EQ "true">
						<!--- Loop for each package required for this item --->
						<cfloop from="1" to="#thisItemPackages#" index="y">

							<!--- if values are numic calculate package square ft --->
							<cfif isNumeric(items[x].length) and isNumeric(items[x].width) and isNumeric(items[x].height)>
							<!--- account for shrink wrap and free space --->
								<cfset packageEstLength = items[x].length + 2>
								<cfset packageEstWidth = items[x].width + 2>
								<cfset packageEstHeight = items[x].height + 2>
								<cfset packageCuFeet = packageEstLength * packageEstWidth * packageEstHeight>
							<cfelse>
							<!--- if we values arent numeric, item gets its own pallet --->
								<cfset pallet = structNew()>
								<cfset pallet.pltNo = #arrayLen(palletArray)# + 1>
								<cfset pallet.pltHeight = 65>
								<cfset pallet.pltCuFeet = 40 * 48 * 65>
								<cfset pallet.itemsOnPallet = items[x].model>
								<cfset pallet.freightClass = freightClass[i]>
								<cfset pallet.pltDim = "40 X 48 X #pallet.pltHeight#" />
								<cfset pallet.remCuFt = maxCuFeet - pallet.pltCuFeet>
								<cfset pallet.pctOcc = (pallet.pltCuFeet / maxCuFeet) * 100>
								<cfset pallet.errorCode = "NPD">
								<cfset pallet.note = "NPD: No Package Dimensions, Item treated as full pallet">
								<cfset arrayAppend(palletArray, pallet)>
							</cfif>


							<!--- get product weight --->
							<cfset packageWeight = items[x].productWeight>

							<!--- create an array and variable to store pallets that contain this same product --->
							<cfset sameProductLocation = arrayNew(1)>
							<cfset productAlreadyOnPallet = "false">


							<!---- Loop Current Pallets--->
							<cfloop from="1" to="#arrayLen(palletArray)#" index="z">
								<cfset palletCurrentItemList =  palletArray[z].pctOcc>

								<!--- check if pallet already contains the same item,
									if it does, set value and add to same product pallet array --->
									<cfif listContains(palletCurrentItemList, palletArray[z].model)>
										<cfset productAlreadyOnPallet = "true">
										<cfset arrayAppend(sameProductLocation, z)>
									</cfif>

								<!--- get Highest Capacity Pallet and re-order Pallet Array by capacity --->
									<cfif !isDefined("HighestCapacityPallet") and palletArray[z].pctOcc NEQ 100>
										<!--- set vars and re-order array by capacity --->
										<cfset HighestCapacityPallet = palletArray[z].pctOcc>
										<cfset currentPalletSelection = z>
										<cfset currentPalletStruct = StructCopy(palletArray[z])>
										<cfset ArraydeleteAt(palletArray, z)>
										<cfset ArrayInsertAt(palletArray, 1, currentPalletStruct)>
									<cfelse>
										<cfif highestCapacityPallet GT palletArray[z].pctOcc and palletArray[z].pctOcc NEQ 100>
											<cfset highestCapacityPallet>
											<cfset currentPalletSelection = z>
											<cfset currentPalletStruct = StructCopy(palletArray[z])>
											<cfset ArraydeleteAt(palletArray, z)>
											<cfset ArrayInsertAt(palletArray, 1, currentPalletStruct)>
										</cfif>
									</cfif>
							</cfloop>

								<!--- check if same product package will fit on any sameProductLocation Pallets --->




								<!--- if product is not placed, check if product fits on the highest capacity pallets --->



							<cfset remainingPalletSpace = remainingPalletSpace - packageCuFeet>

							<cfif remainingPalletSpace LTE 0>
								<cfset numPallets = numPallets + 1>
								<cfset remainingPalletSpace = maxCuFeet>
							</cfif>

							<ul>
								<cfoutput>
								<li>Pkg Length: #items[x].length#</li>
								<li>Pkg Width: #items[x].width#</li>
								<li>Pkg Height: #items[x].Height#</li>
								<li>Pkg CuFt: #packageCuFeet#</li>
								<li>Pkg Weight: #items[x].productWeight#</li>
								<li>Total Weight: #totalClassWeight#</li>
								</cfoutput>
							</ul>
							<cfset packageNumber = packageNumber + 1>
						</cfloop>

					<!--- if not stackable --->
					<cfelse>
					<!--- Loop for each package required for this item, item requires its own pallet, so
						add to number of pallets --->
						<cfloop from="1" to="#thisItemPackages#" index="y">
							<cfset numPallets = numPallets + 1>
							<!--- create pallet structure --->
								<cfset pallet = structNew()>
								<cfset pallet.pltNo = #arrayLen(palletArray)# + 1>
								<cfset pallet.pltHeight = 4 + items[x].height>
								<cfset pallet.pltCuFeet = 40 * 48 * pallet.pltHeight>
								<cfset pallet.itemsOnPallet = items[x].model>
								<cfset pallet.freightClass = freightClasses[i]>
								<cfset pallet.pltDim = "40 X 48 X #pallet.pltHeight#" />
								<cfset pallet.pctOcc = (pallet.pltCuFeet / maxCuFeet) * 100>
								<cfset pallet.remCuFt = maxCuFeet - pallet.pltCuFeet>
								<cfset pallet.errorCode = "PNS">
								<cfset pallet.note = "PNS: Product not stackable, pallet added">
								<cfset arrayAppend(palletArray, pallet)>
						</cfloop>
					</cfif>
				<cfdump var="#product#">
				<!--- if last row of items, at this point we have the total dimensions and weight for this freight class --->
				<cfif x EQ arrayLen(items)>
					<cfoutput>
					<h2>Num Pallets Needed for class #freightClasses[i]#: #numPallets#</h2>
					</cfoutput>
				</cfif>
			</cfif>

			</cfloop>
		</cfloop>
		<cfdump var="#palletArray#">

		<!--- Return array of pallet structures containing
			- PltNo - Pallet Number
			- PltCuFeet - Cubic Feet of items on pallet
			- itemsOnPallet - Theoretical Items on Pallet
			- pltHeight - height of items stacked
			- pltDimensions - Dimensions of pallet (40 * 48 * PltHeight)
			- pctOccupied - Percentage of space occupied
			- remCuFt - Remaining Cubic Ft.
			--->

	</cffunction>




</cfcomponent>
