function CPUUsage{
	try{
		#Gets any service that uses more the 5 % of the cpu process
		#Can Error out if the counter process doesnt update correctly
		$NumberOfLogicalProcessors = (Get-WmiObject -class Win32_processor | Measure-Object -Sum NumberOfLogicalProcessors).Sum #Gets the number of cores
		$test = (Get-Counter "\Process(*)\% Processor Time").CounterSamples |  Where-Object {$_.CookedValue / $NumberOfLogicalProcessors  -gt 5} |Select InstanceName, CookedValue #Gets every processes that is using more the 1% cpu usage
		foreach($_ in $test)
		{
			Write-Host $_.InstanceName, ($_.CookedValue / $NumberOfLogicalProcessors) #Displays all this services, the number is divided by the number of cores to get cpu %
		}
	}
	catch{
	}
}


function CheckAMService{
	#Check if AMServiceEnabled is enabled if not displays error
	if((Get-MpComputerStatus).AMServiceEnabled -ne 1) 
	{
		Write-Host "AMServiceEnabled Not Enabled"
	}
}

function CheckApprovedInstallPrograms{
	#The approved programs are Node.JS
	$approvedPrograms = $("Node.js") #List of approved programs
	$LoadFromFile = 1 #If one wants to load from a file or not if its set to 0 then it will takes the approvedPrograms from the list above
	#It will create a file if it doesnt exits it will dump all current install software and write it to a file
	
	#Checks if load file is set to 0 if not checks if the file exits
	if($LoadFromFile -eq 0)
	{
		#Clears the file
		echo "" | Out-File -FilePath "Approved-Programs-Installed.txt" 
		foreach($program in Get-ChildItem -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") #Get the registry for all installed programs
		{
			$program.GetValue("DisplayName") | Out-File -FilePath "Approved-Programs-Installed.txt" -append #Writes the service to the file
		}
	}
	else
	{
		if(Test-Path -Path "Approved-Programs-Installed.txt")
		{
			$approvedPrograms = Get-Content "Approved-Programs-Installed.txt"
		}
		else{
			#Clears the file
			echo "" | Out-File -FilePath "Approved-Programs-Installed.txt" 
			foreach($program in Get-ChildItem -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") #Get the registry for all installed programs
			{
				$program.GetValue("DisplayName") | Out-File -FilePath "Approved-Programs-Installed.txt" -append #Writes the service to the file
			}
			$approvedPrograms = Get-Content "Approved-Programs-Installed.txt"
		}
	}
	
	
	foreach($program in Get-ChildItem -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") #Get the registry for all installed programs
	{
		$check = 0
		foreach($approvedprogram in $approvedPrograms) #loops through all the approved programs and checks if there the same with a installed program if not it displays a error
		{
			#Checks if a service is with in the list
			if($approvedprogram -eq $program.GetValue("DisplayName"))			
			{	
				$check = 0
				break
			}
			else
			{
				$check = 1
			}
		}
		if($check -eq 1)
		{
			try{
				Write-Host "Program:" $program.GetValue("DisplayName").replace("\n","").replace("  "," ") "not approved to be installed"
			}
			catch{}
		}
	}
}

function CheckApprovedRunningPrograms
{
	#The approved programs to run are svchost
	$approvedPrograms = $("svchost") #List of approved programs
	$LoadFromFile = 1 
	#If one wants to load from a file or not if its set to 0 then it will takes the Approved-Programs-Service.txt from the list above
	#It will create a file if it doesnt exits it will dump all current software that is running and write it to a file
	
	#Checks if load file is set to 0 if not checks if the file exits
	if($LoadFromFile -eq 0)
	{
		#Clears the file
		echo "" | Out-File -FilePath "Approved-Programs-Service.txt" 
		foreach($program in (Get-Process).ProcessName | Unique) #Get all current running service
		{
			$program | Out-File -FilePath "Approved-Programs-Service.txt" -append #Writes the service to the file
		}
	}
	else
	{
		if(Test-Path -Path "Approved-Programs-Service.txt")
		{
			$approvedPrograms = Get-Content "Approved-Programs-Service.txt"
		}
		else{
			#Clears the file
			echo "" | Out-File -FilePath "Approved-Programs-Service.txt" 
			foreach($program in (Get-Process).ProcessName | Unique) #Get the registry for all installed programs
			{
				$program | Out-File -FilePath "Approved-Programs-Service.txt" -append #Writes the service to the file
			}
			$approvedPrograms = Get-Content "Approved-Programs-Service.txt"
		}
	}
	

	
	foreach($service in (Get-Process).ProcessName | Unique)#Gets all current running services and checks if there on the allowed list if not displays a warning
	{
		$check = 0
		foreach($program in $approvedPrograms) #loops through all the approved programs and checks if there the same with a installed program if not it displays a error
		{
			#Checks if a service is with in the list
			if($service -eq $program)
			{	$check = 0
				break
			}
			else
			{
				$check = 1
			}
		}
		if($check -eq 1)
		{
			try{
				Write-Host "Service:" $program.replace("\n","").replace("  "," ") "not approved to run"
			}
			catch{}
		}
	}
}

function CheckNTP{
	#Checks if NTP is enabled
	if((Get-Item -path "HKLM:\SYSTEM\State\DateTime").GetValue("NTP Enabled") -ne 1)
	{
		Write-Host "NTP Not Enabled"
	}
}

function CheckUser
{
	#Checks if the current users is the same as the hard coded user
	if([Security.Principal.WindowsIdentity]::GetCurrent().Name -ne "12172185")
	{
		Write-Host "Not Right User"
	}
}

CPUUsage
CheckAMService
CheckApprovedInstallPrograms
CheckApprovedRunningPrograms
CheckNTP
CheckUser
