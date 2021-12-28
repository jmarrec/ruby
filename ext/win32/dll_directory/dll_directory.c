#include <ruby.h>
#include <ruby/encoding.h>
#include <windows.h>
#include <libloaderapi.h>

#define PTR2NUM(x) (ULL2NUM((LONG_LONG)(x)))
#define NUM2PTR(x) ((void*)(NUM2ULL(x)))

static VALUE
s_SetDefaultDllDirectories(VALUE self, VALUE flags)
{
	int ret = SetDefaultDllDirectories(RB_NUM2LONG(flags));
	return RB_INT2NUM(ret);
}

static VALUE
s_AddDllDirectory(VALUE self, VALUE dir)
{
	void *handle;
	int encidx = rb_enc_find_index("utf-16le");
	StringValueCStr(dir);
	dir = rb_str_export_to_enc(dir, rb_enc_from_index(encidx));
	handle = AddDllDirectory((PCWSTR)RSTRING_PTR(dir));
	return PTR2NUM(handle);
}

static VALUE
s_RemoveDllDirectory(VALUE self, VALUE handle)
{
	int ret = RemoveDllDirectory(NUM2PTR(handle));
	return RB_INT2NUM(ret);
}

void
Init_dll_directory(void)
{
    VALUE mWin32 = rb_define_module("Win32");
    VALUE mDD = rb_define_module_under(mWin32, "DllDirectory");
    rb_define_singleton_method(mDD, "SetDefaultDllDirectories", s_SetDefaultDllDirectories, 1);
    rb_define_singleton_method(mDD, "AddDllDirectory", s_AddDllDirectory, 1);
    rb_define_singleton_method(mDD, "RemoveDllDirectory", s_RemoveDllDirectory, 1);
}
