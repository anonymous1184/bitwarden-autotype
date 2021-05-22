
; Reformat of
; https://github.com/Lexikos/AutoHotkey-Release/blob/master/installer/source/Lib/EnableUIAccess.ahk

signExe(filename, certName, uia := false)
{
    if !hStore := DllCall("Crypt32\CertOpenStore", "Ptr",10, "UInt",0, "Ptr",0, "UInt",0x20000, "WStr","Root", "Ptr")
        throw
    p := DllCall("Crypt32\CertFindCertificateInStore", "Ptr",hStore, "UInt",0x10001, "UInt",0, "UInt",0x80007, "WStr",certName, "Ptr",0, "Ptr")
    cert := p ? new CertContext(p) : signExe_CreateCert(certName, hStore)
    if uia
        signExe_SetManifest(filename)
    signExe_SignFile(filename, cert, certName)
}

signExe_CreateCert(CertName, hStore)
{
    if !DllCall("Advapi32\CryptAcquireContext", "Ptr*",hProv, "Str",CertName, "Ptr",0, "UInt",1, "UInt",0)
    {
        if !DllCall("Advapi32\CryptAcquireContext", "Ptr*",hProv, "Str",CertName, "Ptr",0, "UInt",1, "UInt",8)
            throw
        prov := new CryptContext(hProv)
        if !DllCall("Advapi32\CryptGenKey", "Ptr",hProv, "UInt",2, "UInt",0x4000001, "Ptr*",hKey)
            throw
        (new CryptKey(hKey))
    }
    loop 2
    {
        if A_Index = 1
            pbName := cbName := 0
        else
            VarSetCapacity(bName, cbName), pbName := &bName
        if !DllCall("Crypt32\CertStrToName", "UInt",1, "Str","CN=" CertName, "UInt",3, "Ptr",0, "Ptr",pbName, "UInt*", cbName, "Ptr",0)
            throw
    }
    VarSetCapacity(cnb, 2*A_PtrSize)
    NumPut(pbName, NumPut(cbName, cnb))
    VarSetCapacity(endTime, 16)
    DllCall("Kernel32\GetSystemTime", "Ptr",&endTime)
    NumPut(NumGet(endTime, "UShort") + 10, endTime, "UShort")
    if !hCert := DllCall("Crypt32\CertCreateSelfSignCertificate", "Ptr",hProv, "Ptr",&cnb, "UInt",0, "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",&endTime, "Ptr",0, "Ptr")
        throw
    cert := new CertContext(hCert)
    if !DllCall("Crypt32\CertAddCertificateContextToStore", "Ptr",hStore, "Ptr",hCert, "UInt",1, "Ptr",0)
        throw
    return cert
}

signExe_DeleteCert(CertName)
{
    DllCall("Advapi32\CryptAcquireContext", "Ptr*",undefined, "Str",CertName, "Ptr",0, "UInt",1, "UInt",16)
    if !hStore := DllCall("Crypt32\CertOpenStore", "Ptr",10, "UInt",0, "Ptr",0, "UInt",0x20000, "WStr","Root", "Ptr")
        throw
    if !p := DllCall("Crypt32\CertFindCertificateInStore", "Ptr",hStore, "UInt",0x10001, "UInt",0, "UInt",0x80007, "WStr",CertName, "Ptr",0, "Ptr")
    return 0
    if !DllCall("Crypt32\CertDeleteCertificateFromStore", "Ptr",p)
        throw
    return 1
}

signExe_SetManifest(file)
{
    xml := ComObjCreate("Msxml2.DOMDocument")
    xml.async := false
    xml.setProperty("SelectionLanguage", "XPath")
    xml.setProperty("SelectionNamespaces", "xmlns:v1='urn:schemas-microsoft-com:asm.v1' xmlns:v3='urn:schemas-microsoft-com:asm.v3'")
    if !xml.load("res://" file "/#24/#1")
        throw
    if !node := xml.selectSingleNode("/v1:assembly/v3:trustInfo/v3:security/v3:requestedPrivileges/v3:requestedExecutionLevel")
        throw
    node.setAttribute("uiAccess", "true")
    xml := RTrim(xml.xml, "`r`n")
    VarSetCapacity(data, data_size := StrPut(xml, "UTF-8") - 1)
    StrPut(xml, &data, "UTF-8")
    if !hupd := DllCall("Kernel32\BeginUpdateResource", "Str",file, "Int",false)
        throw
    r := DllCall("Kernel32\UpdateResource", "Ptr",hupd, "Ptr",24, "Ptr",1, "UShort",1033, "Ptr",&data, "UInt",data_size)
    if !DllCall("Kernel32\EndUpdateResource", "Ptr",hupd, "Int",!r) && r
        throw
}

signExe_SignFile(File, CertCtx, Name)
{
    VarSetCapacity(dwIndex, 4, 0), cert_Ptr := IsObject(CertCtx) ? CertCtx.p : CertCtx
    VarSetCapacity(wfile, 2 * StrPut(File, "UTF-16")), StrPut(File, &wfile, "UTF-16")
    VarSetCapacity(wname, 2 * StrPut(Name, "UTF-16")), StrPut(Name, &wname, "UTF-16")
    signExe_Struct(file_info, "Ptr",A_PtrSize * 3, "Ptr",&wfile)
    signExe_Struct(subject_info, "Ptr",A_PtrSize * 4, "Ptr",&dwIndex, "Ptr",1, "Ptr",&file_info)
    signExe_Struct(cert_store_info, "Ptr",A_PtrSize * 4, "Ptr",cert_Ptr, "Ptr",2)
    signExe_Struct(cert_info, "UInt",8 + A_PtrSize * 2, "UInt",2, "Ptr",&cert_store_info)
    signExe_Struct(authcode_attr, "UInt",8 + A_PtrSize * 3, "Int",false, "Ptr",true, "Ptr",&wname)
    signExe_Struct(sig_info, "UInt",8 + A_PtrSize * 4, "UInt",0x8004, "Ptr",1, "Ptr",&authcode_attr)
    hr := DllCall("MSSign32\SignerSign", "Ptr",&subject_info, "Ptr",&cert_info, "Ptr",&sig_info, "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",0, "UInt")
    if hr != 0
        throw hr
}

signExe_Struct(ByRef struct, arg*)
{
    VarSetCapacity(struct, arg[2], 0), p := &struct
    loop % arg.Length() // 2
        p := NumPut(arg[2], p+0, arg[1]), arg.RemoveAt(1, 2)
    return &struct
}

class CryptContext
{
    __New(p)
    {
        this.p := p
    }
    __Delete()
    {
        DllCall("Advapi32\CryPtreleaseContext", "Ptr",this.p, "UInt",0)
    }
}

class CertContext extends CryptContext
{
    __Delete()
    {
        DllCall("Crypt32\CertFreeCertificateContext", "Ptr",this.p)
    }
}

class CryptKey extends CryptContext
{
    __Delete()
    {
        DllCall("Advapi32\CryptDestroyKey", "Ptr",this.p)
    }
}
