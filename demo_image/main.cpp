
#define SHARED_OBJECT

#include <cstdio>
#include <cstring>
#include <cstdint>

#include "../interface.h"

using namespace std;

image src, src_thr, dst;
int hor_row = 100;

bool is_correct_index(const bool is_param, const unsigned ind)
{
	return ((is_param && ind < 3) || (! is_param && ind < 1));
}

// ############################################################################ 

int EXPORT_FUNCTION init(char * module_name, const unsigned module_name_len, unsigned * param_num, unsigned * return_value_num)
{
	src = NULL;
	src_thr = NULL;
	dst = NULL;

	strncpy(module_name, "demo_image", module_name_len);
	module_name[module_name_len - 1] = '\0';

	* param_num = 3;
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
			strncpy(name, "Source image - threshold", name_len);

			break;
		}
		case 2:
		{
			strncpy(name, "Rows number", name_len);

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
			* type = IMAGE_TYPE;

			break;
		}
		case 1:
		{
			* type = IMAGE_TYPE;

			break;
		}
		case 2:
		{
			* type = INT_TYPE;

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
			* (s_image **) value = is_param ? src : dst;

			break;
		}
		case 1:
		{
			* (s_image **) value = src_thr;

			break;
		}
		case 2:
		{
			* (int *) value = hor_row;

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
				src = * (s_image **) value;
			else
				dst = * (s_image **) value;

			break;
		}
		case 1:
		{
			src_thr = * (s_image **) value;

			break;
		}
		case 2:
		{
			hor_row = * (int *) value;

			break;
		}
	}

	return 0;
}

// ############################################################################ 

int EXPORT_FUNCTION run()
{
	uint8_t value;
	unsigned v, u, t;
	const unsigned height = src->height, width = src->width;
	
	dst = image_copy(src);

	for(v = hor_row; v < height; v++)
		for(u = 0; u < width; u++)
			for(t = 0; t < 3; t++)
			{
				matrix_get_value(src_thr->mat, v, u, t, & value);
				matrix_set_value(dst->mat, v, u, t, & value);
			}

	return 0;
}

