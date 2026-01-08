Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strCmdPath = objFSO.BuildPath(strScriptPath, "cursor-actual.cmd")

' Get current working directory
strCurrentDir = objShell.CurrentDirectory

' Build command with arguments
strCommand = "cmd.exe /c ""cd /d """ & strCurrentDir & """ && """ & strCmdPath & """"

' Add any arguments passed to the script
If WScript.Arguments.Count > 0 Then
    For i = 0 To WScript.Arguments.Count - 1
        strCommand = strCommand & " """ & WScript.Arguments(i) & """"
    Next
End If

strCommand = strCommand & """"

' Run hidden (0 = hidden window, False = don't wait)
objShell.Run strCommand, 0, False

Set objShell = Nothing
Set objFSO = Nothing
