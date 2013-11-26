
#define SHARED_OBJECT
#define EXPORT_VARIABLE __declspec(dllexport)
#define EXPORT_FUNCTION __declspec(dllexport) __cdecl
                
#include <windows.h>
#include <vcl.h>
#include <cstdio>
#include <cstring>

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

image src, dst;
char * in, * out;

bool is_correct_index(const bool is_param, const unsigned ind)
{
	return ind < 2;
}

Graphics::TBitmap * matrix_to_TBitmap(matrix mtx)
{
	Graphics::TBitmap * img = NULL;

	try
	{
		unsigned height, width, ch_num, v, scale;
		int elem_type;       
                void * ptr;

		throw_if(matrix_height(mtx, & height));
		throw_if(matrix_width(mtx, & width));
		throw_if(matrix_number_of_channels(mtx, & ch_num));
		throw_if(matrix_element_type(mtx, & elem_type));
		throw_null(img = new Graphics::TBitmap);

		img->Height = height;
		img->Width = width;

		switch(elem_type)
		{
			case UNSIGNED_INT_8_BIT_ELEMENT:
			{
				switch(ch_num)
				{
					case 1:
					{
						img->PixelFormat = pf8bit;
						scale = 1;
						
						struct
                        {
							WORD palVersion;
							WORD palNumEntries;
							PALETTEENTRY palEntry[256];
						} palette;

						palette.palVersion = 0x300;
						palette.palNumEntries = 256;

						for(v = 0; v < 256; v++)
						{
							palette.palEntry[v].peRed = v;
							palette.palEntry[v].peGreen = v;
							palette.palEntry[v].peBlue = v;
							palette.palEntry[v].peFlags = PC_NOCOLLAPSE;
						}

						img->Palette = CreatePalette((LOGPALETTE *)& palette);

						break;
					}
					case 3:
					{
						img->PixelFormat = pf24bit;
						scale = 3;

						break;
					}
					default:
					{
						throw_;
					}
				}

				break;
			}
			case DOUBLE_ELEMENT:
			{
				throw_;
			}
			default:
			{
				throw_;
			}
		}

		for(v = 0; v < height; v++)
		{
			throw_if(matrix_pointer_to_row(mtx, v, & ptr));
			memcpy(img->ScanLine[v], ptr, width * scale);
		}
	}
	catch(...)
	{
		if(img != NULL)
			delete img;

		img = NULL;
	}

	return img;
}

image TBitmap_to_image(const Graphics::TBitmap * img)
{
	image __img = NULL;

	try
	{
		const unsigned height = img->Height, width = img->Width;
		unsigned v, u, u_3, u_4;
		unsigned char * ptr, * line;

		switch(img->PixelFormat)
		{
			case pf8bit:
			{
				PALETTEENTRY palette[256], color;

				__img = image_create(height, width, 3);
				GetPaletteEntries(img->Palette, 0, 256, palette);

				for(v = 0; v < height; v++)
				{
					throw_if(matrix_pointer_to_row(__img->mat, v, (void **) & ptr));
					line = (unsigned char *) img->ScanLine[v];

					for(u = 0, u_3 = 0; u < width; u++, u_3 += 3)
					{
						color = palette[ line[u] ];

						ptr[u_3] = color.peRed;
						ptr[u_3 + 1] = color.peGreen;
						ptr[u_3 + 2] = color.peBlue;
					}
				}

				break;
				}
			case pf24bit:
			{
				__img = image_create(height, width, 3);

				for(v = 0; v < height; v++)
				{
					throw_if(matrix_pointer_to_row(__img->mat, v, (void **) & ptr));
					memcpy(ptr, img->ScanLine[v], width * 3);
				}

				break;
			}
			case pf32bit:
			{ 
				__img = image_create(height, width, 3);

				for(v = 0; v < height; v++)
				{
					throw_if(matrix_pointer_to_row(__img->mat, v, (void **) & ptr));
					line = (unsigned char *) img->ScanLine[v];

					for(u = 0, u_3 = 0, u_4 = 0; u < width; u++, u_3 += 3, u_4 += 4)
						memcpy(ptr + u_3, line + u_4, 3);
				}

				break;
			}
			default:
			{
				throw_;
			}
		}
	}
	catch(...)
	{
		if(__img != NULL)
			image_delete(__img);

		__img = NULL;
	}

	return __img;
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
	dst = image_copy(src);

	printf("In module: %s\n", in);

	if(out == NULL)
		out = strdup("Output string");

	return 0;
}

