<?php
//-------------------------------------------------
// webcdb_pdo.php - common functions for cdb PDO-based PHP scripts
//
// This file can be found at:
//		/usr/local/apache/lib/php/webcdb_pdo.php
//-------------------------------------------------

# Function that uses our top-secret username and password to connect
# to the MySQL server to use the sampdb database. It also enables
# exceptions for errors that occur for subsequent PDO calls.
# Return value is the database handle produced by new PDO().
#-------------------------------------------------
function webcdb_connect ()
{
  $dbh = new PDO("mysql:host=localhost;dbname=ext_cdb",
                 "cdbweb", "antipode");
  $dbh->setAttribute (PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  return ($dbh);
}

# Put out initial HTML tags for page.  $title and $header, if
# present, are assumed to have any special characters properly
# encoded.
#-------------------------------------------------
function html_begin ($title, $header)
{
  print ("<html>\n");
  print ("<head>\n");
  if ($title != "")
    print ("<title>$title</title>\n");
  print ("<link href=\"css/cdb.css\" rel=\"stylesheet\" type=\"text/css\"/>\n");
  print ("</head>\n");
  print ("<body bgcolor=\"white\">\n");
  if ($header != "")
    print ("<h2>$header</h2>\n");
}

# put out final HTML tags for page.
#-------------------------------------------------
function html_end ()
{
  print ("</body>\n");
  print ("</html>\n");
}

#-------------------------------------------------
# Generate Web form elements.  Arguments that become part of the
# content of the element are automatically HTML-encoded.
#-------------------------------------------------

# Print hidden field
#-------------------------------------------------
function hidden_field ($name, $value)
{
  printf ("<input type=\"%s\" name=\"%s\" value=\"%s\" />\n",
          "hidden",
          htmlspecialchars ($name),
          htmlspecialchars ($value));
}

# Print editable text entry field
#-------------------------------------------------
function text_field ($name, $value, $size)
{
  printf ("<input type=\"%s\" name=\"%s\" value=\"%s\" size=\"%s\" />\n",
          "text",
          htmlspecialchars ($name),
          htmlspecialchars ($value),
          htmlspecialchars ($size));
}

# Print password entry field
#-------------------------------------------------
function password_field ($name, $value, $size)
{
  printf ("<input type=\"%s\" name=\"%s\" value=\"%s\" size=\"%s\" />\n",
          "password",
          htmlspecialchars ($name),
          htmlspecialchars ($value),
          htmlspecialchars ($size));
}

# Print radio button.  $checked should be true if the box should be
# selected by default.
#-------------------------------------------------
function radio_button ($name, $value, $label, $checked)
{
  printf ("<input type=\"%s\" name=\"%s\" value=\"%s\"%s />%s\n",
          "radio",
          htmlspecialchars ($name),
          htmlspecialchars ($value),
          ($checked ? " checked=\"checked\"" : ""),
          htmlspecialchars ($label));
}

# Print form submission button
#-------------------------------------------------
function submit_button ($name, $value)
{
  printf ("<input type=\"%s\" name=\"%s\" value=\"%s\" />\n",
          "submit",
          htmlspecialchars ($name),
          htmlspecialchars ($value));
}

# script_param() extracts an input parameter from the script execution
# environment.
# If extra backslashes were added due to magic_quotes_gpc being
# enabled, it strips them using the remove_backslashes() function.
# track_vars is assumed to be enabled, but nothing is assumed about
# magic_quotes_gpc, and the function does not require register_globals to
# be enabled.

# remove_backslashes() takes into account whether the value is a scalar or
# an array.  It is recursive in case you create a form that takes advantage
# of the ability to created nested input parameters in PHP 4 and up.
#-------------------------------------------------
function remove_backslashes ($val)
{
  if (is_array ($val))
  {
    foreach ($val as $k => $v)
      $val[$k] = remove_backslashes ($v);
  }
  else if (!is_null ($val))
    $val = stripslashes ($val);
  return ($val);
}

#-------------------------------------------------
function script_param ($name)
{
  $val = NULL;
  if (isset ($_GET[$name]))
    $val = $_GET[$name];
  else if (isset ($_POST[$name]))
    $val = $_POST[$name];
  if (get_magic_quotes_gpc ())
    $val = remove_backslashes ($val);
  return ($val);
}

# Return the pathname of the current script.
#-------------------------------------------------
function script_name ()
{
  return ($_SERVER["SCRIPT_NAME"]);
}

# Print the results of the $stmt query as a table (for debug)
#-------------------------------------------------
function printtab($dbh,$stmt)
{
	$sth = $dbh->query ($stmt);

	print ("<table>\n");
	while ($row = $sth->fetch (PDO::FETCH_NUM))
	{
		print ("<tr>\n");
		for ($i = 0; $i < $sth->columnCount (); $i++)
		{
			print ("<td>" . htmlspecialchars ($row[$i]) . "</td>\n");
		}
		print ("</tr>\n");
	}
	print ("</table>\n");
	
	$sth = NULL;
}

?>
