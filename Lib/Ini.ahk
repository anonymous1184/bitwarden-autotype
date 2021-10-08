
Ini(Path, Atomic := true)
{
	return new Ini_File(Path, Atomic)
}

class Ini_File extends Object_Sortable
{

	AtomicGet()
	{
		return this.__sync
	}

	AtomicSet(Mode)
	{
		for name in this
			this[name].AtomicSet(Mode)
		this.__sync := !!Mode
		return this.__sync
	}

	Commit()
	{
		IniRead buffer, % this.__path
		sections := new Object()
		loop parse, buffer, `n
			sections[A_LoopField] := true
		for name in this.__data
		{
			this[name].Commit()
			sections.Delete(name)
		}
		for name in sections
			IniDelete % this.__path, % name
	}

	Delete(Name)
	{
		if (this.__sync)
			IniDelete % this.__path, % Name
	}

	__New(Path, Sync)
	{
		ObjRawSet(this, "__path", Path)
		ObjRawSet(this, "__sync", false)
		IniRead buffer, % Path
		loop parse, buffer, `n
		{
			name := A_LoopField
			IniRead data, % Path, % name
			this[name] := Ini_Section(Path, name, data)
		}
		this.AtomicSet(Sync)
	}

	__Set(Key, Val)
	{
		if (IsObject(Val) && ObjGetBase(Val).__Class != "Ini_Section")
		{
			obj := Ini_Section(this.__path, Key, Val, this.__sync)
			this[Key] := obj
			return obj ; Overload Base.__Set
		}
	}

}

Ini_Section(Parameters*)
{
	return new Ini_Section(Parameters*)
}

class Ini_Section extends Object_Sortable
{

	AtomicGet()
	{
		return this.__sync
	}

	AtomicSet(Mode)
	{
		Mode := !!Mode
		this.__sync := Mode
		return Mode
	}

	Commit()
	{
		IniRead buffer, % this.__path, % this.__name
		keys := new Object()
		loop parse, buffer, `n
		{
			key := StrSplit(A_LoopField, "=")[1]
			keys[key] := true
		}
		for key,val in this
		{
			keys.Delete(key)
			this._Write(key, val)
		}
		for key in keys
			IniDelete % this.__path, % this.__name, % key
	}

	Delete(Key)
	{
		if (this.__sync)
			IniDelete % this.__path, % this.__name, % Key
	}

	__New(Path, Name, Data, Sync := false)
	{
		ObjRawSet(this, "__path", Path)
		ObjRawSet(this, "__name", Name)
		ObjRawSet(this, "__sync", Sync)
		if !IsObject(Data)
			this._ToObject(Data)
		for key,val in Data
			this[key] := val
	}

	__Set(Key, Val)
	{
		if (this.__sync)
			this._Write(Key, Val)
	}

	_ToObject(ByRef Data)
	{
		copy := Data
		Data := new Object()
		loop parse, copy, `n
		{
			pair := StrSplit(A_LoopField, "=",, 2)
			ObjRawSet(Data, pair*)
		}
	}

	_Write(Key, Val)
	{
		; http://is.gd/uhoQqu ↓
		Val := StrLen(Val) ? " " Val : ""
		IniWrite % Val, % this.__path, % this.__name, % Key
	}

}

#Include <Object>
