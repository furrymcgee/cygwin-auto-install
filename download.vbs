'https://www.codeproject.com/tips/506439/downloading-files-with-vbscript

If WScript.Arguments.Count Then
	strLink = WScript.Arguments(0)
Else
	WScript.Quit 1
End If

' Get file name from URL.
strSaveName = Mid(strLink, InStrRev(strLink,"/") + 1, Len(strLink))
strSaveTo = strSaveName

WScript.Echo "HTTPDownload"
WScript.Echo "-------------"
WScript.Echo "Download: " & strLink
WScript.Echo "Save to:  " & strSaveTo

' Create an HTTP object
Set objHTTP = CreateObject("MSXML2.ServerXMLHTTP")
objHTTP.SetOption 2, objHTTP.GetOption(2) And Not SXH_SERVER_CERT_IGNORE_ALL_SERVER_ERRORS

' Download the specified URL
'xmlhttp.Open "GET", strURL, false, "User", "Password"
objHTTP.open "GET", strLink, False
objHTTP.send

Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists(strSaveTo) Then
	objFSO.DeleteFile(strSaveTo)
End If

If objHTTP.Status = 200 Then
	Dim objStream
	Set objStream = CreateObject("ADODB.Stream")
	With objStream
		.Type = 1 'adTypeBinary
		.Open
		.Write objHTTP.responseBody
		.SaveToFile strSaveTo
		.Close
	End With
	set objStream = Nothing
End If

If objFSO.FileExists(strSaveTo) Then
	WScript.Echo "Download `" & strSaveName & "` completed successfuly."
End If

