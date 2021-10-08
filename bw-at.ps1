
param([string]$certName, [System.IO.FileInfo]$fileName)

if (!($cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=$certName" })) {
	$cert = New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -HashAlgorithm SHA256 -NotAfter (Get-Date).AddMonths(120) -Subject "$certName" -Type CodeSigning
	foreach ($i in @('TrustedPublisher', 'Root')) {
		$store = [System.Security.Cryptography.X509Certificates.X509Store]::new($i, 'LocalMachine')
		$store.Open('ReadWrite')
		$store.Add($cert)
		$store.Close()
	}
}
Set-AuthenticodeSignature -Certificate $cert -FilePath "$fileName" -HashAlgorithm SHA256 -TimeStampServer http://timestamp.sectigo.com
