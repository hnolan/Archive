'-------------------------------------------------
' arrM and ArrC are dynamically generated by the 
' main php code that includes this script
'-------------------------------------------------

' =============================
Sub Window_OnLoad()
	' Call onChange routines to initialise selections
	cmbPeriod_onChange
	cmbSelType_onChange
End Sub
 
' =============================
Sub cmbPeriod_onChange()
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
Sub cmbSelType_onChange()
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