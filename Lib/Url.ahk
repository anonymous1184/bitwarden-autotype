
Url_Get(hWnd, isIE := false)
{
	static cache := []
	if (!cache.HasKey(hWnd) || isIE)
	{
		oAcc := Acc_ObjectFromWindow(hWnd)
		cache[hWnd] := Url_GetAddressBar(oAcc)
	}
	try
		return cache[hWnd].accValue(0)
	catch e
	{
		cache.Delete(hWnd)
		if InStr(e.Message, "800401FD")
			return Url_Get(hWnd)
	}
}

Url_GetAddressBar(oAcc)
{
	; Firefox + Chromium-based + IE || Min Browser
	if (oAcc.accRole(0) = 42 && InStr(oAcc.accName(0), "Address"))
		|| (oAcc.accRole(0) = 15 && oAcc.accName(0) != "Min")
	{
		return oAcc
	}
	for _,accChild in Acc_Children(oAcc)
	{
		oAcc := Url_GetAddressBar(accChild)
		if IsObject(oAcc)
			return oAcc
	}
}

Url_Split(Url, ByRef Host, ByRef Domain, ByRef Schema := "", ByRef Resource := "")
{
	RegExMatch(Url, "S)(?<Schema>.+:\/\/)?(?<Host>[^\/]+)(?<Resource>.*)", $)
	Schema := $Schema
	Host := $Host
	Resource := $Resource

	; RegEx is no longer an option because:
	; 3-letter domains + SLD are confused as a TLD + SLD
	; Expected: git.io
	; Returned: example.git.io
	; Same for: example.com.mx

	; Thus a validation for actual TLDs is needed:

	$Domain := StrSplit($Host, ".")

	p1 := $Domain.Pop(), len1 := StrLen(p1)
	p2 := $Domain.Pop(), len2 := StrLen(p2)
	p3 := $Domain.Pop()

	; No subdomain || Standard TLD
	if (!p3 || len1 >= 3)
	{
		Domain := p2 "." p1
		return
	}

	validTld := Url_ValidTld(p2)

	; 3-letter TLD || 3-letter TLD + SLD || 2-letter TLD + SLD
	if (validTld || (validTld && len1 = 2) || (len2 = 2 && len1 = 2))
		Domain := p3 "." p2 "." p1
	else ; Regular domain + SLD
		Domain := p2 "." p1
}

Url_ValidTld(p2)
{
	; https://data.iana.org/TLD/tlds-alpha-by-domain.txt
	; Version 2021093002, Last Updated Fri Oct  1 07:07:01 2021 UTC
	;TODO: Create an automated updater & parser (storage: settings.ini).
	if p2 in % "AAA,ABB,ABC,ACO,ADS,AEG,AFL,AIG,ANZ,AOL,APP,ART,AWS,AXA,BAR"
		. ",BBC,BBT,BCG,BCN,BET,BID,BIO,BIZ,BMS,BMW,BOM,BOO,BOT,BOX,BUY"
		. ",BZH,CAB,CAL,CAM,CAR,CAT,CBA,CBN,CBS,CEO,CFA,CFD,COM,CPA,CRS"
		. ",CSC,DAD,DAY,DDS,DEV,DHL,DIY,DNP,DOG,DOT,DTV,DVR,EAT,ECO,EDU"
		. ",ESQ,EUS,FAN,FIT,FLY,FOO,FOX,FRL,FTR,FUN,FYI,GAL,GAP,GAY,GDN"
		. ",GEA,GLE,GMO,GMX,GOO,GOP,GOT,GOV,HBO,HIV,HKT,HOT,HOW,IBM,ICE"
		. ",ICU,IFM,INC,ING,INK,INT,IST,ITV,JCB,JIO,JLL,JMP,JNJ,JOT,JOY"
		. ",KFH,KIA,KIM,KPN,KRD,LAT,LAW,LDS,LLC,LLP,LOL,LPL,LTD,MAN,MAP"
		. ",MBA,MED,MEN,MIL,MIT,MLB,MLS,MMA,MOE,MOI,MOM,MOV,MSD,MTN,MTR"
		. ",NAB,NBA,NEC,NET,NEW,NFL,NGO,NHK,NOW,NRA,NRW,NTT,NYC,OBI,OFF"
		. ",ONE,ONG,ONL,OOO,ORG,OTT,OVH,PAY,PET,PHD,PID,PIN,PNC,PRO,PRU"
		. ",PUB,PWC,QVC,RED,REN,RIL,RIO,RIP,RUN,RWE,SAP,SAS,SBI,SBS,SCA"
		. ",SCB,SES,SEW,SEX,SFR,SKI,SKY,SOY,SPA,SRL,STC,TAB,TAX,TCI,TDK"
		. ",TEL,THD,TJX,TOP,TRV,TUI,TVS,UBS,UNO,UOL,UPS,VET,VIG,VIN,VIP"
		. ",WED,WIN,WME,WOW,WTC,WTF,XIN,XXX,XYZ,YOU,YUN,ZIP"
		return true
}
