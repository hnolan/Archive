<?php
# webcdbp2.php - script display capacity data

require_once "webcdb_pdo.php";

$title = "Imerja Web Charts (p2)";
html_begin ($title, $title);

# Collect form parameters
$prefix = script_param("cmbSystemType");
$systyp = script_param("cmbSystemType");
$cust = script_param("txtCustomer");

# Connect to DB
$dbh = webcdb_connect ();

#---------------------------------------
#	Print VBscript Arrays for machine/counter combo box
#---------------------------------------
function print_arrays($dbh,$systyp)
{

	# Array declarations
	print("Dim arrM, arrC\n");

	$stmt = "call web_get_machine_counter('$systyp','Machine')";
	$sth = $dbh->query ($stmt);
	
	# Machines array
	print("arrM = Array("); $sep = "";
	while ($row = $sth->fetch (PDO::FETCH_NUM)) {
		print("$sep \"$row[0]\""); $sep = ",";
		}
	print(" )\n");
	
	$sth = NULL;
	
	$stmt = "call web_get_machine_counter('$systyp','Counter')";
	$sth = $dbh->query ($stmt);
	
	# Counters array
	print("arrC = Array("); $sep = "";
	while ($row = $sth->fetch (PDO::FETCH_NUM)) {
		print("$sep \"$row[0]\""); $sep = ",";
		}
	print(" )\n");
	
	$sth = NULL;
	
}

#---------------------------------------
#	Print the combo boxes for selecting the date
#---------------------------------------
function print_date_combo($nam,$daysago)
{
	$dat = getdate( time() - ($daysago * 86400) );
	
	# Days
	print("<select size=\"1\" name=\"cmb" . $nam . "Day\">\n");
	for ( $i=1; $i <= 31; $i++ ) {
		$s = $dat["mday"] == $i ? "selected" : "";
		printf("\t<option value='%d' %s>%02d</option>\n",$i,$s,$i);
		}
	print("</select>\n");

	# Months
	print("<select size=\"1\" name=\"cmb" . $nam . "Month\">\n");
	for ( $i=1; $i <= 12; $i++ ) {
		$s = $dat["mon"] == $i ? "selected" : "";
		printf("\t<option value='%d' %s>%02d</option>\n",$i,$s,$i);
		}
	print("</select>\n");

	# Years
	print("<select size=\"1\" name=\"cmb" . $nam . "Year\">\n");
	for ( $i=2008; $i <= 2009; $i++ ) {
		$s = $dat["year"] == $i ? "selected" : "";
		printf("\t<option value='%d' %s>%04d</option>\n",$i,$s,$i);
		}
	print("</select>\n");

}

#---------------------------------------
#	Print the combo boxes for selecting the time
#---------------------------------------
function print_time_combo($nam)
{
	print("<select size=\"1\" name=\"cmb" . $nam . "Hour\">\n");
	for ( $i=0; $i < 24; $i++ ) {
		printf("\t<option value='%d'>%02d:00</option>\n",$i,$i);
		}
	print("</select>\n");
}


/*
'-------------------------------- ASP Start -----------------------------------
Months = Array( "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", _
				"Jul", "Aug", "Sep", "Oct", "Nov", "Dec" )

'--------------------------------  ASP End  -----------------------------------
*/

?>

<h1 align="center"><b><font color="#000080">Imerja Capacity Data Web Charts</font></b></h1>
<h2 align="center"><b><font color="#000080">
Data for <?php print($systyp); ?> systems from <?php print($cust); ?>
</font></b></h2>

<form method="POST" name="FormFP1" action="webcdbp3.php" target="_blank">

	<div align="center">

	<table border="0" cellspacing="0" cellpadding="0" >

	<tr>
		<td align="center" nowrap><p align="right">Start Date</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap>
<?php
	print_date_combo( "Start", 35 );
?>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="visibility:visible" id="StartTime" >
<?php
	print_time_combo( "Start" );
?>
			</span>
		</td>
	</tr>

	<tr>
		<td align="center" nowrap><p align="right">End Date</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap>
<?php
	print_date_combo( "End", 0 );
?>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="visibility:visible" id="EndTime" >
<?php
	print_time_combo( "End" );
?>
			</span>
		</td>
	</tr>

	<tr>
		<td align="center" nowrap>&nbsp;</td>
		<td align="center" width="18" nowrap></td>
		<td align="center" nowrap></td>
	</tr>

	<tr>
		<td nowrap><p align="right">Period</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap>
		<select size="1" name="cmbPeriod">
			<option value="20" selected>Hourly</option>
			<option value="21">HourOfDay</option>
<!--
			<option value="30">Daily</option>
			<option value="40">Weekly</option>
			<option value="50">Monthly</option>
-->
		  </select>
		<span style="visibility:visible" id="ShiftID" >
		<select size="1" name="cmbShift">
			<option value="1" selected>24 x 7</option>
			<option value="2">Core Hours</option>
		  </select></span>
		 </td>
	</tr>

	<tr>
		<td nowrap>&nbsp;</td>
		<td align="center" width="18" nowrap> </td>
		<td align="center" nowrap> </td>
	</tr>

	<tr>
		<td nowrap><p align="right">Selection Type</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap>
		<select size="1" name="cmbSelType">
			<option value="Machine">Machine</option>
			<option value="Counter" selected>Counter</option>
		  </select> </td>
	</tr>

	<tr>
		<td nowrap>&nbsp;</td>
		<td align="center" width="18" nowrap> </td>
		<td align="center" nowrap> </td>
	</tr>

	<tr>
		<td nowrap><p align="right">Selection</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" width="200" nowrap>
			<span id="spnSelection">
			<select size="1" name="cmbSelection">
				<option value="-1">-- No Selection --</option>
			</select>
			</span></td>
	</tr>

	<tr>
		<td nowrap>&nbsp;</td>
		<td align="center" width="18" nowrap> </td>
		<td align="center" nowrap> </td>
	</tr>

	<tr>
		<td align="center" ><p align="right">Local Version of MS Office</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap><p align="left">
			<select size="1" name="cmbOfficeVer">
			    <option value="9">2000</option>
			    <option value="10">XP</option>
			    <option selected value="11">2003</option>
			</select>&nbsp;&nbsp;&nbsp;
			<input type="submit" value="Show Charts" name="B1">
		</td>
	</tr>

	</table>

	</div>

<div style="visibility:hidden" id="ExtraData" >
	<input type="text" value="<?php print($prefix); ?>" name="txtPrefix">
	<input type="text" value="<?php print($systyp); ?>" name="txtSystemType">
	<input type="text" value="xx" name="txtStartDate">
	<input type="text" value="yy" name="txtEndDate">
</div>

</form>

<script language=vbs>
<!--

'---------------------------------------
'	VBscript code for page starts here
'---------------------------------------

<?php
 print_arrays($dbh,$systyp);
?>

' =============================
Sub Window_OnLoad
	' Call onChange routines to initialise selections
	cmbPeriod_onChange
	cmbSelType_onChange
End Sub
 
' =============================
Sub cmbPeriod_onChange
	If FormFP1.cmbPeriod.Value = 20 Then
		' Only visible if Hourly is selected
		Document.All.StartTime.Style.Visibility = "visible"
		Document.All.EndTime.Style.Visibility = "visible"
		Document.All.ShiftID.Style.Visibility = "hidden"
	  ElseIf FormFP1.cmbPeriod.Value = 21 Then
		' Only visible if Hourly is selected
		Document.All.StartTime.Style.Visibility = "hidden"
		Document.All.EndTime.Style.Visibility = "hidden"
		Document.All.ShiftID.Style.Visibility = "hidden"
	  Else
		Document.All.StartTime.Style.Visibility = "hidden"
		Document.All.EndTime.Style.Visibility = "hidden"
		Document.All.ShiftID.Style.Visibility = "visible"
	  End If
End Sub

' =============================
Sub cmbSelType_onChange
	Dim v,h,i,arrV

	' Update cmbSelection
	v = document.FormFP1.cmbSelType.Value
	If v = "Machine" Then arrV = arrM Else arrV = arrC
	
	h = "<select size='1' name='cmbSelection'>"
	For i = 0 to UBound(arrV)
		h = h & "<option value='" & arrV(i) & "'>" & arrV(i) & "</option>"
	  Next
	h = h & "</select>"
	document.all.spnSelection.innerHTML = h

End Sub
  
' =============================
Function FormFP1_onReset()
	Document.All.StartTime.Style.Visibility = "hidden"
	Document.All.EndTime.Style.Visibility = "hidden"
	Document.All.ShiftID.Style.Visibility = "visible"
End Function

' =============================
Function FormFP1_onSubmit()

	Dim Months, msg

	msg = ""
	Months = Array( "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", _
				"Jul", "Aug", "Sep", "Oct", "Nov", "Dec" )

	' Convert to a date (handles invalid dates gracefully, e.g. converts 30 Feb 2003 to 02 Mar 2003)
	datStart = DateSerial( FormFP1.cmbStartYear.Value, FormFP1.cmbStartMonth.Value, FormFP1.cmbStartDay.Value )
	datEnd = DateSerial( FormFP1.cmbEndYear.Value, FormFP1.cmbEndMonth.Value, FormFP1.cmbEndDay.Value )

	strStart = Day(datStart) & " " & Months(Month(datStart)) & ", " & Year(datStart)
	strEnd = Day(datEnd) & " " & Months(Month(datEnd)) & ", " & Year(datEnd)

	Select Case FormFP1.cmbPeriod.Value
	  Case 20
		datStart = datStart + TimeSerial(FormFP1.cmbStartHour.Value,0,0)
		datEnd = datEnd + TimeSerial(FormFP1.cmbEndHour.Value,0,0)
		strStart = strStart & " " & FormFP1.cmbStartHour.Value & ":00"
		strEnd = strEnd & " " & FormFP1.cmbEndHour.Value & ":00"
		samples = DateDiff("h",datStart,datEnd)
	  Case 21
		samples = DateDiff("d",datStart,datEnd)
	  Case 30
		samples = DateDiff("d",datStart,datEnd)
	  Case 40
		samples = DateDiff("ww",datStart,datEnd)
	  Case 50
		samples = DateDiff("m",datStart,datEnd)
	  End Select

	If CInt(FormFP1.cmbStartDay.Value) <> Day(datStart) Then
		msg =  "Start date corrected to : " & vbTab & strStart & vbCrLf & vbCrLf
	  End If
		
	If CInt(FormFP1.cmbEndDay.Value) <> Day(datEnd) Then
		msg =  msg & "End date corrected to : " & vbTab & strEnd & vbCrLf & vbCrLf
	  End If

	' Validate DateRange
	If datStart >= datEnd Then
		msg = msg & "The end date must be later than the start date." & vbCrLf & vbCrLf
		msg = msg & "Please re-enter the date range and re-submit the form."
		MsgBox msg, , "Date Validation"
		FormFP1_onsubmit = False
		Exit Function
	  End If

	' Validate DateRange (no of samples)
	If samples >350 Then
		msg = "There are too many samples in the date range requested (based upon the period selected)." & vbCrLf
		msg = msg & "There are " & samples & " samples in the date range; The maximum allowed is 350." & vbCrLf & vbCrLf
		msg = msg & "Please re-enter the date range (or change the period) and re-submit the form."
		MsgBox msg, , "Sample Validation"
		FormFP1_onsubmit = False
		Exit Function
	  End If

	' Warn if dates have been corrected
	If msg <> "" Then
		MsgBox msg, , "Date Validation"
	  End If

	FormFP1.txtStartDate.Value = strStart
	FormFP1.txtEndDate.Value = strEnd

	FormFP1_onsubmit = True

End Function

-->
</script>

<?php
$dbh = NULL;  # close connection
html_end ();
?>
