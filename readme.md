hacking together a lime version of this https://github.com/jeremyfa/imgui-hx/blob/master/test/kha/Sources/ImGuiDemo.hx#L294

here we can have imgui-hx working in hxcpp and html5 targets on lime

I don't know what I'm doing so my plan is to try to mirror the kha example and make something work.

So there is some code borrowed from Kha (see Kha.hx). It was a quick copy paste job to get things compiling. Some of the kha code originally used externs which are not present here so that must be implemented in haxe instead - e.g. IndexBuffer and VertexBuffer

Once the lime sample is working the kha code can be rewritten leaving only the parts needed for the sample to function.

Then hashlink can also join the party, but will need some hl versions of the imgui-hx code which is currently surrounded by #if js or #if cpp (some re-use is likely possibly for #if hl)