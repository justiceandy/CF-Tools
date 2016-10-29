<!--- THis HTML Is Copy Pasta from TSI's website, excuse bad formatting its only to use for session spoofing for future requests --->
<form method="POST" name="ratereq" action="actgetrate.cfm" onSubmit="return validateForm();">
<div align="center">
<table border="0" width="95%">
<input type="hidden" name="shipdate" value="04/17/2013" />
<tr><th align="right"><font color="red"><b>*</b></font>Payment Terms:</th><td align="left"><select size="1" name="vbterms">
<option value="P" selected="selected">Prepaid</option>
<option value="C">Collect</option>
</select></td><!--  ServTypeList = S,T
      UseCoCode    = no  -->
<!--  servtype select 2  -->
<th align="right"><font color="red"><b>*</b></font>Service Type:</th><td align="left" colspan="3"><select name="servtype" size="1"><option value="">-- Please Select --</option><option selected="selected" value="S">NORMAL SERVICE</option><option value="T">TRUCKLOAD</option></select></td>
        </tr>
        <tr valign="bottom">
            <th align="right" valign="bottom"><font color="red"><b>*</b></font>Origin Zip:</th>
            <td align="left">
               <input id="vozip" size="5" name="vozip" value="97020" title="Origin Zip" required="required" onChange="getCity('1');" />
               <a href="javascript:zipLookup('1');"> <img src="/carrierlogistics/images/search.png" border="0" /> Zip Search</a></td>
            <th align="right" valign="bottom">City:</th>
            <td align="left" width="40%">
                <input type="hidden" name="vocity" value=", OR" />
                <div id="cityname1">, OR</div>
                <div id="citysel1" class="hidden"><select name="city1" size="1" onChange="document.ratereq.vocity.value=this.value;"></select></div>
            </td></tr>
        <tr valign="bottom">
            <th align="right" valign="bottom"><font color="red"><b>*</b></font>Destination Zip:</th>
            <td align="left">
                <input id="vdzip" size="5" name="vdzip" value="" title="Destination Zip" required="required" onChange="getCity('2');" />
                <a href="javascript:zipLookup('2');"> <img src="/carrierlogistics/images/search.png" border="0" /> Zip Search</a></td>
            <th align="right" valign="bottom">City:</th>
            <td align="left">
                <input type="hidden" name="vdcity" value=", " />
                <div id="cityname2">, </div>
                <div id="citysel2" class="hidden"><select name="city2" size="1" onChange="document.ratereq.vdcity.value=this.value;"></select></div>
            </td></tr>
<tr><th align="right">Declared Value:</th>
    <td align="left"><input name="declval" size="8" value="0" onBlur="this.value=formatCurrency(this.value);" /></tr>
<tr><td class="center" align="center" colspan="4">
<table align="center">
<tr><th>Pieces<font color="red"><b>*</b></font></th><th>Pallets</th><th>Weight<font color="red"><b>*</b></font></th><th>Class<font color="red"><b>*</b></font></th><th>Length</th><th>Width</th><th>Height</th></tr>
<tr id="line1.1"><td align="center"><input id="wpieces1" name="wpieces[1]" size="2" maxlength="5" value="" required="required" /></td><td align="center"><input id="wpallets1" name="wpallets[1]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight1" name="wweight[1]" size="3" maxlength="6" value="" required="required" /></td><td align="center"><select id="vclass1" name="vclass[1]" size="1" required="required">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength1" size="3" name="wlength[1]" value="" maxlength="3" /></td><td><input id="wwidth1" size="3" name="wwidth[1]" value="" maxlength="3" /></td><td><input id="wheight1" size="3" name="wheight[1]" value="" maxlength="3" /></td></tr>
<tr id="line2.1"><td align="center"><input id="wpieces2" name="wpieces[2]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets2" name="wpallets[2]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight2" name="wweight[2]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass2" name="vclass[2]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength2" size="3" name="wlength[2]" value="" maxlength="3" /></td><td><input id="wwidth2" size="3" name="wwidth[2]" value="" maxlength="3" /></td><td><input id="wheight2" size="3" name="wheight[2]" value="" maxlength="3" /></td></tr>
<tr id="line3.1" style="display:none;visibility:hidden;"><td align="center"><input id="wpieces3" name="wpieces[3]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets3" name="wpallets[3]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight3" name="wweight[3]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass3" name="vclass[3]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength3" size="3" name="wlength[3]" value="" maxlength="3" /></td><td><input id="wwidth3" size="3" name="wwidth[3]" value="" maxlength="3" /></td><td><input id="wheight3" size="3" name="wheight[3]" value="" maxlength="3" /></td></tr>
<tr id="line4.1" style="display:none;visibility:hidden;"><td align="center"><input id="wpieces4" name="wpieces[4]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets4" name="wpallets[4]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight4" name="wweight[4]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass4" name="vclass[4]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength4" size="3" name="wlength[4]" value="" maxlength="3" /></td><td><input id="wwidth4" size="3" name="wwidth[4]" value="" maxlength="3" /></td><td><input id="wheight4" size="3" name="wheight[4]" value="" maxlength="3" /></td></tr>
<tr id="line5.1" style="display:none;visibility:hidden;"><td align="center"><input id="wpieces5" name="wpieces[5]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets5" name="wpallets[5]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight5" name="wweight[5]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass5" name="vclass[5]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength5" size="3" name="wlength[5]" value="" maxlength="3" /></td><td><input id="wwidth5" size="3" name="wwidth[5]" value="" maxlength="3" /></td><td><input id="wheight5" size="3" name="wheight[5]" value="" maxlength="3" /></td></tr>
<tr id="line6.1" style="display:none;visibility:hidden;"><td align="center"><input id="wpieces6" name="wpieces[6]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets6" name="wpallets[6]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight6" name="wweight[6]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass6" name="vclass[6]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength6" size="3" name="wlength[6]" value="" maxlength="3" /></td><td><input id="wwidth6" size="3" name="wwidth[6]" value="" maxlength="3" /></td><td><input id="wheight6" size="3" name="wheight[6]" value="" maxlength="3" /></td></tr>
<tr id="line7.1" style="display:none;visibility:hidden;"><td align="center"><input id="wpieces7" name="wpieces[7]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets7" name="wpallets[7]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight7" name="wweight[7]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass7" name="vclass[7]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength7" size="3" name="wlength[7]" value="" maxlength="3" /></td><td><input id="wwidth7" size="3" name="wwidth[7]" value="" maxlength="3" /></td><td><input id="wheight7" size="3" name="wheight[7]" value="" maxlength="3" /></td></tr>
<tr id="line8.1" style="display:none;visibility:hidden;"><td align="center"><input id="wpieces8" name="wpieces[8]" size="2" maxlength="5" value="" /></td><td align="center"><input id="wpallets8" name="wpallets[8]" size="2" maxlength="3" value="" /></td><td align="center"><input id="wweight8" name="wweight[8]" size="3" maxlength="6" value="" /></td><td align="center"><select id="vclass8" name="vclass[8]" size="1">  <option value=""></option>  <option value="050">50</option>
  <option value="055">55</option>
  <option value="060">60</option>
  <option value="065">65</option>
  <option value="070">70</option>
  <option value="077">77</option>
  <option value="085">85</option>
  <option value="092">92</option>
  <option value="100">100</option>
  <option value="110">110</option>
  <option value="125">125</option>
  <option value="150">150</option>
  <option value="175">175</option>
  <option value="200">200</option>
  <option value="250">250</option>
  <option value="300">300</option>
  <option value="400">400</option>
  <option value="500">500</option>
</select></td><td><input id="wlength8" size="3" name="wlength[8]" value="" maxlength="3" /></td><td><input id="wwidth8" size="3" name="wwidth[8]" value="" maxlength="3" /></td><td><input id="wheight8" size="3" name="wheight[8]" value="" maxlength="3" /></td></tr>
</table>
<table width="100%">
<tr id="addline"><td align="left"><a href="javascript:showRow()"><b>+</b> Add Line Item</a></td></tr>
</table>
Maximum Pallet Dimensions 40"W x 48"L x 96"H<br/>            </td></tr>
        <tr><td colspan="4" align="center">
<fieldset><legend>Accessorials</legend>
<table border="0" width="80%">
<tr><TD ALIGN="LEFT"><input id="APPT" type="checkbox" name="APPT"  /></TD><TD ALIGN="LEFT"><label for="APPT">APPOINTMENT</label></TD>
<TD ALIGN="LEFT"><input id="CONST" type="checkbox" name="CONST"  /></TD><TD ALIGN="LEFT"><label for="CONST">CONSTRUCTION SITE</label></TD>
<TD ALIGN="LEFT"><input id="WACB4" type="checkbox" name="WACB4"  /></TD><TD ALIGN="LEFT"><label for="WACB4">CONTACT RATE DEPT</label></TD>
</tr>
<tr><TD ALIGN="LEFT"><input id="HAZMAT" type="checkbox" name="HAZMAT"  /></TD><TD ALIGN="LEFT"><label for="HAZMAT">Hazardous Materials</label></TD>
<TD ALIGN="LEFT"><input id="INSDEL" type="checkbox" name="INSDEL"  /></TD><TD ALIGN="LEFT"><label for="INSDEL">INSIDE DEL 1ST FLOOR</label></TD>
<TD ALIGN="LEFT"><input id="LIFT" type="checkbox" name="LIFT"  /></TD><TD ALIGN="LEFT"><label for="LIFT">Lift Gate Service</label></TD>
</tr>
<tr><TD ALIGN="LEFT"><input id="LIMITED" type="checkbox" name="LIMITED"  /></TD><TD ALIGN="LEFT"><label for="LIMITED">LIMITED ACCESS</label></TD>
<TD ALIGN="LEFT"><input id="OVER12FT" type="checkbox" name="OVER12FT"  /></TD><TD ALIGN="LEFT"><label for="OVER12FT">OVR-LNGHT 12' - 20</label></TD>
<TD ALIGN="LEFT"><input id="OVER20FT" type="checkbox" name="OVER20FT"  /></TD><TD ALIGN="LEFT"><label for="OVER20FT">OVR-LNGTH 20.01' -28</label></TD>
</tr>
<tr><TD ALIGN="LEFT"><input id="OVER28FT" type="checkbox" name="OVER28FT"  /></TD><TD ALIGN="LEFT"><label for="OVER28FT">OVR-LNGTH EXCEEDS 28</label></TD>
<TD ALIGN="LEFT"><input id="RES" type="checkbox" name="RES"  /></TD><TD ALIGN="LEFT"><label for="RES">RESIDENTIAL DELIVERY</label></TD>
<TD ALIGN="LEFT"><input id="SORT& SE" type="checkbox" name="SORT& SE"  /></TD><TD ALIGN="LEFT"><label for="SORT& SE">SORTING & SEGRAGATING</label></TD>
</tr>
</table></fieldset>
</td></tr>
<tr><td colspan="4"><h2>All quotes are subject to audits which include classifications and weight verification.</td></tr>
        <tr><td class="center" align="center" colspan="2">
            <input id="ratereqsubmit" type="submit" name="BtnAction" value="Get Quote"/></td>
            <td class="center" align="center" colspan="2">
            <input id="startoverbtn" type="button" name="BtnStartOver" value="Start Over"
                   onClick="this.form.method='get';this.form.submit();"/></td>
        </tr>
    </TABLE>
    </div>
    <input type="hidden" name="seskey" value="djiidpqUdcubrndb"/>
    <input type="hidden" name="language" value=""/>
    <input type="hidden" name="nav" value="side"/>
    <input type="hidden" name="ConsZip" value=""/>
    <input type="hidden" name="ConsState" value=""/>
    <input type="hidden" name="ConsCity" value="" />
    <input type="hidden" name="ShipZip" value="97020"/>
    <input type="hidden" name="ShipState" value="OR"/>
    <input type="hidden" name="ShipCity" value="" />
    <input type="hidden" name="DeclValue" value="0"/>
    <input type="hidden" name="ConsCOD" value="0"/>
    <input type="hidden" name="FromMod" value="ratequote"/>
    <input type="hidden" name="carrier" value="" />
    <input type="hidden" name="custno" value="" />
    <input type="hidden" name="qkwords" value="" />
<input type="hidden" name="PcsT" value="0">
<input type="hidden" name="PltT" value="0">
<input type="hidden" name="WgtT" value="0">
<input id="searchcity" type="hidden" name="searchcity" />
</form>
