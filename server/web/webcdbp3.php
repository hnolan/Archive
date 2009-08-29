<?php
// webcdbp3.php - script display capacity data

require_once "cdb_dev_pdo.php";

$title = "Imerja - Web Charts";
html_begin ($title, "");

//----------------------------------
// Get data from submitted web form
//----------------------------------

// Pass-through from Page 1
$sPrefix  = script_param("txtPrefix");
$sSysType = script_param("txtSystemType");

// Data from Page 2
$iPeriod    = script_param("cmbPeriod");
$iQualifier = script_param("cmbShift");
$sSelType   = script_param("cmbSelType");
$sSelection = script_param("cmbSelection");
$iOfficeVer = script_param("cmbOfficeVer");

$sStartDate = script_param("cmbStartYear") . "-" . script_param("cmbStartMonth") . "-" . script_param("cmbStartDay");
$sEndDate   = script_param("cmbEndYear") . "-" . script_param("cmbEndMonth") . "-" . script_param("cmbEndDay");

// The three columns preceding the data are: Selection, Series and Data_Type
$rhc = 3;

//----------------------------------
// Process submitted data
//----------------------------------

switch ( $iPeriod ) {
	case 20:
		$sPeriod = "Hour";
		$iQualifier = 1;
		break;
	case 21:
		$sPeriod = "HourOfDay";
		$iQualifier = 2;
		break;
	case 30:
		$sPeriod = "Day";
		break;
	case 40:
		$sPeriod = "Week";
		break;
	case 50:
		$sPeriod = "Month";
	}

if ( $sSelType == "Machine" )
	$bSingleMachine = true;
 else
	$bSingleMachine = false;

switch ( $iOfficeVer ) {
	case 9:
		$sCLSID = "0002E500-0000-0000-C000-000000000046";
		break;
	case 10:
		$sCLSID = "0002E556-0000-0000-C000-000000000046";
		break;
	case 11:
		$sCLSID = "0002E55D-0000-0000-C000-000000000046";
	}

// Format page title
$sTitle = "$sPrefix data from $sStartDate to $sEndDate";
$sTitle = $sTitle . ", for '$sSelection' by $sPeriod (Shift $iQualifier)";

print("<!--\n");
print("txtPrefix     : $sPrefix\n");
print("txtSystemType : $sSysType\n");
print("  StartDate   : $sStartDate\n");
print("    EndDate   : $sEndDate\n");
print("cmbPeriod     : $iPeriod\n");
print("cmbShift      : $iQualifier\n"); 
print("cmbSelType    : $sSelType\n");
print("cmbSelection  : $sSelection\n");
print("cmbOfficeVer  : $iOfficeVer\n");
print("\n");
print("sPeriod       : $sPeriod\n");
print("iQualifier    : $iQualifier\n"); 
print("bSingleMach   : " . ( $bSingleMachine ? 1 : 0 ) . "\n");
print("sCLSID        : $sCLSID\n");
print("sTitle        : $sTitle\n");

//-------------------------------
// DB Handling code
//-------------------------------

$nodata = false;
$aData = array();
$aCats = array();

try {
	$dbh = webcdb_connect ();
	
	$stmt = "call web_pivot_data( '$sSysType', '$sSelType', " .
				"'$sSelection', '$sStartDate', '$sEndDate', $iPeriod )";
	
	print("stmt          : $stmt\n");
	print("-->\n");
	
	$sth = $dbh->query ($stmt);
	
	// Read the returned dataset into a datastructure
	// Returned data columns are expected to be:
	//
	//	Selection, Series, Data_Type, Sample_Time, Value
	//
	$aData = array();
	while ($row = $sth->fetch (PDO::FETCH_NUM))	{
		$aData[$row[0]][$row[1]][$row[2]][$row[3]] = $row[4];
		$aCats[$row[3]] = 1;
		}
	}
	catch	(Exception $e) {
		$em = $e->getMessage();
		$ec = substr($em,strlen($em)-5,4);
		if ( $ec == 2053 )	// CR_NO_RESULT_SET
			$nodata = true;
		 else
			print "Caught unexpected exception: " . $e->getMessage() . "\n";
		}

$sth = NULL;
$dbh = NULL;  // close connection

// printtab($dbh,$stmt);

if ( $nodata == false ) {

//--------------------------------  PHP End  -----------------------------------
?>

<div id="divHeader">

<img src="css/imerja.gif" alt="Imerja - Securing Business" id="logo" >

<div id="divControls">
<table border=0 cellspacing=0 cellpadding=0 >
	<tr>
		<td class="label">Chart Type&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td>
			<select size="1" name="cmbType" language="VBScript" OnChange="MakeCharts()">
				<option selected value="6">Line</option>
				<option value="12">Line Smooth</option>
				<option value="7">Line Markers</option>
				<option value="0">Column Clustered</option>
				<option value="1">Column Stacked</option>
				<option value="29">Area</option>
				<option value="30">Area Stacked</option>
			</select>
		</td>
		<td align="center" >Charts</td>
		<td class="label">Maximum Values&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td><input type="checkbox" name="chkMax" language="VBScript" OnClick="MakeCharts()"></td>
	</tr>

	<tr>
		<td class="label">Chart Scale&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td>
			<select size="1" name="cmbScale" language="VBScript" OnChange="MakeCharts()">
<?php
//--------- PHP Start ----------
	$t4 = "				";
	if ( $bSingleMachine ) {
		// Many different counters, so set initial scale to be "Auto from zero"
		print $t4 . "<option selected value=\"0\">Auto (Min=zero)</option>\n";
		print $t4 . "<option value=\"50\">Auto</option>\n";
		print $t4 . "<option value=\"100\">Percent (0 to 100)</option>\n";
		}
	 else {
		// Only one counter, so check its type
		if ( strpos($sSelection,"%") > 0 ) {
			// Counter name contains percent, set scaling accordingly
			print $t4 . "<option value=\"0\">Auto (Min=zero)</option>\n";
			print $t4 . "<option value=\"50\">Auto</option>\n";
			print $t4 . "<option selected value=\"100\">Percent (0 to 100)</option>\n";
			}
		 else {
			// Set scaling to auto
			print $t4 . "<option selected value=\"0\">Auto (Min=zero)</option>\n";
			print $t4 . "<option value=\"50\">Auto</option>\n";
			print $t4 . "<option value=\"100\">Percent (0 to 100)</option>\n";
			}
		}
//---------  PHP End  ----------
?>
			</select>
		</td>
		<td align="center" rowspan=3>
			<select multiple size=4 name="cmbSelections">
<?php
//--------- PHP Start ----------
	// Build the option list for the cmbSelections listbox
	$c0=0;
	foreach ( array_keys($aData) as $k0 ) { // Each Selection
		print "				<option selected value=$c0>$k0</option>\n";
		$c0++; $c0++;
		}
//---------  PHP End  ----------
?>
			</select>
		</td>
		<td class="label">Average Values&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td><input type="checkbox" name="chkAvg" language="VBScript" OnClick="MakeCharts()" checked></td>
	</tr>

	<tr>
		<td class="label">Chart Wrap&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td>
			<select size="1" name="cmbWrap" language="VBScript" OnChange="MakeCharts()">
				<option value="1">1</option>
				<option value="2">2</option>
				<option selected value="3">3</option>
			</select>
		</td>
		<td class="label">Minimum values&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td><input type="checkbox" name="chkMin" language="VBScript" OnClick="MakeCharts()"></td>
	</tr>

	<tr>
		<td></td>
		<td>
		<input type="button" name="btnShowSeries" value="Show Series">
		</td>
		<td class="label">Sample Counts&nbsp;&nbsp;:&nbsp;&nbsp;</td>
		<td><input type="checkbox" name="chkCnt" language="VBScript" OnClick="MakeCharts()"></td>
	</tr>

</table>
</div>

</div>

<div id=divMain>

<?php
//--------- PHP Start ----------
	print "	<h2>$sTitle</h2>\n";
//---------  PHP End  ----------
?>

	<div id=divSeries>

<?php
//--------- PHP Start ----------
	$c0=0; $c1=0;
	foreach ( array_keys($aData) as $k0 ) { // Each Selection
		print "    <div class=\"ChartSeries\" id=\"CS$c0\">\n";
		print "    	<h3>$k0</h3>\n";
		foreach ( array_keys($aData[$k0]) as $k1 ) { // Each Series
			print "			<span class=\"CSX\">";
			print "<input type=\"checkbox\" id=\"C$c0" . "S$c1\"";
			print " language=\"VBScript\" OnClick=\"MakeCharts()\" checked>";
			print "$k1</span>\n";
			$c1++; $c1++;
			}
		print "    </div>\n\n";
		$c0++; $c0++; $c1=0;
		}
//---------  PHP End  ----------
?>

	</div>

	<div id=divCharts>
<?php
//--------- PHP Start ----------
	// Write the code to instantiate a ChartSpace
	print "<object id=ChartSpace1 classid=CLSID:$sCLSID style=\"width:100%\"></object>\n";
	print "<object id=ChartSpace2 classid=CLSID:$sCLSID style=\"height:0;width:100%\"></object>\n";
	print "<object id=ChartSpace3 classid=CLSID:$sCLSID style=\"height:0;width:100%\"></object>\n";
//---------  PHP End  ----------
?>
	</div>

</div>

<script language=vbs>
<!--

' Initialise data as global arrays
    Dim CTG, blSingleMachine, strSelection

<?php
//--------- PHP Start ----------
	
	// Output the dictionary data
	print "' Initialise data as global nested arrays\n";

	// Output main structure
	print "arrSel = Array("; $s0="";
	foreach ( array_keys($aData) as $k0 ) { // Each Selection
		print "$s0 _\n\t\"$k0\", Array("; $s1="";
		foreach ( array_keys($aData[$k0]) as $k1 ) { // Each Series
			print "$s1 _\n\t\t\"$k1\", Array("; $s2="";
			foreach ( array_keys($aData[$k0][$k1]) as $k2 ) { // Each Data_Type
				print "$s2 _\n\t\t\t\"$k2\", Array("; $s3="";
				foreach ( array_keys($aCats) as $kc ) { // Each Sample_Time
					if ( array_key_exists( $kc, $aData[$k0][$k1][$k2] ) )
						$v = $aData[$k0][$k1][$k2][$kc];
					 else
					 	$v = 0;
					print "$s3 $v";  $s3=",";
					}
				print " )"; $s2=","; 
				}
			print " _\n\t\t)"; $s1=","; 
			}
		print " _\n\t)"; $s0=","; 
		}
	print "_\n)\n\n";

	// Output category array
	print "CTG = Array( "; $s0="";
	foreach ( array_keys($aCats) as $kc ) { // Each Sample_Time
		if ($iPeriod == 20) // Hourly
			$cv = substr($kc,0,16);
		 elseif ($iPeriod == 21) // HourOfDay
			$cv = substr($kc,11,5);
		 else
			$cv = substr($kc,0,10);
		print "$s0 \"$cv.\""; $s0=",";
		}
	print " )\n\n";

	print "    blSingleMachine = " . ( $bSingleMachine ? 1 : 0 ) . "\n";
	print "    strSelection = \"$sSelection\"\n";
	print "    intChartSize = 80\n\n";
	
//---------  PHP End  ----------
?>
-->
</script>

<script src="scripts/webcdbp3.vbs" language="vbs" ></script>

<?php
//-------------------------------- PHP Start -----------------------------------

		}
  else {

	//----------------------------------
	// Return a page to say no data was found
	//----------------------------------

//--------------------------------  PHP End  -----------------------------------
?>
<div id="divHeader">
<img src="css/imerja.gif" alt="Imerja - Securing Business" id="logo" >
</div>
<p></p>
<?php
//--------- PHP Start ----------
	print "	<h2>$sTitle</h2>\n";
//---------  PHP End  ----------
?>
<p></p>
<div class="errMsg">
<p>No Data Found for this selection and period</p>
</div>
<p>&nbsp;</p>
<?php
//-------------------------------- PHP Start -----------------------------------

	}

////==============================================================================
////	This is the end of the main PHP routine, subroutines follow
////==============================================================================
//
//// ---------------------------------------------------------
//function print_scale_options () {
//}
//
//// ---------------------------------------------------------
//function print_chart_options() {
//}
//
//// ---------------------------------------------------------
//function print_title() {
//}
//
//// ---------------------------------------------------------
//function print_chart_series() {
//}
//
//// ---------------------------------------------------------
//function print_chart_space() {
//}
//
//// ---------------------------------------------------------
//function print_global_data() {
//}

html_end ();
?>
