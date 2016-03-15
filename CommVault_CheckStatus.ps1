﻿
############################## REQUIRED ASSEMBLIEs######################################
Add-Type -AssemblyName Microsoft.VisualBasic
############################## VARIABLES######################################
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$xml_path = $current_path + "\cssettings.xml"

#COMMSERVER LOGIN
$cssettings

#SNMP
$snmphost = ""
$snmpCommunity = ""

############################## FUNCTIONS#######################################
function readsettings (){
	$cssettings = @{
		#Install information
		base_folder    = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Base").dBASEHOME;
		commserver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Commserve").sCSCLIENTNAME;
		#database information
		dsn_name       = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Database").sCONNECTION;
		dsn_dbname     = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Database").sCSDBNAME;
		dsn_dbinstance = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Database").sINSTANCE;
    }
}
function createsettings ($xml_path){
inputsettings
$XmlWriter = New-Object System.XMl.XmlTextWriter($xml_path,$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"
$xmlWriter.WriteStartDocument() #Header
$xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'") #xsl 
$XmlWriter.WriteComment('Settings for powershell script')
$xmlWriter.WriteStartElement('cssettings')
    $xmlWriter.WriteStartElement('qlogin')
        $xmlWriter.WriteElementString('cs',$cssettings.commserver)
        $xmlWriter.WriteElementString('uname',$cssettings.uname)
        $xmlWriter.WriteElementString('pwd',$cssettings.password)
        $xmlWriter.WriteElementString('token',$cssettings.tokenfile)
        $xmlWriter.WriteElementString('bf',$cssesttings.base_folder)
    $xmlWriter.WriteEndElement()
$xmlWriter.WriteEndElement() 
$xmlWriter.Flush()
$xmlWriter.Close()
}
function sendtrap($trapinfo){

}
function csactivity(){
&cd $cssettings.base_folder #Change to base folder - update to change drive as well
&qlogin -cs $cssetttings.commserver -u $cssettings.username -ps $cssettings.password  #Logging into commserver

$qlistSI = New-Object System.Diagnostics.ProcessStartInfo
$qlistSI.FileName = "qlist.exe"
$qlistSI.RedirectStandardError = $true
$qlistSI.RedirectStandardOutput = $true
$qlistSI.UseShellExecute = $false
$qlistSI.Arguments = "jobsummary "
$qlist = New-Object System.Diagnostics.Process
$qlist.StartInfo = $qlistSI
$qlist.Start() | Out-Null
$qlist.WaitForExit()
$stdout = $qlist.StandardOutput.ReadToEnd()
$stderr = $qlist.StandardError.ReadToEnd()
Write-Host "stdout: $stdout"
Write-Host "stderr: $stderr"
Write-Host "exit code: " + $qlist.ExitCode
}
function inputsettings{
	$cssettings = @{
		commserver = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the name of the Commserve:", "Commserve");
		username = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your username:", "Username", "Default value");
		password = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your password:", "Window Title", "Default value");
        snmphost = [Microsoft.VisualBasic.Interaction]::InputBox("Enter SNMP Host:", "#SNMPHOST", "Default value");
		snmpcommunity = [Microsoft.VisualBasic.Interaction]::InputBox("Enter SNMP Community:", "SNMP Community", "Default value");
		#base_folder = (Get-ItemProperty "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Base")
	}
}
##############################SCRIPT BEGIN ####################################
if (Test-Path $xml_path){readsettings($xml_path)}else {createsettings($xml_path)}

#login to commserve run qlist and capture output
csactivity



#export

#########################################PARSE JOBSUMMARY INFO AND CONVERT TO OBJECT################################
$qlisttxt = [IO.File]::ReadAllText($current_path + "\qlistjobsummary.txt") # HERE FOR RESTING COMMENT OUT BEFORE PUBLISHING


#compare qlist ratios of running jobs to pending
###########################################SEND SNMP TRAP############################################################

#Log out of commserve
qlogout