' https://stackoverflow.com/questions/911053/how-to-unzip-a-file-in-vbscript-using-internal-windows-xp-options-in

With CreateObject("Shell.Application")
	.NameSpace(
		CreateObject("Scripting.FileSystemObject")
			.CreateFolder(WScript.Arguments(1)).Name
	).CopyHere(
		.objShell.NameSpace(WScript.Arguments(0)).items
	)
End With
