
async(fn, args*)
{
    ref := Func(fn)
    if args.Count()
        ref := ref.Bind(args*)
    SetTimer % ref, -1
}
