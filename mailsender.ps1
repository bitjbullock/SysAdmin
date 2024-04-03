# Basic script to send a singular email with an attachment using SMTP2GO to a predefined recipient
#
# Written by Jonathan Bullock
# 2024 - 04 - 03


# Load assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# SMTP2go configuration
$smtpServer = "mail.smtp2go.com"
$smtpPort = 2525  
$smtpUser = "smtp2go-username"
$smtpPass = "smtp2go-password"
$fromEmail = "sender@domain.com"  # SMTP2go email
$toEmail = "recipient@domain.com"  # Pre-defined recipient email

# Create the actual Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Send File via Email"
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = "CenterScreen"

# Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Drop a file below and click Send"
$label.Location = New-Object System.Drawing.Point(10,10)
$label.Size = New-Object System.Drawing.Size(280,20)
$form.Controls.Add($label)

# Add a text box for file path display (read-only)
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(360,20)
$textBox.ReadOnly = $true
$form.Controls.Add($textBox)

# Add a send button
$sendButton = New-Object System.Windows.Forms.Button
$sendButton.Location = New-Object System.Drawing.Point(10,70)
$sendButton.Size = New-Object System.Drawing.Size(75,23)
$sendButton.Text = "Send"
$form.Controls.Add($sendButton)

# File drop / attach
$form.AllowDrop = $true
$form.Add_DragEnter({
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [Windows.Forms.DragDropEffects]::Copy
    }
})
$form.Add_DragDrop({
    $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
    $textBox.Text = $files[0]  # Assuming only one file is dropped
})

# Send button click event
$sendButton.Add_Click({
    $attachment = $textBox.Text
    if (Test-Path $attachment) {
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $smtpUser, (ConvertTo-SecureString $smtpPass -AsPlainText -Force)
        
        # Sending email
        Send-MailMessage -From $fromEmail -To $toEmail -Subject "File sent via PowerShell" -Body "See attached file." -Attachments $attachment -SmtpServer $smtpServer -Port $smtpPort -Credential $credentials -UseSsl

        [System.Windows.Forms.MessageBox]::Show("Email Sent Successfully", "Success")
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("Please drop a file first.", "Error")
    }
})

# Show the Form
$form.ShowDialog()
