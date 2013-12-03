
#define SHARED_OBJECT
#define EXPORT_VARIABLE __declspec(dllexport)
#define EXPORT_FUNCTION __declspec(dllexport) __cdecl
                
#include <windows.h>
#include <vcl.h>
#include <cstdio>
#include <cstring>
#include <vector>

#include "../interface.h"

using namespace std;     

#define throw_ \
{\
	fprintf(stderr, "[Exception] File %s, Line %d\n", __FILE__, __LINE__);\
	throw 1;\
};

#define throw_if(condition) \
{\
	if((condition))\
		throw_;\
}

#define throw_null(pointer) \
	throw_if((pointer) == NULL)

#pragma argsused
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fwdreason, LPVOID lpvReserved)
{
	return 1;
}

int code;
void * src, * dst;

// ############################################################################

int EXPORT_FUNCTION init(char * module_name, const unsigned module_name_len, unsigned * param_num, unsigned * return_value_num)
{
	dst = NULL;

	strncpy(module_name, "meaningless_demo_bcb_6", module_name_len);
	module_name[module_name_len - 1] = '\0';

	* param_num = 2;
	* return_value_num = 1;

	return 0;
}

int EXPORT_FUNCTION destroy()
{
	return 0;
}

// ############################################################################ 

int EXPORT_FUNCTION get_name(const bool is_param, const unsigned ind, char * name, const unsigned name_len)
{
	if((is_param && ind > 1) || (! is_param && ind))
		return -1;

        strncpy(name, "TODO", name_len);

	return 0;
}

int EXPORT_FUNCTION get_type(const bool is_param, const unsigned ind, int * type)
{
	if((is_param && ind > 1) || (! is_param && ind))
		return -1;

        (* type) = is_param && ind ? INT_TYPE : VOID_POINTER_TYPE;

	return 0;
}

int EXPORT_FUNCTION get_value(const bool is_param, const unsigned ind, void * value)
{
	if((is_param && ind > 1) || (! is_param && ind))
		return -1;

        if(is_param)
        {
                if(ind)
                        * (int *) value = code;
                else
                        * (void **) value = src;
        }
        else
        	* (void **) value = dst;

	return 0;
}

int EXPORT_FUNCTION set_value(const bool is_param, const unsigned ind, const void * value)
{
	if((is_param && ind > 1) || (! is_param && ind))
		return -1;

        if(is_param)
        {
                if(ind)
                        code = * (int *) value;
                else
                        src = * (void **) value;
        }
        else
                dst = * (void **) value;

	return 0;
}

// ############################################################################ 

int EXPORT_FUNCTION run()
{
        switch(code)
        {
                case 0:
                {
                        vector<TPoint> * cnt = new vector<TPoint>;

                        cnt->push_back(TPoint(1988, 28));
                        cnt->push_back(TPoint(10, 40));
                        cnt->push_back(TPoint(777, 555));

                        dst = (void *) cnt;

                        break;
                }
                case 1:
                {
                        vector<TPoint> & cnt = * (vector<TPoint> *) src;
                        const unsigned size = cnt.size();
                        unsigned v;

                        for(v = 0; v < size; v++)
                                printf("Point %u = %d %d\n", v, cnt[v].x, cnt[v].y);

                        dst = NULL;

                        break;
                }
                case 2:
                {                                                       
                        delete ((vector<TPoint> *) src);
                        dst = NULL;

                        break;
                }

        }

	return 0;
}

