#pragma once

#include <ShObjIdl.h>
#include <winerror.h>


namespace sketchup {


// Thin wrapper over the ITaskbarList3 interface.
// http://stackoverflow.com/a/15002979/486990
class TaskbarProgress  
{
public:
  TaskbarProgress();
  virtual ~TaskbarProgress();

	// http://msdn.microsoft.com/en-us/library/cc231198.aspx
	// TODO(thomthom): Verify that the Customer bit is set to indicate that the
	// error is customer defined.
	const HRESULT E_INIT_FAILED = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NULL, 1);

  HRESULT SetProgressState(HWND hwnd, TBPFLAG flag);

  HRESULT SetProgressValue(HWND hwnd,
		ULONGLONG ullCompleted, ULONGLONG ullTotal);

private:
  bool Init();
  ITaskbarList3* m_pITaskBarList3;
  bool m_bFailed;
};


} // namespace sketchup
