
; This file was modified.

;
; cJson.ahk 0.4.0-git-built
; Copyright (c) 2021 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/cJson.ahk
;
; MIT License
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;

class JSON
{
	static version := "0.4.0-git-built"

	BoolsAsInts[]
	{
		get
		{
			return NumGet(this.lib.bBoolsAsInts, "Int")
		}

		set
		{
			NumPut(value, this.lib.bBoolsAsInts, "Int")
			return value
		}
	}

	_init()
	{
		qpc()
		if (this.lib)
			return
		this.lib := this._LoadLib()

		; Populate globals
		NumPut(&this.True, this.lib.objTrue, "UPtr")
		NumPut(&this.False, this.lib.objFalse, "UPtr")
		NumPut(&this.Null, this.lib.objNull, "UPtr")

		this.fnGetObj := Func("Object")
		NumPut(&this.fnGetObj, this.lib.fnGetObj, "UPtr")

		this.fnCastString := Func("Format").Bind("{}")
		NumPut(&this.fnCastString, this.lib.fnCastString, "UPtr")
		return qpc()
	}

	_LoadLib() {
		CodeBase64 := ""
		. "yLUEAQALAFVIieVICIHswABQSIlNEABIiVUYTIlFIABEiciIRShIixBFEEiLAAgFlR0BAHyLAEg5wg+EIrwAVsdF/AF660cASIN9GAB0LYsARfxI"
		. "mEiNFY0hAE5ED7YEAGZFGAEBYI1IAkiLVRgASIkKZkEPvtAgZokQ6w8AGyCLEACNUAEBCIkQg2hF/AEFP00APwE+hAjAdaUCfYlFoEgIi00gAkON"
		. "RaBJAInISInB6EYjCwCOAnkZEGjHACIABQ5luAGv6RYJAACYxkX7gGWBbFAwgwMkQCAAbHVbAAwBxxRF9AJsNYQQGItFAvSATMHgBUgB0E2ARrCA"
		. "C4ABUBCAC4MMwAEADQCJlMCIRQD7g0X0AYB9+0gAdBMBGWPQCC18CrIDViyCDwhBuFthATEGQbh7AbsPYEQCiY9fgH0oAHRkKMdF8Iy78IKbJhxN"
		. "sbvwwF3DD+Ybx13HZEXswkqlBgInREHsAUlBqIN97AAPjhbKgS+YYSyUMWbHRWrojDHogiFfgCGvMehLgDHDDx+IMesvmSYgIZQmecdF5IImaMeU"
		. "ReDMKODCGL4a8Sg24MAoww9+wA/FKINFAuTABTA7ReR9kAQPtsCQ8AGEwA9chOhA6UFcBpEwQZmNbomcW1C9QAGowA/B0ZilyNGY5Gj+HyUKHDQK"
		. "zOn+Q1SJCunqYALqE0Y44hNBbMdF3Kwm3NmiHooZvyavJtygI+MHrkrgBwiDhRqQiBqQhBqWKYYa1iQsLA3rG2YK0+QJZAm9IHsJOlAuv04BLTSL"
		. "QBiD+AF1J2EwgBAKEFweIHEXA8NiMOMEBg+Fn+BDYwUZYbMJGKAB4Jdpx0Xq2Gwv2GInFwAEfy9tLybYYC/jB9cXZy/pi1oCaQ9tQANkD9RsD9Td"
		. "YgegAAR/D20P1GAP4weqYGkPD2oPAWcP0GwP2tBiByp/D3AP0GAP4wcU6hZoD5NicjCNSJoBQApNQePAEABMgAYhQQqJTCQgwTWt+DD//+loxDPC"
		. "NQV1Vh9kBSw7YiE7PUkFAggPhYOjbahIjZVQcP///+EEimCaxxRFzCIcSCMcLkiLRJV4wAOLRcwAFQEwwEyNBAAbbRxBD3S3EFMczJAACgRQXQ8A"
		. "twBmhcB1nukqqlI8yBwVyBIR3RW3HxUfFe0GyBAV8wOd8AN7WzwqEW+gDu8zD07aBewH0AWoSPF2D4xE+f+i//FcD4Td4gzE7AxyxOII8BTvDO8M"
		. "DQfE+wAH8wOw8ANXczGUcmMBknXJBrzCAobPBs8Gzga8i8AG8wNGyAaDRcBwAUDAO0UwfJCshV0dpIV9r4WvhaiRSIHEcQEMXcOQCgDsog4AVYXA"
		. "ozBBLI2sJIBCpIqNs6SVESRIi4VhAIWgGxS1AEjHQAjyEe2QCYWiAgEKUAAK0wARUYN1ATEpg/ggdNUtAYgKdMItAQ10ry0BCAl0nC0Bew+FKUfC"
		. "VK8HogfHRVDCEMcURVh0AGByAIsFA0fhOAE/QaMF9f7QAMeIRCRAUwJEJDiCAACNVTBIiVQkMFWAAFCBACiQASAht0EqufEBQZIWuqICicGoQf/S"
		. "8Bc4UGxozxA/zxDPEM8QzxDPECcBfQ+shMLyR2kBhfCHrF4BQIP4InQKuCAQ/3jpZhGBDqG5YAfCHugA9/3//4XAdCL9AwJFAQLvDO8M7wzvDO8M"
		. "y+8MJAE6FQrEEA8ICAjbUijHCzrDC7QDiLIDsDKki40DLEVoxEkCYA1/fxqPDY8Njw2PDY8NJwEszHUdbwdjB+nC0AtAkHOMHdUMug+fEJwQsDkJ"
		. "AbY5i1VoSIlQCA2z0n3KA5MFWw+FZd9CeD8F9DPyyXAA+HQAUkJpEDPD+/kztdEA/zONdlXQxfMz8P8z/zPgGdjh8DNwx4WsMAGBAh8aPx8aHxof"
		. "Gh8aHxonAV0PNoRh45803kdQKCfH+pkpJxUOMQLiJouVcQz1UA1wRCftMBgvDS8NLw0DLw0iAQq2AGaD+A10r0iLAIXAAAAASIsAiA+3AACQCXSc"
		. "DZAILHUkB0hIjVACQQU0iRCDhawAEAFA6ar+//+QDW5dEHQKuP8AAOk+DRcBKhOCAAnIAAlmxwAGCQEjAQtIi1VwSBCJUAi4AAsA6QGDCjwDWSIP"
		. "hRMFGlOxBReJhaACCQRYlQINgwBbB3YIAOlZBA0xSIXAdYRdggwPP1wwD4X2AyE/hFZ1NLcACYI8gROJAkKAPCKWIFzpxwovhDoUI1wXI4BVECMv"
		. "FCMvlxE5kBFipZQRCJcR8gKPEWaUEaoMlxGrkBFulBEKlxGqZJARcpQRDZcRHZARTnSUEUK4kxHWAY8RdTgPhYWKBY6ZxBUAANjHhZwBy8HLO4MM"
		. "gQbBgBHB4ASJwkUKj6aIL35CTQI5fy/HB4NiB8cDAdCD6DDpCYzprqNrKghAfj9NAihGfyyaCjeJCutc1c0HYC8KZjwKVyoKhHkUtQjXKYNCKAGD"
		. "vSHBAAMPjrhAmkiDUSIIAus64wd16QcQuEiNSucHIYojPkggPpqNAxMSUC5gl5D7QAvFRZJIJgcpyEiCFuMCwEAISIPoBMs8dReJI6XXB28xLXQu"
		. "bj4YD44MiqfkPg+P9XHgoMeFmMEgh6YADxSZBqjHQCAgsAx1IuMG56Ek36KDBjB1ITjTCk1+IXAOMA+OidACOX8YdutMhigAvYnQSADB4AJIAdBI"
		. "ATDASYnAaQwgNYuVBWMMCqAHSA+/wEx0AcBgD9AFCCPFTGYfCW4Ofo4lTFMGAABhDuEuD4Xm2BtIPmaAD+/A8kgPKsEUsWEC8g8R4EAGMQXAM0KU"
		. "xDPrbIuVYQGJgtDAGwHQAcCJQgO9+BuYgHcCDOAL4ADScAABEgRmDyjI8g9eAso2BxBACPIPWJbBPAhcEBcPJI5q6h8JYwFldJ4CRQ+F+HePTf0Q"
		. "swIUVyL/Ef8RxqyFkw8qASohkwEBTweJQwfrMj0DK3Uf3gRbHy1LEROvIYQhOrI1jGFUWus6i5WxAMYbQXufKZwbRBEeMQNfB18HfhCgx4WIhCLH"
		. "hYRxVQcci5VRASgj4QCDKQICAYtiADsyBnzWZIC9og90Klkh4BfJnVAjjVEDECMaIusolwISSIMaDyryBfIPWS+9JPkdwaXVOotSREiYSEgPrzk4"
		. "6zg6AwW+db8GsAahA78GugYMtyIUAwBTU6EPfPh0D5SF35ITgJUTUouyABGQCY0V0hADD7YEMBBmD75BCpgDOcJ9Ja9LWgWdZqEE8BYWBYABFAWE"
		. "wHWXD7YFAGLk//+EwHQdn8kKqFLSPxURZIUVDgMHGVdLBfwiNkNQiwXuodEAicH/0lMPq/+GIPhmD4XTUQ9FfKEiD0yLRXzSCeewAhv/DvsOW/88"
		. "9w5FfAEttQSbtASQDqCQDnjjt58OTGGeDgSjBpgO8lQHLZMO5IIBlg7BLzP4bigPhaWSDngSBkmLtEV40gkDnw6XDgeSDmzrdG8OZQ54YA6DBLpr"
		. "MSdjDqPsC1X4yOMLQyXqCzXqC+sFUgdIgcTEMLAJXcOQBwCkKQcPAA8AAgAiVW5rbgBvd25fT2JqZUBjdF8ADQoQCSIB1QB0cnVlAGZhAGxzZQBu"
		. "dWxsAecCVmFsdWVfAAAwMTIzNDU2NwA4OUFCQ0RFRgAAVUiJ5UiDxACASIlNEEiJVQAYTIlFIMdF/A0DU0XAURFbKEiNTQAYSI1V/EiJVEAkKMdE"
		. "JCDxAUFiuTEsSYnIcRJgAk2AEP/QSMdF4NIAKMdF6HQA8LQEIEg4iUXg4ABTiaIFTItAUDCLRfxIEAVAUdMCRCQ4hQAwggCN/FXgRgfAV0AHogdi"
		. "FXGWYE0QQf/S0QWE73V+HqIGgZfCGGAG5ADRGOtiYKcCA3VTtQEBDICwSDnQfUBu1AK68Bqif0IbOdB/4FNF8Q8s2ElwiFMH6EE2hcC0dA+gAdiw"
		. "7lADUjAGwBCQSIPsgBge8xVs7GDxFeQVZrIREAWJFEX4oBYUgASLTRiAicq4zczMzDBTAMJIweggicLBBOoDJl4pwYnKiQDQg8Awg238AQSJwjET"
		. "mGaJVEUAwIuitABFGInCuM3MzADMSA+vwkjB6AAgwegDiUUYgwB9GAB1qUiNVQDAi0X8SJhIAQDASAHQSItVIABJidBIicJIiwBNEOgB/v//kIBI"
		. "g8RgXcOQBgAAVUiJ5UiD7HAASIlNEEiJVRgATIlFIMdF/AABAADprgIAAEiLQEUQSItQGAOswUTgBQFXiUXQAQ9jAwBhAR1AMEg5wg8AjZoBAABm"
		. "x0UWuAI0ABpAAFBF8MYARe8ASIN98AAEeQgACgFI913wMMdF6BQAXwCU8EgIumdmAwBIichICPfqSACuwfgCSQCJyEnB+D9MKWbAAbwBE+ACAXgA"
		. "1ikAwUiJyonQg8AAMINt6AGJwosARehImGaJVEVCkJgnSMH5PwAbSAopgV3wAkd1gIB9MO8AdBCBIoMhx0TQRZAtAIChkIIHhKEAiUXAxkXnAMdE"
		. "ReCBiYtF4IAMjUYUAXEBDw+3EAQJDAEBCRhIAcgPtwAgZjnCdW8PFQBmcIXAdR6JC4AXhQsGkYAyAes6kxp0IpMaAHQKg0XgAelmAv9AdoB95wAP"
		. "hDL2AlZFIMB+wC4QuLHAZADpAUABCmw4AWwMjMrDCoVqyMZF39XAOdjDOdiGG8jFOYIE39A5jQrFOccFyznfwjlRDRfBOVENwTnYxjnfAHSCEs04"
		. "6yCDRfwAcoUIOSACOTv9//+ApEFAOoPEcF3DwruBbOyQAQSEvEjEdsAB6E3EAfDBAcCy4AUCwPJADxAA8g8RQIXHVEXAhAjIxAHQwgGND4BnQIqA"
		. "AwEjSIsFhADm//9IiwBMixRQMEADdkEDx0QkokADDUQkOAICiwAfsIlUJDDB7QECKEAGUiABEEG5wQdBwi26AYIKicFB/9JIgfbEAS7wd0DpdwAX"
		. "ABmgeI+jbIEhAAjkXg+Jm39vCXlvuDDgBynQg21u/KJvwIKhb8C/b6lvDzyFemA5YQgjCGBvwC14AOmAXxPfgh8T2oLHJEXsIS7rUOABGAAsdDaL"
		. "qgAL7EIBTI3MBAJiVGArjUhAAWE5BApBAGVmiRDrD0HhU4sAjVABAQGJYBCDRewBFAlHY45t5VRAJzzkOyDpOwMTHAGvD2bHACIA6QjGBEOAyA/p"
		. "9AMjQSENoIP4InVmYwgZcghsXADuF1wOkMMLSg58nUoOXF8OXw7IBekdUA46CUoOCF8OXw7GBWIAbOmq4+FKDpZk5EMODIdfDl8OxgVmAOk3UA76"
		. "IyoHCi8HLwcvBy8H4gKwbgDpxABILQewMwF9JAcNLwcvBy8HLwfiAnJIAOlRLwfpPSoHCR8vBy8HLwcvB+ICdADpHt50cikH9HAkBx9+DfHHAH5+"
		. "fP8H/wf+B+8CzeECde8CpAYPt/FKkW1CGMBOicHojKFINN3DBB7PBGAAYAMSL0cBCAxFEBFKEgyFwA+FfPz7QGhfCXg8PgThoiAv6Wb2SGBU1WaJ"
		. "AGaNBRyS89AFUFTEo+syD8C3RRCD4A/Sp8BVwVBOtgBmD76So5JZwugRAmbB6AQRBNF7AIN9/AN+yMdFIvhgPADrP7MKJYsARfhImEQPt0Rj4Hdu"
		. "C0SJwr8P4FZtwvjQBPgAebslVVUM"

		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/

		CompressedSize := VarSetCapacity(DecompressionBuffer, 4221, 0)
		if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
			throw Exception("Failed to convert MCLib b64 to binary")
		if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 11072, "Ptr"))
			throw Exception("Failed to reserve MCLib memory")
		if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 11072, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize := 0, "UInt"))
			throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 11072, "UInt", 0x40, "UInt*", OldProtect := 0, "UInt")
			Throw Exception("Failed to mark MCLib memory as executable")
		Exports := {}
		for ExportName, ExportOffset in {"bBoolsAsInts": 0, "dumps": 16, "fnCastString": 2608, "fnGetObj": 2624, "loads": 2640, "objFalse": 7616, "objNull": 7632, "objTrue": 7648} {
			Exports[ExportName] := pCode + ExportOffset
		}
		return Exports
	}

	Dump(obj, pretty := 0)
	{
		if (!IsObject(obj))
			throw Exception("Input must be object")
		size := 0
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		VarSetCapacity(buf, size*2+2, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		return StrGet(&buf, size, "UTF-16")
	}

	Load(ByRef json)
	{
		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
		VarSetCapacity(pJson, A_PtrSize)
		NumPut(&_json, &pJson, 0, "Ptr")

		VarSetCapacity(pResult, 24)

		if (r := DllCall(this.lib.loads, "Ptr", &pJson, "Ptr", &pResult , "CDecl Int")) || ErrorLevel
		{
			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson)-&_json)//2, Chr(NumGet(NumGet(pJson), "short"))))
		}

		result := ComObject(0x400C, &pResult)[]
		if (IsObject(result))
			ObjRelease(&result)
		return result
	}

	True[]
	{
		get
		{
			static _ := {"value": true, "name": "true"}
			return _
		}
	}

	False[]
	{
		get
		{
			static _ := {"value": false, "name": "false"}
			return _
		}
	}

	Null[]
	{
		get
		{
			static _ := {"value": "", "name": "null"}
			return _
		}
	}
}

