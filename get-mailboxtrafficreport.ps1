# Script is designed to pull mailbox stats from Exchange Online
# Connect-ExchangeOnline
# Run script
# Output will go to C:\brockit  - Modify if necessary for your application
#
# Written by Jonathan Bullock
# 2024 - 06 - 11


# Define the date range
$startDate = (Get-Date).AddDays(-10)
$endDate = Get-Date

# Define the path for the log file
$logFilePath = "C:\BrockIT\mailboxstats.log"

# Initialize log file
"Script started at $(Get-Date)" | Out-File $logFilePath -Append

try {
    # Get message trace data for all users
    $messageTrace = Get-MessageTrace -StartDate $startDate -EndDate $endDate -PageSize 5000

    # Log the raw message trace data count
    "Total messages returned: $($messageTrace.Count)" | Out-File $logFilePath -Append

    if ($messageTrace -and $messageTrace.Count -gt 0) {
        # Log the first few entries to see what kind of data is being returned
        $messageTrace | Select-Object -First 10 | Format-List | Out-File $logFilePath -Append

        # Inspect the properties of the message trace data to find the correct property for outgoing emails
        $sampleMessage = $messageTrace | Select-Object -First 1
        "Properties of a sample message:" | Out-File $logFilePath -Append
        $sampleMessage | Get-Member | Out-File $logFilePath -Append

        # Update the filter to match outgoing emails based on the Status property
        $outgoingEmailsPerUser = $messageTrace | Where-Object { $_.Status -eq "Delivered" } | Group-Object -Property SenderAddress

        if ($outgoingEmailsPerUser -and $outgoingEmailsPerUser.Count -gt 0) {
            # Prepare the results for export
            $results = $outgoingEmailsPerUser | ForEach-Object {
                [PSCustomObject]@{
                    User  = $_.Name
                    Count = $_.Count
                }
            }

            # Export the results to CSV format
            $results | Export-Csv -Path "C:\BrockIT\mailbox stats.csv" -NoTypeInformation

            "Data successfully exported to CSV at $(Get-Date)" | Out-File $logFilePath -Append
        } else {
            "No outgoing emails found for the specified date range." | Out-File $logFilePath -Append
        }
    } else {
        "No message trace data returned." | Out-File $logFilePath -Append
    }
} catch {
    "An error occurred: $_" | Out-File $logFilePath -Append
}

"Script ended at $(Get-Date)" | Out-File $logFilePath -Append
