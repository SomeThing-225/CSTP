#Gets any service that uses more the 1% of the cpu process
$NumberOfLogicalProcessors = (Get-WmiObject -class Win32_processor | Measure-Object -Sum NumberOfLogicalProcessors).Sum #Gets the number of cores
$test = (Get-Counter "\Process(*)\% Processor Time").CounterSamples | Where-Object {$_.CookedValue / $NumberOfLogicalProcessors  -gt 1} | Select InstanceName, CookedValue #Gets every processes that is using more the 1% cpu usage

foreach($_ in $test)
{
    echo $_.InstanceName, ($_.CookedValue / $NumberOfLogicalProcessors) #Displays all this services, the number is divided by the number of cores to get cpu %
}



#Check if AMServiceEnabled is enabled if not displays error
if((Get-MpComputerStatus).AMServiceEnabled -ne 1) 
{
	echo "AMServiceEnabled Not Enabled"
}


#The approved programs are Node.JS
$approvedPrograms = $("Node.js") #List of approved programs
foreach($program in Get-ChildItem -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") #Get the registry for all installed programs
{
	foreach($approvedprogram in $approvedPrograms) #loops through all the approved programs and checks if there the same with a installed program if not it displays a error
	{
		if($approvedprogram -ne $program.GetValue("DisplayName"))
		{
			echo "Program: " + $program.GetValue("DisplayName") + " not approved"
		}
	}
}

#The approved programs to run are svchost
$approvedPrograms = $("svchost") #List of approved programs
foreach($service in (Get-Process).ProcessName)#Gets all current running services and checks if there on the allowed list if not displays a warning
{
	foreach($program in $approvedPrograms)
	{
		if($service -ne $program)
		{
			echo "Program: " + $service + " not approved"
		}
	}
}

#Checks if NTP is enabled
if((Get-Item -path "HKLM:\SYSTEM\State\DateTime").GetValue("NTP Enabled") -ne 1)
{
	echo "NTP Not Enabled"
}

#Checks if the current users is the same as the hard coded user
if([Security.Principal.WindowsIdentity]::GetCurrent().Name -ne "12172185")
{
	echo "Not Right User"
}
