<?php
# webcdbp2.php - script display capacity data

require_once "cdb_dev_pdo.php";

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
<?php
 print_arrays($dbh,$systyp);
?>
-->
</script>

<script src="scripts/webcdbp2.vbs" language="vbs" ></script>

<?php
$dbh = NULL;  # close connection
html_end ();
?>
