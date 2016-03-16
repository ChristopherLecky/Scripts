
############################## REQUIRED ASSEMBLIEs######################################
Add-Type -AssemblyName Microsoft.VisualBasic
############################## VARIABLES######################################
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$xml_path = $current_path + "\cssettings.xml"
$cssettings

$csDataTable = New-Object System.Data.DataTable
[string]$csquery = $("SELECT * FROM [dbo].[CommCellJobController]")


#SNMP
$snmphost = ""
$snmpCommunity = ""

############################## FUNCTIONS#######################################
function readsettings ($cssettings){
	$cssettings = @{
		#Install information
		base_folder    = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Base").dBASEHOME;
		commserver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Commserve").sCSCLIENTNAME;
		#database information
		dsn_name       = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Database").sCONNECTION;
		dsn_dbname     = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Database").sCSDBNAME;
		dsn_dbinstance = (Get-ItemProperty -Path "HKLM:\SOFTWARE\CommVault Systems\Galaxy\Instance001\Database").sINSTANCE;
    }
return $cssettings	
}
function sendtrap($trapinfo){

}




function CSSqlQuery ($Server, $Database, $SQLQuery)
{
	$Datatable = New-Object System.Data.DataTable
	$Connection = New-Object System.Data.SQLClient.SQLConnection
	$Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;"
	$Connection.Open()
	$Command = New-Object System.Data.SQLClient.SQLCommand
	$Command.Connection = $Connection
	$Command.CommandText = $SQLQuery
	$Reader = $Command.ExecuteReader()
	$Datatable.Load($Reader)
	$Connection.Close()
	return $Datatable
}




##############################SCRIPT BEGIN ####################################
$cssetings   = readsettings($cssettings)
$csDataTable = CSSqlQuery $cssettings.sCONNECTION $cssettings.dsn_dbname $csquery

#login to commserve run qlist and capture output
csactivity



#export

#########################################PARSE JOBSUMMARY INFO AND CONVERT TO OBJECT################################
$qlisttxt = [IO.File]::ReadAllText($current_path + "\qlistjobsummary.txt") # HERE FOR RESTING COMMENT OUT BEFORE PUBLISHING


#compare qlist ratios of running jobs to pending
###########################################SEND SNMP TRAP############################################################

#Log out of commserve
qlogout