Admin Powershell Scripts

-findADLockout.ps1 is a Powershell tool similar to the Microsoft AD Lockout Tool, it will find lockouts
 across multiple domain controllers and only unlock the user from those dc's, it also has a error checking to tell
 you if any dc's aren't communicating from the pulled list and what there names are, if statement included to blacklist
 dc's if needed.

-adCompPoll.ps1 is used to search for computers by partial name and across multiple Domain Controllers(DC's), usefull if you suspect a possible AD replication delay/issue.

-timeTracking.ps1 is for creating a log based on action description and automatic timestamps, saved to a csv file ever iteration of the loop in case of power outage.

-decrapify.ps1 and apps.txt are a script to remove Windows 10 extra appx packages and the associated text file the script reads from, please make the names in the text file unique enough so as not to accidentally remove desired programs(updated thanks to M Boyle over at Spiceworks)
