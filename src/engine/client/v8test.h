#ifndef ENGINE_CLIENT_V8TEST_H
#define ENGINE_CLIENT_V8TEST_H

#include <v8.h>

class CV8Test
{
public:
	CV8Test();
private:
	v8::MaybeLocal<v8::String> ReadFile(v8::Isolate* isolate, const char* name);
	bool ExecuteString(v8::Isolate* isolate, v8::Local<v8::String> source,
						v8::Local<v8::Value> name, bool print_result,
						bool report_exceptions);
	const char* ToCString(const v8::String::Utf8Value& value);
};

#endif
