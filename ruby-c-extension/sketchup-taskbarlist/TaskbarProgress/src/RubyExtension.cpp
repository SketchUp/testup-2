#include "RubyExtension.h"

#include <assert.h>
#include <Windows.h>

#include "TaskbarProgress.h"


namespace sketchup {
namespace ruby {
namespace taskbarutils {
namespace {

HWND get_sketchup_window_handle();
BOOL CALLBACK EnumThreadWndProc(HWND hwnd,LPARAM lParam);
TaskbarProgress* get_progressbar(VALUE self);
void wrap_progressbar_free(TaskbarProgress* progressbar);
VALUE wrap_progressbar_alloc(VALUE klass);
VALUE wrap_set_state(VALUE self, VALUE flag);
VALUE wrap_set_value(VALUE self, VALUE completed, VALUE total);


HWND get_sketchup_window_handle()
{
	// TODO(thomthom): Review is there is a better way of getting a handle to the
	// SketchUp window.
	// GetActiveWindow cannot be used because it fails when no SketchUp windows
	// are active. This function might be called when SketchUp is not the active
	// window because it's doing some long task that made the user switch to do
	// something else.
	// Instead the thread's windows are enumerated and the root owner is picked.
	// This should be the SketchUp window.
	DWORD thread_id = GetCurrentThreadId();
	assert(thread_id);
	HWND sketchup_handle = NULL;
	LPARAM lParam = reinterpret_cast<LPARAM>(&sketchup_handle);
	BOOL bRetVal = EnumThreadWindows(thread_id, EnumThreadWndProc, lParam);
	assert(sketchup_handle);
	return sketchup_handle;
}


BOOL CALLBACK EnumThreadWndProc(HWND hwnd, LPARAM lParam)
{
	// TODO(thomthom): Might want to check the window title of `root` to ensure
	// that is really is the SketchUp Window. When going over the whole set of
	// windows it appear to be some where the root isn't SketchUp.
	HWND root = GetAncestor(hwnd, GA_ROOTOWNER);
	assert(root);
	assert(lParam);
	HWND* hwnd_out = reinterpret_cast<HWND*>(lParam);
	assert(hwnd_out);
	*hwnd_out = root;
	return FALSE;
}


TaskbarProgress* get_progressbar(VALUE self) {
  TaskbarProgress* progressbar;
  Data_Get_Struct(self, TaskbarProgress, progressbar);
  return progressbar;
}


void wrap_progressbar_free(TaskbarProgress* progressbar) {
  ruby_xfree(progressbar);
}


VALUE wrap_progressbar_alloc(VALUE klass) {
	TaskbarProgress* progressbar;
  return Data_Make_Struct(klass, TaskbarProgress, NULL,
		wrap_progressbar_free, progressbar);
}


VALUE wrap_set_state(VALUE self, VALUE v_flag)
{
	int flag_value = NUM2INT(v_flag);
	switch (flag_value)
	{
	case TBPF_NOPROGRESS:
	case TBPF_INDETERMINATE:
	case TBPF_NORMAL:
	case TBPF_ERROR:
	case TBPF_PAUSED:
		break;
	default:
		rb_raise(rb_eArgError, "Invalid state");
	}
	TBPFLAG flag = static_cast<TBPFLAG>(flag_value);
	HWND sketchup_window = get_sketchup_window_handle();
	TaskbarProgress* progressbar = get_progressbar(self);
	HRESULT result = progressbar->SetProgressState(sketchup_window, flag);
  return LONG2NUM(result);
}


VALUE wrap_set_value(VALUE self, VALUE v_completed, VALUE v_total)
{
	ULONGLONG completed = NUM2ULL(v_completed);
	ULONGLONG total = NUM2ULL(v_total);
  HWND sketchup = get_sketchup_window_handle();
	TaskbarProgress* progressbar = get_progressbar(self);
	HRESULT result = progressbar->SetProgressValue(sketchup, completed, total);
  return LONG2NUM(result);
}

} // namespace


void InitUnder(VALUE parent)
{
	VALUE cTaskbarProcess = Qnil;
  if (parent == Qnil)
  {
    cTaskbarProcess = rb_define_class("TaskbarProgress", rb_cObject);
  }
  else
  {
    cTaskbarProcess = rb_define_class_under(parent,
      "TaskbarProgress", rb_cObject);
  }

	rb_define_const(cTaskbarProcess, "CEXT_VERSION",  GetRubyInterface("1.0.0"));

	rb_define_alloc_func(cTaskbarProcess, wrap_progressbar_alloc);

	rb_define_method(cTaskbarProcess, "set_state", VALUEFUNC(wrap_set_state), 1);
	rb_define_method(cTaskbarProcess, "set_value", VALUEFUNC(wrap_set_value), 2);

	rb_define_const(cTaskbarProcess, "NOPROGRESS",    INT2NUM(TBPF_NOPROGRESS));
	rb_define_const(cTaskbarProcess, "INDETERMINATE", INT2NUM(TBPF_INDETERMINATE));
	rb_define_const(cTaskbarProcess, "NORMAL",        INT2NUM(TBPF_NORMAL));
	rb_define_const(cTaskbarProcess, "ERROR",         INT2NUM(TBPF_ERROR));
	rb_define_const(cTaskbarProcess, "PAUSED",        INT2NUM(TBPF_PAUSED));
}

} // namespace taskbarutils
} // namespace ruby
} // namespace sketchup


extern "C"
void Init_TaskbarProgress()
{
  VALUE mTestUp = rb_define_module("TestUp");
  sketchup::ruby::taskbarutils::InitUnder(mTestUp);
}
