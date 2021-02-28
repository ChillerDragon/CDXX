#include "v8test.h"

#include <libplatform/libplatform.h>
#include <engine/external/v8pp/class.hpp>
#include <engine/external/v8pp/module.hpp>

#include <base/system.h>

CV8Test::CV8Test()
{
	// Initialize V8.
	v8::V8::InitializeICUDefaultLocation(".");
	v8::V8::InitializeExternalStartupData(".");
	std::unique_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();
	v8::V8::InitializePlatform(platform.get());
	v8::V8::Initialize();
	
    // Create a new Isolate and make it the current one.
	v8::Isolate::CreateParams create_params;
	create_params.array_buffer_allocator = v8::ArrayBuffer::Allocator::NewDefaultAllocator();
	v8::Isolate* isolate = v8::Isolate::New(create_params);
	{
		// Create a stack-allocated handle scope.
		v8::HandleScope handle_scope(isolate);
		v8::Local<v8::Context> context = v8::Context::New(isolate);
		// Enter the context for compiling and running the hello world script.
		v8::Context::Scope context_scope(context);


		const char *str = "test.js";
		v8::Local<v8::String> file_name = v8::String::NewFromUtf8(isolate, str).ToLocalChecked();
		v8::Local<v8::String> source;
		if(!ReadFile(isolate, str).ToLocal(&source))
			fprintf(stderr, "Error reading '%s'\n", str);

		bool success = ExecuteString(isolate, source, file_name, true, true);
		while(v8::platform::PumpMessageLoop(platform.get(), isolate))
			continue;
	}

	// Dispose the isolate and tear down V8.
	isolate->Dispose();
	v8::V8::Dispose();
	v8::V8::ShutdownPlatform();
	delete create_params.array_buffer_allocator;
}

v8::MaybeLocal<v8::String> CV8Test::ReadFile(v8::Isolate* isolate, const char* name) {
	FILE* file = fopen(name, "rb");
	if(file == NULL)
		return v8::MaybeLocal<v8::String>();

	fseek(file, 0, SEEK_END);
	size_t size = ftell(file);
	rewind(file);

	char* chars = new char[size + 1];
	chars[size] = '\0';
	for(size_t i = 0; i < size;)
	{
		i += fread(&chars[i], 1, size - i, file);
		if(ferror(file)) {
			fclose(file);
			return v8::MaybeLocal<v8::String>();
		}
	}
	fclose(file);
	v8::MaybeLocal<v8::String> result = v8::String::NewFromUtf8(
	isolate, chars, v8::NewStringType::kNormal, static_cast<int>(size));
	delete[] chars;
	return result;
}

bool CV8Test::ExecuteString(v8::Isolate* isolate, v8::Local<v8::String> source,
					v8::Local<v8::Value> name, bool print_result,
					bool report_exceptions)
{
	v8::HandleScope handle_scope(isolate);
	v8::TryCatch try_catch(isolate);
	v8::ScriptOrigin origin(name);
	v8::Local<v8::Context> context(isolate->GetCurrentContext());
	v8::Local<v8::Script> script;
	if(!v8::Script::Compile(context, source, &origin).ToLocal(&script))
	{
		// Print errors that happened during compilation.
		if(report_exceptions)
			dbg_msg("v8test", "exception caught!");
		return false;
	} else {
		v8::Local<v8::Value> result;
		if(!script->Run(context).ToLocal(&result)) {
		assert(try_catch.HasCaught());
		// Print errors that happened during execution.
		if(report_exceptions)
			dbg_msg("v8test", "exception caught!");
		return false;
		} else {
			assert(!try_catch.HasCaught());
			if(print_result && !result->IsUndefined()) {
				// If all went well and the result wasn't undefined then print
				// the returned value.
				v8::String::Utf8Value str(isolate, result);
				const char* cstr = ToCString(str);
				dbg_msg("v8test", "%s\n", cstr);
			}
			return true;
		}
	}
}

const char* CV8Test::ToCString(const v8::String::Utf8Value& value) {
  return *value ? *value : "<string conversion failed>";
}
