//  SERVICE_PORT = 8404

struct TRFileInfo
{
	1:string name,
	2:string path,
	3:i64 size,
}

service TransferServ
{
	list<TRFileInfo> find_file_path()
	binary download(1:TRFileInfo file_info, 2:i32 length=0, 3:i32 offset=0)
	bool already_exist(1:TRFileInfo file_info)
	void upload(1:TRFileInfo file_info, 2:binary payload)

	void print_message(1:string msg)
}