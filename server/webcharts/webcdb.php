<?php
# webcdb.php - script display capacity data

require_once "webcdb_pdo.php";

$title = "Imerja Web Charts";
html_begin ($title, $title);

$dbh = webcdb_connect ();

#---------------------------------------
#	Print the combo box for selecting the customer
#---------------------------------------
function print_combo($dbh)
{
	$stmt = "call web_get_prefix_type('Prefix')";
	$sth = $dbh->query ($stmt);
	
	print ("<select size='1' name='cmbPrefix'>\n");
	while ($row = $sth->fetch (PDO::FETCH_NUM))
	{
		print ("\t<option value='$row[0]'>" . htmlspecialchars ($row[1]) . "</option>\n");
	}
	print ("</select>\n");
	
	$sth = NULL;
}

#---------------------------------------
#	Print the array for matching sites to customer
#---------------------------------------
function print_array($dbh)
{
	$stmt = "call web_get_prefix_type('')";
	$sth = $dbh->query ($stmt);
	
	print ("Dim arrP, arrPST\narrPST = Array( _\n");
	while ($row = $sth->fetch (PDO::FETCH_NUM))
	{
		print ("\t\"$row[0]\", \"" . htmlspecialchars ($row[1]) . "\", _\n");
	}
	print ("\"0\",\"Dummy\" )\n");
	
	$sth = NULL;
}

//$response = script_param ("response");
//if (is_null ($response))   # invoked for first time
//  present_question ($dbh);
//else                      # user submitted response to form
//  check_response ($dbh);

#---------------------------------------
#	Main HTML code of page starts here
#---------------------------------------

?>

<h1 align="center"><b><font color="#000080">Imerja Capacity Data Web Charts</font></b></h1>
<h2 align="center"><b><font color="#000080">Please Select a Trust and Site Name</font></b></h2>

<form method="POST" name="FormFP1" action="webcdbp2.php" >

	<div align="center">

	<table border="0" cellspacing="0" cellpadding="0" >

	<tr>
		<td align="center" nowrap><p align="right">NHS Trust</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap><p align="left">

<?php
 print_combo($dbh);
?>

		</td>
	</tr>

	<tr>
		<td align="center" nowrap>&nbsp;</td>
		<td align="center" width="18" nowrap></td>
		<td align="center" nowrap></td>
	</tr>

	<tr>
		<td align="center" nowrap><p align="right">Site Name</td>
		<td align="center" width="18" nowrap>:</td>
		<td align="left" nowrap><p align="left">
			<span id="spnSystemType">
			<select size="1" name="cmbSystemType">
				<option value="-1">-- No System Types --</option>
			</select>
			</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="submit" value="Next >>" name="B1">
		</td>
	</tr>

	</table>

	</div>

<div style="visibility:hidden" id="ExtraData" >
	<input type="text" value="No customer!" name="txtCustomer">
</div>

</form>

<script language=vbs>
<!--
<?php
 print_array($dbh);
?>
-->
</script>

<script src="scripts/webcdb.vbs" language="vbs" ></script>

<?php
$dbh = NULL;  # close connection
html_end ();
?>
