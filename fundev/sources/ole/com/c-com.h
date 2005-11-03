
/* This file is automatically generated; do not edit. */

extern HRESULT __stdcall __RPC_FAR
DW_IUnknown_QueryInterface ( 
	    IUnknown __RPC_FAR * This, 
	    /* [in] */ REFIID riid,
	    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);

extern ULONG __stdcall __RPC_FAR
DW_IUnknown_AddRef (
		IUnknown __RPC_FAR * This);

extern ULONG __stdcall __RPC_FAR
DW_IUnknown_Release (
		IUnknown __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IClassFactory_CreateInstance ( 
	    IClassFactory __RPC_FAR * This, 
	    /* [unique][in] */ IUnknown __RPC_FAR *pUnkOuter,
	    /* [in] */ REFIID riid,
	    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);

extern HRESULT __stdcall __RPC_FAR
DW_IClassFactory_LockServer ( 
	    IClassFactory __RPC_FAR * This, 
	    /* [in] */ BOOL fLock);

/* This file is automatically generated; do not edit. */

extern HRESULT __stdcall __RPC_FAR
DW_IMarshal_GetUnmarshalClass ( 
	    IMarshal __RPC_FAR * This, 
	    /* [in] */ REFIID riid,
	    /* [unique][in] */ void __RPC_FAR *pv,
	    /* [in] */ DWORD dwDestContext,
	    /* [unique][in] */ void __RPC_FAR *pvDestContext,
	    /* [in] */ DWORD mshlflags,
	    /* [out] */ CLSID __RPC_FAR *pCid);

extern HRESULT __stdcall __RPC_FAR
DW_IMarshal_GetMarshalSizeMax ( 
	    IMarshal __RPC_FAR * This, 
	    /* [in] */ REFIID riid,
	    /* [unique][in] */ void __RPC_FAR *pv,
	    /* [in] */ DWORD dwDestContext,
	    /* [unique][in] */ void __RPC_FAR *pvDestContext,
	    /* [in] */ DWORD mshlflags,
	    /* [out] */ DWORD __RPC_FAR *pSize);

extern HRESULT __stdcall __RPC_FAR
DW_IMarshal_MarshalInterface ( 
	    IMarshal __RPC_FAR * This, 
	    /* [unique][in] */ IStream __RPC_FAR *pStm,
	    /* [in] */ REFIID riid,
	    /* [unique][in] */ void __RPC_FAR *pv,
	    /* [in] */ DWORD dwDestContext,
	    /* [unique][in] */ void __RPC_FAR *pvDestContext,
	    /* [in] */ DWORD mshlflags);

extern HRESULT __stdcall __RPC_FAR
DW_IMarshal_UnmarshalInterface ( 
	    IMarshal __RPC_FAR * This, 
	    /* [unique][in] */ IStream __RPC_FAR *pStm,
	    /* [in] */ REFIID riid,
	    /* [out] */ void __RPC_FAR *__RPC_FAR *ppv);

extern HRESULT __stdcall __RPC_FAR
DW_IMarshal_ReleaseMarshalData ( 
	    IMarshal __RPC_FAR * This, 
	    /* [unique][in] */ IStream __RPC_FAR *pStm);

extern HRESULT __stdcall __RPC_FAR
DW_IMarshal_DisconnectObject ( 
	    IMarshal __RPC_FAR * This, 
	    /* [in] */ DWORD dwReserved);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMalloc_Alloc ( 
	    IMalloc __RPC_FAR * This, 
	    /* [in] */ ULONG cb);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMalloc_Realloc ( 
	    IMalloc __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pv,
	    /* [in] */ ULONG cb);

extern void __stdcall __RPC_FAR
DW_IMalloc_Free ( 
	    IMalloc __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pv);

extern ULONG __stdcall __RPC_FAR
DW_IMalloc_GetSize ( 
	    IMalloc __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pv);

extern int __stdcall __RPC_FAR
DW_IMalloc_DidAlloc ( 
	    IMalloc __RPC_FAR * This, 
	    void __RPC_FAR *pv);

extern void __stdcall __RPC_FAR
DW_IMalloc_HeapMinimize (
		IMalloc __RPC_FAR * This);

extern ULONG __stdcall __RPC_FAR
DW_IMallocSpy_PreAlloc ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ ULONG cbRequest);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMallocSpy_PostAlloc ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pActual);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMallocSpy_PreFree ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pRequest,
	    /* [in] */ BOOL fSpyed);

extern void __stdcall __RPC_FAR
DW_IMallocSpy_PostFree ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ BOOL fSpyed);

extern ULONG __stdcall __RPC_FAR
DW_IMallocSpy_PreRealloc ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pRequest,
	    /* [in] */ ULONG cbRequest,
	    /* [out] */ void __RPC_FAR *__RPC_FAR *ppNewRequest,
	    /* [in] */ BOOL fSpyed);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMallocSpy_PostRealloc ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pActual,
	    /* [in] */ BOOL fSpyed);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMallocSpy_PreGetSize ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pRequest,
	    /* [in] */ BOOL fSpyed);

extern ULONG __stdcall __RPC_FAR
DW_IMallocSpy_PostGetSize ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ ULONG cbActual,
	    /* [in] */ BOOL fSpyed);

extern void __RPC_FAR * __stdcall __RPC_FAR
DW_IMallocSpy_PreDidAlloc ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pRequest,
	    /* [in] */ BOOL fSpyed);

extern int __stdcall __RPC_FAR
DW_IMallocSpy_PostDidAlloc ( 
	    IMallocSpy __RPC_FAR * This, 
	    /* [in] */ void __RPC_FAR *pRequest,
	    /* [in] */ BOOL fSpyed,
	    /* [in] */ int fActual);

extern void __stdcall __RPC_FAR
DW_IMallocSpy_PreHeapMinimize (
		IMallocSpy __RPC_FAR * This);

extern void __stdcall __RPC_FAR
DW_IMallocSpy_PostHeapMinimize (
		IMallocSpy __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IStdMarshalInfo_GetClassForHandler ( 
	    IStdMarshalInfo __RPC_FAR * This, 
	    /* [in] */ DWORD dwDestContext,
	    /* [unique][in] */ void __RPC_FAR *pvDestContext,
	    /* [out] */ CLSID __RPC_FAR *pClsid);

extern DWORD __stdcall __RPC_FAR
DW_IExternalConnection_AddConnection ( 
	    IExternalConnection __RPC_FAR * This, 
	    /* [in] */ DWORD extconn,
	    /* [in] */ DWORD reserved);

extern DWORD __stdcall __RPC_FAR
DW_IExternalConnection_ReleaseConnection ( 
	    IExternalConnection __RPC_FAR * This, 
	    /* [in] */ DWORD extconn,
	    /* [in] */ DWORD reserved,
	    /* [in] */ BOOL fLastReleaseCloses);

extern HRESULT __stdcall __RPC_FAR
DW_IMultiQI_QueryMultipleInterfaces ( 
	    IMultiQI __RPC_FAR * This, 
	    /* [in] */ ULONG cMQIs,
	    /* [out][in] */ MULTI_QI __RPC_FAR *pMQIs);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumUnknown_Next ( 
	    IEnumUnknown __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [out] */ IUnknown __RPC_FAR *__RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumUnknown_Skip ( 
	    IEnumUnknown __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumUnknown_Reset (
		IEnumUnknown __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumUnknown_Clone ( 
	    IEnumUnknown __RPC_FAR * This, 
	    /* [out] */ IEnumUnknown __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_RegisterObjectBound ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [unique][in] */ IUnknown __RPC_FAR *punk);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_RevokeObjectBound ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [unique][in] */ IUnknown __RPC_FAR *punk);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_ReleaseBoundObjects (
		IBindCtx __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_SetBindOptions ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [in] */ BIND_OPTS __RPC_FAR *pbindopts);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_GetBindOptions ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [out][in] */ BIND_OPTS __RPC_FAR *pbindopts);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_GetRunningObjectTable ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [out] */ IRunningObjectTable __RPC_FAR *__RPC_FAR *pprot);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_RegisterObjectParam ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [in] */ LPOLESTR pszKey,
	    /* [unique][in] */ IUnknown __RPC_FAR *punk);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_GetObjectParam ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [in] */ LPOLESTR pszKey,
	    /* [out] */ IUnknown __RPC_FAR *__RPC_FAR *ppunk);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_EnumObjectParam ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [out] */ IEnumString __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IBindCtx_RevokeObjectParam ( 
	    IBindCtx __RPC_FAR * This, 
	    /* [in] */ LPOLESTR pszKey);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumMoniker_Next ( 
	    IEnumMoniker __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ IMoniker __RPC_FAR *__RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumMoniker_Skip ( 
	    IEnumMoniker __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumMoniker_Reset (
		IEnumMoniker __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumMoniker_Clone ( 
	    IEnumMoniker __RPC_FAR * This, 
	    /* [out] */ IEnumMoniker __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IRunnableObject_GetRunningClass ( 
	    IRunnableObject __RPC_FAR * This, 
	    /* [out] */ LPCLSID lpClsid);

extern HRESULT __stdcall __RPC_FAR
DW_IRunnableObject_Run ( 
	    IRunnableObject __RPC_FAR * This, 
	    /* [in] */ LPBINDCTX pbc);

extern BOOL __stdcall __RPC_FAR
DW_IRunnableObject_IsRunning (
		IRunnableObject __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IRunnableObject_LockRunning ( 
	    IRunnableObject __RPC_FAR * This, 
	    /* [in] */ BOOL fLock,
	    /* [in] */ BOOL fLastUnlockCloses);

extern HRESULT __stdcall __RPC_FAR
DW_IRunnableObject_SetContainedObject ( 
	    IRunnableObject __RPC_FAR * This, 
	    /* [in] */ BOOL fContained);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_Register ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [in] */ DWORD grfFlags,
	    /* [unique][in] */ IUnknown __RPC_FAR *punkObject,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkObjectName,
	    /* [out] */ DWORD __RPC_FAR *pdwRegister);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_Revoke ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [in] */ DWORD dwRegister);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_IsRunning ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkObjectName);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_GetObject ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkObjectName,
	    /* [out] */ IUnknown __RPC_FAR *__RPC_FAR *ppunkObject);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_NoteChangeTime ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [in] */ DWORD dwRegister,
	    /* [in] */ FILETIME __RPC_FAR *pfiletime);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_GetTimeOfLastChange ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkObjectName,
	    /* [out] */ FILETIME __RPC_FAR *pfiletime);

extern HRESULT __stdcall __RPC_FAR
DW_IRunningObjectTable_EnumRunning ( 
	    IRunningObjectTable __RPC_FAR * This, 
	    /* [out] */ IEnumMoniker __RPC_FAR *__RPC_FAR *ppenumMoniker);

extern HRESULT __stdcall __RPC_FAR
DW_IPersist_GetClassID ( 
	    IPersist __RPC_FAR * This, 
	    /* [out] */ CLSID __RPC_FAR *pClassID);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStream_IsDirty (
		IPersistStream __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStream_Load ( 
	    IPersistStream __RPC_FAR * This, 
	    /* [unique][in] */ IStream __RPC_FAR *pStm);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStream_Save ( 
	    IPersistStream __RPC_FAR * This, 
	    /* [unique][in] */ IStream __RPC_FAR *pStm,
	    /* [in] */ BOOL fClearDirty);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStream_GetSizeMax ( 
	    IPersistStream __RPC_FAR * This, 
	    /* [out] */ ULARGE_INTEGER __RPC_FAR *pcbSize);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_BindToObject ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkToLeft,
	    /* [in] */ REFIID riidResult,
	    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvResult);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_BindToStorage ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkToLeft,
	    /* [in] */ REFIID riid,
	    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObj);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_Reduce ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [in] */ DWORD dwReduceHowFar,
	    /* [unique][out][in] */ IMoniker __RPC_FAR *__RPC_FAR *ppmkToLeft,
	    /* [out] */ IMoniker __RPC_FAR *__RPC_FAR *ppmkReduced);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_ComposeWith ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkRight,
	    /* [in] */ BOOL fOnlyIfNotGeneric,
	    /* [out] */ IMoniker __RPC_FAR *__RPC_FAR *ppmkComposite);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_Enum ( 
	    IMoniker __RPC_FAR * This, 
	    /* [in] */ BOOL fForward,
	    /* [out] */ IEnumMoniker __RPC_FAR *__RPC_FAR *ppenumMoniker);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_IsEqual ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkOtherMoniker);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_Hash ( 
	    IMoniker __RPC_FAR * This, 
	    /* [out] */ DWORD __RPC_FAR *pdwHash);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_IsRunning ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkToLeft,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkNewlyRunning);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_GetTimeOfLastChange ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkToLeft,
	    /* [out] */ FILETIME __RPC_FAR *pFileTime);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_Inverse ( 
	    IMoniker __RPC_FAR * This, 
	    /* [out] */ IMoniker __RPC_FAR *__RPC_FAR *ppmk);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_CommonPrefixWith ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkOther,
	    /* [out] */ IMoniker __RPC_FAR *__RPC_FAR *ppmkPrefix);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_RelativePathTo ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkOther,
	    /* [out] */ IMoniker __RPC_FAR *__RPC_FAR *ppmkRelPath);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_GetDisplayName ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkToLeft,
	    /* [out] */ LPOLESTR __RPC_FAR *ppszDisplayName);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_ParseDisplayName ( 
	    IMoniker __RPC_FAR * This, 
	    /* [unique][in] */ IBindCtx __RPC_FAR *pbc,
	    /* [unique][in] */ IMoniker __RPC_FAR *pmkToLeft,
	    /* [in] */ LPOLESTR pszDisplayName,
	    /* [out] */ ULONG __RPC_FAR *pchEaten,
	    /* [out] */ IMoniker __RPC_FAR *__RPC_FAR *ppmkOut);

extern HRESULT __stdcall __RPC_FAR
DW_IMoniker_IsSystemMoniker ( 
	    IMoniker __RPC_FAR * This, 
	    /* [out] */ DWORD __RPC_FAR *pdwMksys);

extern HRESULT __stdcall __RPC_FAR
DW_IROTData_GetComparisonData ( 
	    IROTData __RPC_FAR * This, 
	    /* [size_is][out] */ byte __RPC_FAR *pbData,
	    /* [in] */ ULONG cbMax,
	    /* [out] */ ULONG __RPC_FAR *pcbData);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumString_Next ( 
	    IEnumString __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ LPOLESTR __RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumString_Skip ( 
	    IEnumString __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumString_Reset (
		IEnumString __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumString_Clone ( 
	    IEnumString __RPC_FAR * This, 
	    /* [out] */ IEnumString __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_ISequentialStream_Read ( 
	    ISequentialStream __RPC_FAR * This, 
	    /* [length_is][size_is][out] */ void __RPC_FAR *pv,
	    /* [in] */ ULONG cb,
	    /* [out] */ ULONG __RPC_FAR *pcbRead);

extern HRESULT __stdcall __RPC_FAR
DW_ISequentialStream_Write ( 
	    ISequentialStream __RPC_FAR * This, 
	    /* [size_is][in] */ const void __RPC_FAR *pv,
	    /* [in] */ ULONG cb,
	    /* [out] */ ULONG __RPC_FAR *pcbWritten);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_Seek ( 
	    IStream __RPC_FAR * This, 
	    /* [in] */ LARGE_INTEGER dlibMove,
	    /* [in] */ DWORD dwOrigin,
	    /* [out] */ ULARGE_INTEGER __RPC_FAR *plibNewPosition);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_SetSize ( 
	    IStream __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER libNewSize);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_CopyTo ( 
	    IStream __RPC_FAR * This, 
	    /* [unique][in] */ IStream __RPC_FAR *pstm,
	    /* [in] */ ULARGE_INTEGER cb,
	    /* [out] */ ULARGE_INTEGER __RPC_FAR *pcbRead,
	    /* [out] */ ULARGE_INTEGER __RPC_FAR *pcbWritten);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_Commit ( 
	    IStream __RPC_FAR * This, 
	    /* [in] */ DWORD grfCommitFlags);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_Revert (
		IStream __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_LockRegion ( 
	    IStream __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER libOffset,
	    /* [in] */ ULARGE_INTEGER cb,
	    /* [in] */ DWORD dwLockType);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_UnlockRegion ( 
	    IStream __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER libOffset,
	    /* [in] */ ULARGE_INTEGER cb,
	    /* [in] */ DWORD dwLockType);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_Stat ( 
	    IStream __RPC_FAR * This, 
	    /* [out] */ STATSTG __RPC_FAR *pstatstg,
	    /* [in] */ DWORD grfStatFlag);

extern HRESULT __stdcall __RPC_FAR
DW_IStream_Clone ( 
	    IStream __RPC_FAR * This, 
	    /* [out] */ IStream __RPC_FAR *__RPC_FAR *ppstm);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATSTG_Next ( 
	    IEnumSTATSTG __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ STATSTG __RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATSTG_Skip ( 
	    IEnumSTATSTG __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATSTG_Reset (
		IEnumSTATSTG __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATSTG_Clone ( 
	    IEnumSTATSTG __RPC_FAR * This, 
	    /* [out] */ IEnumSTATSTG __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_CreateStream ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsName,
	    /* [in] */ DWORD grfMode,
	    /* [in] */ DWORD reserved1,
	    /* [in] */ DWORD reserved2,
	    /* [out] */ IStream __RPC_FAR *__RPC_FAR *ppstm);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_OpenStream ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsName,
	    /* [unique][in] */ void __RPC_FAR *reserved1,
	    /* [in] */ DWORD grfMode,
	    /* [in] */ DWORD reserved2,
	    /* [out] */ IStream __RPC_FAR *__RPC_FAR *ppstm);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_CreateStorage ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsName,
	    /* [in] */ DWORD grfMode,
	    /* [in] */ DWORD reserved1,
	    /* [in] */ DWORD reserved2,
	    /* [out] */ IStorage __RPC_FAR *__RPC_FAR *ppstg);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_OpenStorage ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][unique][in] */ const OLECHAR __RPC_FAR *pwcsName,
	    /* [unique][in] */ IStorage __RPC_FAR *pstgPriority,
	    /* [in] */ DWORD grfMode,
	    /* [unique][in] */ SNB snbExclude,
	    /* [in] */ DWORD reserved,
	    /* [out] */ IStorage __RPC_FAR *__RPC_FAR *ppstg);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_CopyTo ( 
	    IStorage __RPC_FAR * This, 
	    /* [in] */ DWORD ciidExclude,
	    /* [size_is][unique][in] */ const IID __RPC_FAR *rgiidExclude,
	    /* [unique][in] */ SNB snbExclude,
	    /* [unique][in] */ IStorage __RPC_FAR *pstgDest);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_MoveElementTo ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsName,
	    /* [unique][in] */ IStorage __RPC_FAR *pstgDest,
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsNewName,
	    /* [in] */ DWORD grfFlags);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_Commit ( 
	    IStorage __RPC_FAR * This, 
	    /* [in] */ DWORD grfCommitFlags);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_Revert (
		IStorage __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_EnumElements ( 
	    IStorage __RPC_FAR * This, 
	    /* [in] */ DWORD reserved1,
	    /* [size_is][unique][in] */ void __RPC_FAR *reserved2,
	    /* [in] */ DWORD reserved3,
	    /* [out] */ IEnumSTATSTG __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_DestroyElement ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsName);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_RenameElement ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsOldName,
	    /* [string][in] */ const OLECHAR __RPC_FAR *pwcsNewName);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_SetElementTimes ( 
	    IStorage __RPC_FAR * This, 
	    /* [string][unique][in] */ const OLECHAR __RPC_FAR *pwcsName,
	    /* [unique][in] */ const FILETIME __RPC_FAR *pctime,
	    /* [unique][in] */ const FILETIME __RPC_FAR *patime,
	    /* [unique][in] */ const FILETIME __RPC_FAR *pmtime);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_SetClass ( 
	    IStorage __RPC_FAR * This, 
	    /* [in] */ REFCLSID clsid);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_SetStateBits ( 
	    IStorage __RPC_FAR * This, 
	    /* [in] */ DWORD grfStateBits,
	    /* [in] */ DWORD grfMask);

extern HRESULT __stdcall __RPC_FAR
DW_IStorage_Stat ( 
	    IStorage __RPC_FAR * This, 
	    /* [out] */ STATSTG __RPC_FAR *pstatstg,
	    /* [in] */ DWORD grfStatFlag);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistFile_IsDirty (
		IPersistFile __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistFile_Load ( 
	    IPersistFile __RPC_FAR * This, 
	    /* [in] */ LPCOLESTR pszFileName,
	    /* [in] */ DWORD dwMode);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistFile_Save ( 
	    IPersistFile __RPC_FAR * This, 
	    /* [unique][in] */ LPCOLESTR pszFileName,
	    /* [in] */ BOOL fRemember);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistFile_SaveCompleted ( 
	    IPersistFile __RPC_FAR * This, 
	    /* [unique][in] */ LPCOLESTR pszFileName);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistFile_GetCurFile ( 
	    IPersistFile __RPC_FAR * This, 
	    /* [out] */ LPOLESTR __RPC_FAR *ppszFileName);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStorage_IsDirty (
		IPersistStorage __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStorage_InitNew ( 
	    IPersistStorage __RPC_FAR * This, 
	    /* [unique][in] */ IStorage __RPC_FAR *pStg);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStorage_Load ( 
	    IPersistStorage __RPC_FAR * This, 
	    /* [unique][in] */ IStorage __RPC_FAR *pStg);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStorage_Save ( 
	    IPersistStorage __RPC_FAR * This, 
	    /* [unique][in] */ IStorage __RPC_FAR *pStgSave,
	    /* [in] */ BOOL fSameAsLoad);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStorage_SaveCompleted ( 
	    IPersistStorage __RPC_FAR * This, 
	    /* [unique][in] */ IStorage __RPC_FAR *pStgNew);

extern HRESULT __stdcall __RPC_FAR
DW_IPersistStorage_HandsOffStorage (
		IPersistStorage __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_ReadAt ( 
	    ILockBytes __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER ulOffset,
	    /* [length_is][size_is][out] */ void __RPC_FAR *pv,
	    /* [in] */ ULONG cb,
	    /* [out] */ ULONG __RPC_FAR *pcbRead);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_WriteAt ( 
	    ILockBytes __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER ulOffset,
	    /* [size_is][in] */ const void __RPC_FAR *pv,
	    /* [in] */ ULONG cb,
	    /* [out] */ ULONG __RPC_FAR *pcbWritten);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_Flush (
		ILockBytes __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_SetSize ( 
	    ILockBytes __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER cb);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_LockRegion ( 
	    ILockBytes __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER libOffset,
	    /* [in] */ ULARGE_INTEGER cb,
	    /* [in] */ DWORD dwLockType);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_UnlockRegion ( 
	    ILockBytes __RPC_FAR * This, 
	    /* [in] */ ULARGE_INTEGER libOffset,
	    /* [in] */ ULARGE_INTEGER cb,
	    /* [in] */ DWORD dwLockType);

extern HRESULT __stdcall __RPC_FAR
DW_ILockBytes_Stat ( 
	    ILockBytes __RPC_FAR * This, 
	    /* [out] */ STATSTG __RPC_FAR *pstatstg,
	    /* [in] */ DWORD grfStatFlag);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumFORMATETC_Next ( 
	    IEnumFORMATETC __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ FORMATETC __RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumFORMATETC_Skip ( 
	    IEnumFORMATETC __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumFORMATETC_Reset (
		IEnumFORMATETC __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumFORMATETC_Clone ( 
	    IEnumFORMATETC __RPC_FAR * This, 
	    /* [out] */ IEnumFORMATETC __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATDATA_Next ( 
	    IEnumSTATDATA __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ STATDATA __RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATDATA_Skip ( 
	    IEnumSTATDATA __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATDATA_Reset (
		IEnumSTATDATA __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATDATA_Clone ( 
	    IEnumSTATDATA __RPC_FAR * This, 
	    /* [out] */ IEnumSTATDATA __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IRootStorage_SwitchToFile ( 
	    IRootStorage __RPC_FAR * This, 
	    /* [in] */ LPOLESTR pszFile);

extern void __stdcall __RPC_FAR
DW_IAdviseSink_OnDataChange ( 
	    IAdviseSink __RPC_FAR * This, 
	    /* [unique][in] */ FORMATETC __RPC_FAR *pFormatetc,
	    /* [unique][in] */ STGMEDIUM __RPC_FAR *pStgmed);

extern void __stdcall __RPC_FAR
DW_IAdviseSink_OnViewChange ( 
	    IAdviseSink __RPC_FAR * This, 
	    /* [in] */ DWORD dwAspect,
	    /* [in] */ LONG lindex);

extern void __stdcall __RPC_FAR
DW_IAdviseSink_OnRename ( 
	    IAdviseSink __RPC_FAR * This, 
	    /* [in] */ IMoniker __RPC_FAR *pmk);

extern void __stdcall __RPC_FAR
DW_IAdviseSink_OnSave (
		IAdviseSink __RPC_FAR * This);

extern void __stdcall __RPC_FAR
DW_IAdviseSink_OnClose (
		IAdviseSink __RPC_FAR * This);

extern void __stdcall __RPC_FAR
DW_IAdviseSink2_OnLinkSrcChange ( 
	    IAdviseSink2 __RPC_FAR * This, 
	    /* [unique][in] */ IMoniker __RPC_FAR *pmk);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_GetData ( 
	    IDataObject __RPC_FAR * This, 
	    /* [unique][in] */ FORMATETC __RPC_FAR *pformatetcIn,
	    /* [out] */ STGMEDIUM __RPC_FAR *pmedium);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_GetDataHere ( 
	    IDataObject __RPC_FAR * This, 
	    /* [unique][in] */ FORMATETC __RPC_FAR *pformatetc,
	    /* [out][in] */ STGMEDIUM __RPC_FAR *pmedium);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_QueryGetData ( 
	    IDataObject __RPC_FAR * This, 
	    /* [unique][in] */ FORMATETC __RPC_FAR *pformatetc);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_GetCanonicalFormatEtc ( 
	    IDataObject __RPC_FAR * This, 
	    /* [unique][in] */ FORMATETC __RPC_FAR *pformatectIn,
	    /* [out] */ FORMATETC __RPC_FAR *pformatetcOut);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_SetData ( 
	    IDataObject __RPC_FAR * This, 
	    /* [unique][in] */ FORMATETC __RPC_FAR *pformatetc,
	    /* [unique][in] */ STGMEDIUM __RPC_FAR *pmedium,
	    /* [in] */ BOOL fRelease);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_EnumFormatEtc ( 
	    IDataObject __RPC_FAR * This, 
	    /* [in] */ DWORD dwDirection,
	    /* [out] */ IEnumFORMATETC __RPC_FAR *__RPC_FAR *ppenumFormatEtc);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_DAdvise ( 
	    IDataObject __RPC_FAR * This, 
	    /* [in] */ FORMATETC __RPC_FAR *pformatetc,
	    /* [in] */ DWORD advf,
	    /* [unique][in] */ IAdviseSink __RPC_FAR *pAdvSink,
	    /* [out] */ DWORD __RPC_FAR *pdwConnection);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_DUnadvise ( 
	    IDataObject __RPC_FAR * This, 
	    /* [in] */ DWORD dwConnection);

extern HRESULT __stdcall __RPC_FAR
DW_IDataObject_EnumDAdvise ( 
	    IDataObject __RPC_FAR * This, 
	    /* [out] */ IEnumSTATDATA __RPC_FAR *__RPC_FAR *ppenumAdvise);

extern HRESULT __stdcall __RPC_FAR
DW_IDataAdviseHolder_Advise ( 
	    IDataAdviseHolder __RPC_FAR * This, 
	    /* [unique][in] */ IDataObject __RPC_FAR *pDataObject,
	    /* [unique][in] */ FORMATETC __RPC_FAR *pFetc,
	    /* [in] */ DWORD advf,
	    /* [unique][in] */ IAdviseSink __RPC_FAR *pAdvise,
	    /* [out] */ DWORD __RPC_FAR *pdwConnection);

extern HRESULT __stdcall __RPC_FAR
DW_IDataAdviseHolder_Unadvise ( 
	    IDataAdviseHolder __RPC_FAR * This, 
	    /* [in] */ DWORD dwConnection);

extern HRESULT __stdcall __RPC_FAR
DW_IDataAdviseHolder_EnumAdvise ( 
	    IDataAdviseHolder __RPC_FAR * This, 
	    /* [out] */ IEnumSTATDATA __RPC_FAR *__RPC_FAR *ppenumAdvise);

extern HRESULT __stdcall __RPC_FAR
DW_IDataAdviseHolder_SendOnDataChange ( 
	    IDataAdviseHolder __RPC_FAR * This, 
	    /* [unique][in] */ IDataObject __RPC_FAR *pDataObject,
	    /* [in] */ DWORD dwReserved,
	    /* [in] */ DWORD advf);

extern DWORD __stdcall __RPC_FAR
DW_IMessageFilter_HandleInComingCall ( 
	    IMessageFilter __RPC_FAR * This, 
	    /* [in] */ DWORD dwCallType,
	    /* [in] */ HTASK htaskCaller,
	    /* [in] */ DWORD dwTickCount,
	    /* [in] */ LPINTERFACEINFO lpInterfaceInfo);

extern DWORD __stdcall __RPC_FAR
DW_IMessageFilter_RetryRejectedCall ( 
	    IMessageFilter __RPC_FAR * This, 
	    /* [in] */ HTASK htaskCallee,
	    /* [in] */ DWORD dwTickCount,
	    /* [in] */ DWORD dwRejectType);

extern DWORD __stdcall __RPC_FAR
DW_IMessageFilter_MessagePending ( 
	    IMessageFilter __RPC_FAR * This, 
	    /* [in] */ HTASK htaskCallee,
	    /* [in] */ DWORD dwTickCount,
	    /* [in] */ DWORD dwPendingType);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcChannelBuffer_GetBuffer ( 
	    IRpcChannelBuffer __RPC_FAR * This, 
	    /* [in] */ RPCOLEMESSAGE __RPC_FAR *pMessage,
	    /* [in] */ REFIID riid);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcChannelBuffer_SendReceive ( 
	    IRpcChannelBuffer __RPC_FAR * This, 
	    /* [out][in] */ RPCOLEMESSAGE __RPC_FAR *pMessage,
	    /* [out] */ ULONG __RPC_FAR *pStatus);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcChannelBuffer_FreeBuffer ( 
	    IRpcChannelBuffer __RPC_FAR * This, 
	    /* [in] */ RPCOLEMESSAGE __RPC_FAR *pMessage);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcChannelBuffer_GetDestCtx ( 
	    IRpcChannelBuffer __RPC_FAR * This, 
	    /* [out] */ DWORD __RPC_FAR *pdwDestContext,
	    /* [out] */ void __RPC_FAR *__RPC_FAR *ppvDestContext);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcChannelBuffer_IsConnected (
		IRpcChannelBuffer __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcProxyBuffer_Connect ( 
	    IRpcProxyBuffer __RPC_FAR * This, 
	    /* [unique][in] */ IRpcChannelBuffer __RPC_FAR *pRpcChannelBuffer);

extern void __stdcall __RPC_FAR
DW_IRpcProxyBuffer_Disconnect (
		IRpcProxyBuffer __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcStubBuffer_Connect ( 
	    IRpcStubBuffer __RPC_FAR * This, 
	    /* [in] */ IUnknown __RPC_FAR *pUnkServer);

extern void __stdcall __RPC_FAR
DW_IRpcStubBuffer_Disconnect (
		IRpcStubBuffer __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcStubBuffer_Invoke ( 
	    IRpcStubBuffer __RPC_FAR * This, 
	    /* [in] */ RPCOLEMESSAGE __RPC_FAR *_prpcmsg,
	    /* [in] */ IRpcChannelBuffer __RPC_FAR *_pRpcChannelBuffer);

extern IRpcStubBuffer __RPC_FAR * __stdcall __RPC_FAR
DW_IRpcStubBuffer_IsIIDSupported ( 
	    IRpcStubBuffer __RPC_FAR * This, 
	    /* [in] */ REFIID riid);

extern ULONG __stdcall __RPC_FAR
DW_IRpcStubBuffer_CountRefs (
		IRpcStubBuffer __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IRpcStubBuffer_DebugServerQueryInterface ( 
	    IRpcStubBuffer __RPC_FAR * This, 
	    void __RPC_FAR *__RPC_FAR *ppv);

extern void __stdcall __RPC_FAR
DW_IRpcStubBuffer_DebugServerRelease ( 
	    IRpcStubBuffer __RPC_FAR * This, 
	    void __RPC_FAR *pv);

extern HRESULT __stdcall __RPC_FAR
DW_IPSFactoryBuffer_CreateProxy ( 
	    IPSFactoryBuffer __RPC_FAR * This, 
	    /* [in] */ IUnknown __RPC_FAR *pUnkOuter,
	    /* [in] */ REFIID riid,
	    /* [out] */ IRpcProxyBuffer __RPC_FAR *__RPC_FAR *ppProxy,
	    /* [out] */ void __RPC_FAR *__RPC_FAR *ppv);

extern HRESULT __stdcall __RPC_FAR
DW_IPSFactoryBuffer_CreateStub ( 
	    IPSFactoryBuffer __RPC_FAR * This, 
	    /* [in] */ REFIID riid,
	    /* [unique][in] */ IUnknown __RPC_FAR *pUnkServer,
	    /* [out] */ IRpcStubBuffer __RPC_FAR *__RPC_FAR *ppStub);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_ReadMultiple ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ ULONG cpspec,
	    /* [size_is][in] */ const PROPSPEC __RPC_FAR rgpspec[  ],
	    /* [size_is][out] */ PROPVARIANT __RPC_FAR rgpropvar[  ]);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_WriteMultiple ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ ULONG cpspec,
	    /* [size_is][in] */ const PROPSPEC __RPC_FAR rgpspec[  ],
	    /* [size_is][in] */ const PROPVARIANT __RPC_FAR rgpropvar[  ],
	    /* [in] */ PROPID propidNameFirst);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_DeleteMultiple ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ ULONG cpspec,
	    /* [size_is][in] */ const PROPSPEC __RPC_FAR rgpspec[  ]);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_ReadPropertyNames ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ ULONG cpropid,
	    /* [size_is][in] */ const PROPID __RPC_FAR rgpropid[  ],
	    /* [size_is][out] */ LPOLESTR __RPC_FAR rglpwstrName[  ]);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_WritePropertyNames ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ ULONG cpropid,
	    /* [size_is][in] */ const PROPID __RPC_FAR rgpropid[  ],
	    /* [size_is][in] */ const LPOLESTR __RPC_FAR rglpwstrName[  ]);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_DeletePropertyNames ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ ULONG cpropid,
	    /* [size_is][in] */ const PROPID __RPC_FAR rgpropid[  ]);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_Commit ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ DWORD grfCommitFlags);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_Revert (
		IPropertyStorage __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_Enum ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [out] */ IEnumSTATPROPSTG __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_SetTimes ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ const FILETIME __RPC_FAR *pctime,
	    /* [in] */ const FILETIME __RPC_FAR *patime,
	    /* [in] */ const FILETIME __RPC_FAR *pmtime);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_SetClass ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [in] */ REFCLSID clsid);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertyStorage_Stat ( 
	    IPropertyStorage __RPC_FAR * This, 
	    /* [out] */ STATPROPSETSTG __RPC_FAR *pstatpsstg);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertySetStorage_Create ( 
	    IPropertySetStorage __RPC_FAR * This, 
	    /* [in] */ REFFMTID rfmtid,
	    /* [unique][in] */ const CLSID __RPC_FAR *pclsid,
	    /* [in] */ DWORD grfFlags,
	    /* [in] */ DWORD grfMode,
	    /* [out] */ IPropertyStorage __RPC_FAR *__RPC_FAR *ppprstg);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertySetStorage_Open ( 
	    IPropertySetStorage __RPC_FAR * This, 
	    /* [in] */ REFFMTID rfmtid,
	    /* [in] */ DWORD grfMode,
	    /* [out] */ IPropertyStorage __RPC_FAR *__RPC_FAR *ppprstg);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertySetStorage_Delete ( 
	    IPropertySetStorage __RPC_FAR * This, 
	    /* [in] */ REFFMTID rfmtid);

extern HRESULT __stdcall __RPC_FAR
DW_IPropertySetStorage_Enum ( 
	    IPropertySetStorage __RPC_FAR * This, 
	    /* [out] */ IEnumSTATPROPSETSTG __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSTG_Next ( 
	    IEnumSTATPROPSTG __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ STATPROPSTG __RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSTG_Skip ( 
	    IEnumSTATPROPSTG __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSTG_Reset (
		IEnumSTATPROPSTG __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSTG_Clone ( 
	    IEnumSTATPROPSTG __RPC_FAR * This, 
	    /* [out] */ IEnumSTATPROPSTG __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSETSTG_Next ( 
	    IEnumSTATPROPSETSTG __RPC_FAR * This, 
	    /* [in] */ ULONG celt,
	    /* [length_is][size_is][out] */ STATPROPSETSTG __RPC_FAR *rgelt,
	    /* [out] */ ULONG __RPC_FAR *pceltFetched);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSETSTG_Skip ( 
	    IEnumSTATPROPSETSTG __RPC_FAR * This, 
	    /* [in] */ ULONG celt);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSETSTG_Reset (
		IEnumSTATPROPSETSTG __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IEnumSTATPROPSETSTG_Clone ( 
	    IEnumSTATPROPSETSTG __RPC_FAR * This, 
	    /* [out] */ IEnumSTATPROPSETSTG __RPC_FAR *__RPC_FAR *ppenum);

extern HRESULT __stdcall __RPC_FAR
DW_ILayoutStorage_LayoutScript ( 
	    ILayoutStorage __RPC_FAR * This, 
	    /* [in] */ StorageLayout __RPC_FAR *pStorageLayout,
	    /* [in] */ DWORD nEntries,
	    /* [in] */ DWORD glfInterleavedFlag);

extern HRESULT __stdcall __RPC_FAR
DW_ILayoutStorage_BeginMonitor (
		ILayoutStorage __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_ILayoutStorage_EndMonitor (
		ILayoutStorage __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_ILayoutStorage_ReLayoutDocfile ( 
	    ILayoutStorage __RPC_FAR * This, 
	    /* [in] */ OLECHAR __RPC_FAR *pwcsNewDfName);

extern HRESULT __stdcall __RPC_FAR
DW_ILayoutStorage_ReLayoutDocfileOnILockBytes ( 
	    ILayoutStorage __RPC_FAR * This, 
	    /* [in] */ ILockBytes __RPC_FAR *pILockBytes);

extern HRESULT __stdcall __RPC_FAR
DW_IDirectWriterLock_WaitForWriteAccess ( 
	    IDirectWriterLock __RPC_FAR * This, 
	    /* [in] */ DWORD dwTimeout);

extern HRESULT __stdcall __RPC_FAR
DW_IDirectWriterLock_ReleaseWriteAccess (
		IDirectWriterLock __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_IDirectWriterLock_HaveWriteAccess (
		IDirectWriterLock __RPC_FAR * This);

extern HRESULT __stdcall __RPC_FAR
DW_ICancelMethodCalls_Cancel (
		ICancelMethodCalls __RPC_FAR * This, 
		/* [in] */ ULONG ulSeconds);

extern HRESULT __stdcall __RPC_FAR
DW_ICancelMethodCalls_TestCancel (
		ICancelMethodCalls __RPC_FAR * This);
