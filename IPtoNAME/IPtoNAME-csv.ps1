####################################################################################################
# 
#   Lookup the DNS FQDN for a list of IP Addresses output from Splunk report
#
#   script takes a CSV file in the format:
#          client_ip,count
#
#   and creates a CSV in the format:
#          client_ip,client_name,count
#
#   This uses PTR record lookups, building a scrastch txt file as it goes.
#
#    28/April/2021 - Jay.Christopherson@Emerson.com - Created script and optimized it
#                        notes:  I run it in the Windows PowerShell ISE
#                                The txt file could probably be the final output, but script reads in and rebuilds to make a nicly formated csv
#                                the name may consist of 0 or more FQDN entries. if there are two or more, they are seperated by spaces
#                                   in most cases, there should not be more than one PTR record for each IP address.
####################################################################################################

#
#  Files
#

$infile = "./ip-test.csv"
$outfile = "./ip-test-out.txt"
$outcsv = "./ip-test-out.csv"

#
# Remove old output files if they exist
#

if (Test-Path $outfile) {
    Remove-Item $outfile
    write-host "$outfile has been deleted"
}
if (Test-Path $outcsv) {
    Remove-Item $outcsv
    write-host "$outcsv has been deleted"
}

# Read in the input file 
$csv = (Import-Csv $infile -Delimiter ',')

# Count the number of items in the csv
$counter = ($csv | Measure-Object).count

# create file header line
Add-Content $outfile "client_ip,client_name,count"


# start resolving the addresses
ForEach ($line in $csv) {
    $ErrorActionPreference = "silentlycontinue"
    $name = $null

    $counter--

    # Map the input line from the csv to simple variables to make it easier
    # If the input csv has more columns that should be preserved add them here ann to the following Add-Content line
    $ip = $line.client_ip
    $count = $line.count

    $name = (Resolve-DnsName -Name $ip -DnsOnly).NameHost

    Write-Host "$counter - Resolved  $ip to $name"
  
    Add-Content $outfile "$ip,$name,$count"

}

Write-Host "Finished resolving addresses."

Write-Host "creating formatted csv file: $outcsv"

$resultcsv = (Import-Csv $outfile -Delimiter ',')
$resultcsv | Export-Csv $outcsv

Write-Host "Done."

####################################################################################################

