
param([string]$certName, [System.IO.FileInfo]$fileName, [string]$clean)

if ($clean -eq "start") {
	Get-ChildItem Cert:\LocalMachine\*\* | Where-Object {$_.Subject -like "CN=$certName*"} | Remove-Item
}

$cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "CN=$certName*" }

if (!$cert) {
	$cert = New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -HashAlgorithm SHA256 -NotAfter (Get-Date).AddMonths(120) -Subject "CN=$certName,O=u/anonymous1184,OU=Bitwarden Auto-Type" -Type CodeSigning
	foreach ($i in @('TrustedPublisher', 'Root')) {
		$store = [System.Security.Cryptography.X509Certificates.X509Store]::new($i, 'LocalMachine')
		$store.Open('ReadWrite')
		$store.Add($cert)
		$store.Close()
	}
}

$exitCode = 0
try {
	Set-AuthenticodeSignature -Certificate $cert -FilePath "$fileName" -HashAlgorithm SHA256 -TimeStampServer http://timestamp.sectigo.com
} catch {
	Add-Type -AssemblyName PresentationCore,PresentationFramework
	[System.Windows.MessageBox]::Show("There was an error while trying to sign the executable.", "Error", 0, 16)
	$exitCode = 1
}

if ($clean -eq "end") {
	Get-ChildItem Cert:\LocalMachine\*\* | Where-Object {$_.Subject -like "CN=$certName*"} | Remove-Item
}

Exit $exitCode
