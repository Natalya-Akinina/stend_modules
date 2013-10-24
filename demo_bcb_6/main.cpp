
#define SHARED_OBJECT
#define EXPORT_VARIABLE __declspec(dllexport)
#define EXPORT_FUNCTION __declspec(dllexport) __cdecl
                
#include <windows.h>
#include <cstdio>
#include <cstring>

#include "../interface.h"

using namespace std;     

#pragma argsused
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fwdreason, LPVOID lpvReserved)
{
        return 1;
}

image src, dst;
char * in, * out;

bool is_correct_index(const bool is_param, const unsigned ind)
{
        return ind < 2;
}

// ############################################################################ 

int EXPORT_FUNCTION init(char * module_name, const unsigned module_name_len, unsigned * param_num, unsigned * return_value_num)
{
	src = NULL;
	dst = NULL;
        in = NULL;
        out = NULL;

	strncpy(module_name, "demo_bcb_6", module_name_len);
	module_name[module_name_len - 1] = '\0';

	* param_num = 2;
	* return_value_num = 2;

	return 0;
}

int EXPORT_FUNCTION destroy()
{
	return 0;
}

// ############################################################################ 

int EXPORT_FUNCTION get_name(const bool is_param, const unsigned ind, char * name, const unsigned name_len)
{
	if(! is_correct_index(is_param, ind))
		return -1;

	switch(ind)
	{
		case 0:
		{
			strncpy(name, is_param ? "Source image" : "Destination image", name_len);

			break;
		}
		case 1:
		{
			strncpy(name, is_param ? "Source string" : "Destination string", name_len);

			break;
		}
	}

	return 0;
}

int EXPORT_FUNCTION get_type(const bool is_param, const unsigned ind, int * type)
{
	if(! is_correct_index(is_param, ind))
		return -1;

	switch(ind)
	{
		case 0:
		{
			(* type) = IMAGE_TYPE;

			break;
		}
		case 1:
		{
			(* type) = STRING_TYPE;

			break;
		}
	}

	return 0;
}

int EXPORT_FUNCTION get_value(const bool is_param, const unsigned ind, void * value)
{
	if(! is_correct_index(is_param, ind))
		return -1;

	switch(ind)
	{
		case 0:
		{
			* (image *) value = is_param ? src : dst;

			break;
		}
		case 1:
		{
			* (char **) value = is_param ? in : out;

			break;
		}
	}

	return 0;
}

int EXPORT_FUNCTION set_value(const bool is_param, const unsigned ind, const void * value)
{
	if(! is_correct_index(is_param, ind))
		return -1;

	switch(ind)
	{
		case 0:
		{
			if(is_param)
				src = * (image *) value;
			else
				dst = * (image *) value;

			break;
		}
		case 1:
		{
			if(is_param)
				in = * (char **) value;
			else
				out = * (char **) value;

			break;
		}
	}

	return 0;
}

// ############################################################################ 

int EXPORT_FUNCTION run()
{
        dst = image_create(src->height, src->width, src->ch_num);

        printf("TODO %s\n", in);

        if(out == NULL)
                out = strdup("TODO out string");

	return 0;
}

