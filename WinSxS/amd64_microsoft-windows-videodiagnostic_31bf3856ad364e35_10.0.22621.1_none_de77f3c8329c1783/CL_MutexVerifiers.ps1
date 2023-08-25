### Copyright © 2013, Microsoft Corporation. All rights reserved.

	. .\utils_setupenv.ps1

# this function should be included in TS_Main.ps1
function CreateUniqueGlobalFile(){
	 Set-PSVersionTable
	if ($PSVersionTable.PSVersion -lt '2.0') 
	{ 
		# if powershell version is less than 2.0
		$guid = [system.guid]::newguid()

		# for each resolver logging, does not contain the data of prior resolver
		$global:filename = $env:temp + "\" + $guid.tostring()

		# for keeping the list of all the resolver that ran
		$global:resolverRan = $env:temp + "\" + [system.guid]::newguid().tostring()

		$global:resolverFail =  $env:temp + "\" + [system.guid]::newguid().tostring()

	}else{
		$global:filename = $env:temp + "\" + [guid]::NewGuid().GUID
		$global:resolverRan =  $env:temp + "\" + [guid]::NewGuid().GUID
		$global:resolverFail =  $env:temp + "\" + [guid]::NewGuid().GUID
	}

	# "" > $global:resolverRan
}



# fail the resolver, $reason could be string also and other .net Exception objects too
# usage : resolverFail nameofPack instanceid reasonofFailure
# if there is no instance id then, resolverFail $null reasonofFailure
function resolverFail($id,$iid=$null,$reason=$null){
	($id+","+$iid)  >> $global:resolverFail

	if($reason -ne $null){
		throw $reason
	}
}


function deleteOldSDIAG($mins=60){

trap {
	continue
}

	$now = [system.datetime]::now
	$winTemp = $env:windir+"\temp"
	$localTemp = $env:temp

	$list = dir ( $winTemp ) -recurse  -filter "sdiag*"
	foreach($l1 in $list){
		if( $l1.CreationTime -lt ( $now.AddMinutes( (-1 * $mins) ) ) ) {
			del $l1.fullname -force -ea SilentlyContinue
			$l1.fullname
		}
	}


	$list = dir ( $localTemp ) -recurse
	foreach($l1 in $list){
		if( $l1.CreationTime -lt ( $now.AddMinutes( (-1 * $mins) ) ) ) {
			del $l1.fullname -force -ea SilentlyContinue
			$l1.fullname
		}
	}
}

# this function should be included in TS_Main.ps1, sometimes creating GUID gives problem in Powershell 1.0
function CreateUniqueGlobalFileName([string]$filename){
	 # Set-PSVersionTable
	
	$global:rc_verifiedHtable = @{}
	$global:rc_parametersHtable = @{}

	$global:rc_verifiedHtableXML =  $env:temp + "\"+$filename+"RC_VF.xml"
	$global:rc_parametersHtableXML =  $env:temp + "\"+$filename+"RC_Param.xml"

	$global:filename = $env:temp + "\$filename" 
	$global:resolverRan =  $env:temp + "\$filename"+"_resolverRan"
	$global:resolverFail =  $env:temp + "\$filename" + "_resolverFail"

	if(test-path ($global:resolverRan)){
		del $global:resolverRan
		"rootcause0123," > $global:resolverRan
	}

	if(test-path ($global:filename)){
		del $global:filename
	}

	if(test-path ($global:resolverFail)){
		del $global:resolverFail
	}
}

# must be used with conjuction of function CreateUniqueGlobalFileName
# this function is to save the state of the rootcause
function set-stateOFRootCause{
	 param([string]$res ,
				[string]$instanceid = $null,
                [bool]$detected = $false,
                [hashtable]$params = $null) 
				
 				# Write-Host ("rootcause and instance id :"+$res+$instanceid)+
				
				if($instanceid){
					
				}else{
					$instanceid = $null
				}
				
				if($params){
					if($params.count -eq 0){
						$params = $null
					}
				}else{
					$params =  $null
				}
				
				
                if( ( ($null -eq $instanceid ) -or ("" -eq $instanceid.trim() ) )  -and ( ($null -eq $params) ) ){ # if both parameters and instance id is null
                                # store the result
                                $res = "RC_"+$res
#								Write-Host ("rootcause and instance id :"+$res)
#								Write-Host ("rootcause gettype :"+$res.gettype())
                                if($global:rc_verifiedHtable["$res"] -eq $null){
                                                $global:rc_verifiedHtable.add("$res",$detected)
                                }else{
                                                $global:rc_verifiedHtable["$res"] = $detected
                                }
                                
                }elseif( ($null -eq $instanceid) -or ("" -eq $instanceid.trim() ) ){ # if only instance id is null
                                # store the result
                                $res = "RC_"+$res
#								Write-Host ("rootcause and instance id :"+$res)
#								Write-Host ("rootcause gettype :"+$res.gettype())
                                if($global:rc_verifiedHtable["$res"] -eq $null){
                                                $global:rc_verifiedHtable.add("$res",$detected)
                                }else{
                                                $global:rc_verifiedHtable["$res"] = $detected
                                }
 
                                # store the parameters
                                if($global:rc_parametersHtable["$res"] -eq $null){
                                                $global:rc_parametersHtable.add("$res",$params)
                                }else{
                                                $global:rc_parametersHtable["$res"] = $params
                                }
 
                }elseif( ($null -eq $params) ){ #if only parameters is null
                                # store the result
        $res = "RC_"+$res+","+$instanceid
#								Write-Host ("rootcause and instance id :"+$res)
#								Write-Host ("rootcause gettype :"+$res.gettype())
#								Write-Host ("instance gettype :"+$instanceid.gettype())
                                if($global:rc_verifiedHtable["$res"] -eq $null){
                                                $global:rc_verifiedHtable.add("$res",$detected)
                                }else{
                                                $global:rc_verifiedHtable["$res"] = $detected
                                } 
                                
 
                }else{ # if both parameter and instance id is not null
                                # store the result
        $res = "RC_"+$res+","+$instanceid
#								Write-Host ("rootcause and instance id :"+$res)
#								Write-Host ("rootcause gettype :"+$res.gettype())
#								Write-Host ("instance gettype :"+$instanceid.gettype())
                                if($global:rc_verifiedHtable["$res"] -eq $null){
                                                $global:rc_verifiedHtable.add("$res",$detected)
                                }else{
                                                $global:rc_verifiedHtable["$res"] = $detected
                                }
 
                                # store the parameters
                                if($global:rc_parametersHtable["$res"] -eq $null){
                                                $global:rc_parametersHtable.add("$res",$params)
                                }else{
                                                $global:rc_parametersHtable["$res"] = $params
                                }              
 
                }
 
                # ($global:rc_verifiedHtable | ConvertTo-Xml) > "$global:rc_verifiedHtableXML" # | Export-Clixml ($global:rc_verifiedHtableXML)
                
                # @($global:rc_parametersHtable) | Export-Clixml ($global:rc_parametersHtableXML)
                
                $f = $global:rc_verifiedHtableXML
#                ( new-object PSObject -property ($global:rc_verifiedHtable) ) | Export-Clixml ($f)
				write-HashTable2File ($global:rc_verifiedHtable) ($f+".txt")
			
#				 ( New-PSCustomObject ($global:rc_parametersHtable) ) | Export-Clixml ($f)
				
				$f = $global:rc_parametersHtableXML 
				write-HashTable2File ($global:rc_parametersHtable) ($f+".txt")
}


function write-HashTable2File([hashtable]$h,$f,$overWrite = $true){
	if( (Test-Path $f) -and $overWrite){
		del $f -Force
	}
	
	
	
	if( (Test-Path $f) -eq $false){
		"" > $f
		foreach($k in $h.keys){
			($k+":"+$h[$k]) >> $f
		}
	}
}


function update-DiagRootCausesecondTime($filename){
	$global:rc_verifiedHtableXML =  $env:temp + "\"+$filename+"RC_VF.xml"
	$global:rc_parametersHtableXML =  $env:temp + "\"+$filename+"RC_Param.xml"

	$rcs = cat ($global:rc_verifiedHtableXML+".txt")

	foreach($rc in $rcs){
		$rc1 = [string]$rc
		$rc1 = $rc1.split(':')
		$rc2 = $rc1[0]
		if($rc2.indexof(",") -gt -1){
			$rc2 = $rc2.split(",")
			update-diagrootcause -id ($rc2[0].trim()) -iid ($rc2[1].trim()) -detected ($($rc[1]))
			# pop-msg (($rc2[0].trim()) + ($rc2[1].trim()) + ($($rc[1])))
		}
	}
}


# function to be placed in every verfier
# usage example : for "RC_WUGenError" ,  if (checkResolver "WUGenError") { return }
#				for "RC_WUGenError" and instance id "Ax123" , if(checkResolver "WUGenError" "Ax123") { return }
#				for "RC_WUGenError" and parameter "Px123" , if(checkResolver "WUGenError" $null "Px123") { return }
#				for "RC_WUGenError" and instance id "Ax123" and parameter "Px123" , if(checkResolver "WUGenError" "Ax123" "Px123") { return }
# as you know here Px123 must be hashtable
# put this line at the top of the verifier after the include statements

function checkResolver {
	 param([string]$res ,
	 [string]$instanceid = $null,
	 [hashtable]$params = $null) 

	# pop-msg ($res+","+$instanceid) "78"

	$resRunning = ""
	if(test-path  $global:filename){
		$resRunning = cat $global:filename
	}

	$alreadyRan = ""
	if(test-path  $global:resolverRan){
		$alreadyRan = cat $global:resolverRan
	}

	$resFailed = $null

	if(test-path $global:resolverFail){
		$resFailed = cat $global:resolverFail
	}

	$detected = $true

	$returnFromFailed = $true;
	
	

	#check for failed resolvers
	if($resfailed -ne $null){
	foreach($f in $resFailed){
		
		$str = $f.split(',')
		
		$res = $str[0]

		if($str[1] -eq ""){
			$instanceid = $null
		}

		if( ($null -eq $instanceid) -and ($null -eq $params) ){ # if both parameters and instance id is null

		
			update-diagrootcause -id "RC_$res" -detected $true
		
		}elseif( ($null -eq $instanceid) ){ # if only instance id is null
	
			update-diagrootcause -id "RC_$res" -detected $true -parameter $params

		}elseif( ($null -eq $params) ){ #if only parameters is null
		
			if("$res,$instanceid" -eq $f){
				update-diagrootcause -id "RC_$res" -detected $true -iid $instanceid 
				
			}else{
				$returnFromFailed = $false
			}

		}else{ # if both parameter and instance id is not null
		
			if("$res,$instanceid" -eq $f){
				update-diagrootcause -id "RC_$res" -detected $true -iid $instanceid -parameter $params 
			}else{
				$returnFromFailed = $false
			}

		}

		if($returnFromFailed) { return $true }
	}
	}
	
	
	# since all the verifiers runs after each resolver is ran, we are keeping the list of which resolvers ran already
	foreach($ran in $alreadyRan){
		$ran=[string] $ran
		$tallyString = $res + "," + $instanceid
		#pop-msg ($tallyString+"==="+$ran)
		if( ($ran.length -eq $tallyString.length) -and ($tallystring.indexof($ran) -eq 0) ){
			return $false
		}
		#return $true
	}

	

	
	

		# check whether the current resolver is of current verifier
		


		if( ($resRunning[0] -eq $res) -and ($resRunning[1] -eq $instanceid) ){
			# pop-msg "$res:$instanceid:false" ":174"
			return $false

		}elseif( ( ($null -eq $instanceid) -or ("" -eq $instanceid.trim() ) ) -and ( ($null -eq $params)  ) ){ # if both parameters and instance id is null
			#-or ("" -eq $params.trim()  ) #>
			# pop-msg "$res:$instanceid:178" ":178"
			# for some strange reason even if $instanceid is set to null it somehow gets initialized to empty string,
			# so in this section checking for empty string
			update-diagrootcause -id "RC_$res" -detected $true
		
		}elseif( ($null -eq $instanceid) ){ # if only instance id is null
			 # pop-msg "$res:$instanceid:182" ":184"
			update-diagrootcause -id "RC_$res" -detected $true -parameter $params

		}elseif( ($null -eq $params) ){ #if only parameters is null
			 
			 
			 [string]$instanceid = [string]$instanceid

			# pop-msg ($instanceid.gettype()) "type"
			# pop-msg "$res:186"
			# pop-msg "$res:$instanceid:186" ":186"

			update-diagrootcause -id "RC_$res" -detected $true -iid $instanceid 

		}else{ # if both parameter and instance id is not null

			 [string]$res = [string]$res
			 [string]$instanceid = [string]$instanceid

			 # pop-msg ($instanceid.gettype()) "instance type"
			 # pop-msg "$res:190"
			 # pop-msg ("$instanceid"+":190")
			 # pop-msg ($params.gettype()) "params type"
			
			 # pop-msg "$res:$instanceid:190" "190:"

			
			update-diagrootcause -id "RC_$res" -detected $true -iid $instanceid -parameter $params 

		}
	# pop-msg ("$res,"+$instanceid+",$detected")
	return $detected
}


# function to be placed in every resolver
# usage example : for "RC_WUGenError" ,  runningResolver "WUGenError"
#				: for "RC_WUGenError" and instance id "Ax1234" , runningResolver "WUGenError" "Ax1234"

function runningResolver {

	 param($resolverName ,
	 $instanceid = $null)

	($resolvername) > $global:filename

	if($null -ne $instanceid){
		$instanceid >> $global:filename
	}else{
		"" >> $global:filename
	}

	ResolverRan ($resolverName) ($instanceid)
}


# private funtion to keep the list of which resolver ran already
# already called in another function, no need to call this from anywhere in the pack
function ResolverRan {

	 param($resolverName ,
	 $instanceid = $null)

	
	($resolvername+","+$instanceid) >> $global:resolverRan

}


# function to create helper variable if the computer needs restart
# must be placed in TS_Main.ps1
function CreateRebootFlag(){
	$global:RebootFlag = $false
}

# sets the reboot flag
# usage : must be placed on verifiers
# must be tied with some logic
function Set-RebootFlag ($boolValue=$false){
	$global:RebootFlag = $boolValue
}


# function to be placed in Resolvers, so if restart needed then resolver fails
function check-RebootFlag($showRestart=$false,$restartname="",$restartdesc=""){
	if($global:RebootFlag){
		# Throw [system.IndexOutOfRangeException]  

		if($showRestart){
			 $params = @{}
			 $params.add("FixVerNAME","$restartname")
			 $params.add("FixVerDESC","$restartdesc")
			 # get-diaginput "INT_Restart" -parameter $params
		}
		# Throw [system.NullReferenceException]  
	}

	
}


# sets the state of this verifier ran or not, detected or not
# state should be true/false/null
function set-verifierRan{
	param([string]$id,
	$state,
	[Parameter(Mandatory=$false)][string]$instanceID)

	if(!($instanceID)){
		instanceID = ""
	}

	$fname = "VF_"+$id+"_"+$instanceID
	[string]$state=[string]$state
	($state+"") > $fname

}

# gets the state of this verifier ran or not, detected or not
# state returned should be true/false/null
function get-verifierRan{
	param([string]$id,
	[Parameter(Mandatory=$false)][string]$instanceID)
	
	$state = cat ("VF_"+$id+"_"+$instanceID)
	[string]$state = [string]$state
	$state = $state.Trim()
	if($state -eq ""){
		return $null
	}
	if($state -ieq "True"){
		return $true
	}else{
		return $false
	}
}



# this function will prevent from running the verifier if previous state is found
function retain-PreviousStateOFVerifier($id,$instanceID=""){
	
	$detected = get-verifierRan $name $instanceID
	
	if($detected -eq $null){
		return $true
	}

	if($instanceID -eq ""){
		update-diagrootcause -id $id -detected $detected
	}

	if($instanceID -ne ""){
		update-diagrootcause -id $id -detected $detected -iid $instanceid
	}

	return $false
}



function fileExists($path1){
	return ([system.IO.file]::Exists($path1))
}


# to check whether TS is running or Detecting Additional Problems, only works if the pack is run as elevated
function isRunningDetectingAdditionalProblems($packName = "already.txt"){
	
	# drop a file in the current folder so that it can be checked later
	"once" > ".\$packName"


	# pop-msg "stop here"
	$p1 = dir ($env:windir+"\Temp") |  Sort-Object LastWriteTime -descending # sorting the items of directory in descending order
	$p1 = $p1 |  where { $_.Mode -match "d" } # search for directories only, cause we aren’t interested in files

	if($null -eq $p1){
		return $false
	}

	# pop-msg ($p1.gettype())
	# pop-msg $p1[0]

	if("System.IO.DirectoryInfo" -ieq $p1.gettype()){
		return $false
	}

	# only works if the pack is run as elevated
	$dir1 = (($env:windir+"\Temp")+"\"+$p1[0].Name)
	$dir2 = (($env:windir+"\Temp")+"\"+$p1[1].Name)

	if( (test-path "$dir1\$packName") -and (test-path "$dir2\$packName") ){
		# check if 2 files are present or not, if the both files are present then its a load back
		return $true
	}

	if( (-not(test-path "$dir1\$packName")) -and (test-path "$dir2\$packName") ){
		# check if 2 files are present or not, if the both files are present then its a load back
		return $false
	}

	if( (test-path "$dir1\$packName") -and (-not(test-path "$dir2\$packName")) ){
		# check if 2 files are present or not, if the both files are present then its a load back
		return $false
	}
	
	return $false
	
}

# second load of the troubleshooter, needs a filename to be given as parameter
# example :-
# if(ispostback "wuPack1"){
# do what you need for detecting additional changes	
# } else {
# do what needs for 1st run of rootcauses
# }
function isPostBack($packName){
	return (isRunningDetectingAdditionalProblems ($packName) )
}

# second load of the troubleshooter, needs a filename to be given as parameter, for all of windows 8,7,6 etc
# example :-
# if(is-WTPPostBack "wuPack1"){
# do what you need for detecting additional changes	
# } else {
# do what needs for 1st run of rootcauses
# }
function is-WTPPostBack($packName = "already.txt"){
	$osVer = [Microsoft.Win32.Registry]::GetValue("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion", "CurrentVersion", "")

	if( 6.2 -le $osVer ){ ### windows 8 and above version
		return ( ispostbackOnWin8 ( $packName ) )
	} else { ### windows 7 and below
		return ( ispostback ( $packName ) )
	}
}

# second load of the troubleshooter, needs a filename to be given as parameter
# example :-
# if(ispostbackOnWin8 "wuPack1"){
# do what you need for detecting additional changes	
# } else {
# do what needs for 1st run of rootcauses
# }
function ispostbackOnWin8($packName,$debug=$false){
	[string] $path1 = (Get-Location -PSProvider FileSystem).ProviderPath
	[string] $path1 = $path1 + "\$packName"
	if(test-path $path1){
		# del $path1 -force
		# the file is already so this must be detecting additional problem
		return $true
	}
	"once" > $path1
	if($debug){
		pop-msg ($path1+"::"+(test-path $path1)) "ispostback"
	} 
	return $false
}

# call off the script that checks whether the pack running or not
function calloff(){
	$true > "$env:temp\calloff"
}

#copy necessary files to the temporary folder
function copyFilesToTemp($fileArray){
	foreach($f in $fileArray){
		copy "$f" ("$env:temp\$f")
	}
}


#block the script, until the pack is either finished or cancelled
function block(){
	
	$p1 = dir ($env:windir+"\Temp") |  Sort-Object LastWriteTime -descending # sorting the items of directory in descending order
	$p1 = $p1 |  where { $_.Mode -match "d" } # search for directories only, cause we aren’t interested in files

	 # take the latest directory
	$dir1 = "not null"
	while( $dir1 -ne $null ){
		$dir1 = dir (($env:windir+"\Temp")+"\"+$p1[0].Name)
		"directory there"
	}

	if(test-path ("$env:temp\calloff")){
		del "$env:temp\calloff"
		
		exit
	}
}


# function to run powershell window without black splash, not used anywhere till now, its not working properly
function runInvisibleWindowPowershell($args){
	
	$runthis = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

	
	$args = [string] $args
	# pop-msg "$args" "runInvisibleWindowPowershell"
	$procStartInfo = New-Object System.Diagnostics.ProcessStartInfo($runthis,$args)

	$procStartInfo.RedirectStandardOutput = $true;
    $procStartInfo.UseShellExecute = $true;
               
    $procStartInfo.CreateNoWindow = $false;

	$proc = new-object System.Diagnostics.Process
	$proc.StartInfo = $procStartInfo;
    $proc.Start();
}



# this function "callthis1st" must be called as shown below in TS_Main file

# if(isRunningDetectingAdditionalProblems){
#	calloff (this function is used to cancel the running of "runaftercancel" file)
#	returnBackExecPolicy (this function sets back the exec policy to the state before the pack was run)
# }else{
#	callthis1st (this sets the exec policy to "remotesigned"
#	runAfterCancelProcess ("RunThisAfterCancel.ps1") ($filesToCopy) {this function runsThisAfterCancel.ps1 after the cancel button is hit}
# }

# this function sets powershell exec policy to remote signed
function callthis1st(){
	
	# $execPolicy = get-executionpolicy

	$runthis = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
	[System.Diagnostics.Process]::Start($runthis," get-executionpolicy > $env:temp\execPolicy.txt")

	# runInvisibleWindowPowershell " get-executionpolicy > $env:temp\execPolicy.txt"

	$execPolicy = cat "$env:temp\execPolicy.txt"
	$execPolicy = [string] $execPolicy
	$execPolicy = $execPolicy.Trim()

	
	# pop-msg "$execPolicy"

	if( ($execPolicy -ieq "remotesigned") -or ($execPolicy -ieq "unrestricted") ){
		
	}else{
		# POP-MSG "$EXECPOLICY" 
		[System.Diagnostics.Process]::Start($runthis," set-executionpolicy unrestricted -force")
	#	runInvisibleWindowPowershell " set-executionpolicy remotesigned -force"
	}

	
}

function timeStamp($name,$fileName=( $env:temp+"\perfPrinterTest.txt")){
	($name + "::" + ( Get-Date -Format o ) ) >> $fileName
}
