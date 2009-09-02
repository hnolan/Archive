<?php
// webcdb.php - script display capacity data

require_once "webcdb_lib.php";
require "./webcdb.env.php";

$title = "Imerja Web Charts ($webcdb_db_env)";
html_begin ($title, $title);

$dbh = webcdb_connect($webcdb_db_env,'pdo');

//---------------------------------------
//	Print the combo box for selecting the customer
//---------------------------------------
function print_combo($dbh)
{
	// Join on machine to only select customers with machines defined
	$sql =  "select distinct c.prefix, c.fullname from m00_customers c ";
	$sql .= " inner join m01_machines m on c.id = m.cdb_customer_id ";
	$sql .= " order by c.fullname";

	$sth = $dbh->query($sql);
	
	print ("<select size='1' name='cmbPrefix'>\n");
	while ($row = $sth->fetch (PDO::FETCH_NUM)) {
		print ("\t<option value='$row[0]'>" . htmlspecialchars ($row[1]) . "</option>\n");
		}
	print ("</select>\n");
	
	$sth->closeCursor();
}

//---------------------------------------
//	Print the array for matching sites to customer
//---------------------------------------
function print_array($dbh)
{
	// Join on machine to get machine_type
	$sql =  "select distinct c.prefix, m.machine_type from m00_customers c ";
	$sql .= " inner join m01_machines m on c.id = m.cdb_customer_id ";
	$sql .= " order by c.prefix";

	$sth = $dbh->query($sql);
	
	print ("Dim arrP, arrPST\narrPST = Array( _\n");
	while ($row = $sth->fetch (PDO::FETCH_NUM)) {
		print ("\t\"$row[0]\", \"" . htmlspecialchars ($row[1]) . "\", _\n");
		}
	print ("\"0\",\"Dummy\" )\n");
	
	$sth->closeCursor();
}

//---------------------------------------
//	Main HTML code of page starts here
//---------------------------------------

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
// close connection
$dbh = NULL;

html_end ();
?>
