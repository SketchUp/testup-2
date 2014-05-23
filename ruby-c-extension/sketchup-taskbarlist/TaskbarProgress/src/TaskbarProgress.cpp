#include "TaskbarProgress.h"


namespace sketchup {

TaskbarProgress::TaskbarProgress()
{
  m_pITaskBarList3 = NULL;
  m_bFailed = false;
}


TaskbarProgress::~TaskbarProgress()
{
  if (m_pITaskBarList3)   
  {
    m_pITaskBarList3->Release();
    CoUninitialize();
  }
}


HRESULT TaskbarProgress::SetProgressState(HWND hwnd, TBPFLAG flag)
{
  if (Init())
	{
		return m_pITaskBarList3->SetProgressState(hwnd, flag);
	}
	
	return E_INIT_FAILED;
}


HRESULT TaskbarProgress::SetProgressValue(HWND hwnd,
	ULONGLONG ullCompleted, ULONGLONG ullTotal)
{
  if (Init())
	{
		return m_pITaskBarList3->SetProgressValue(hwnd, ullCompleted, ullTotal);
	}
	return E_INIT_FAILED;
}


bool TaskbarProgress::Init()
{
  if (m_pITaskBarList3)
	{
		return true;
	}

  if (m_bFailed)
	{
		return false;
	}

  // Initialize COM for this thread...
  CoInitialize(NULL);

  CoCreateInstance(CLSID_TaskbarList, NULL, CLSCTX_INPROC_SERVER,
		IID_ITaskbarList3, (void **)&m_pITaskBarList3);

  if (m_pITaskBarList3)
	{
		return true;
	}

  m_bFailed = true;
  CoUninitialize();
  return false;
}


} // namespace sketchup
