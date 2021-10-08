
Async(Function, Parameters*)
{
	ref := Func(Function)
	if Parameters.Count()
		ref := ref.Bind(Parameters*)
	SetTimer % ref, -1
}
