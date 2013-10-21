
#include <cstdio>
#include <opencv2/opencv.hpp>

#include "interface.h"

using namespace std;
using namespace cv;

#define HEIGHT 32
#define WIDTH 56
#define SIZE 1792

s_image * src, * dst;
double w[SIZE][SIZE];

int init(char * module_name, const unsigned module_name_len, unsigned * param_num, unsigned * return_value_num)
{
	unsigned i, j;

	strncpy(module_name, "ica", module_name_len);
	module_name[module_name_len - 1] = '\0';

	* param_num = 1;
	* return_value_num = 1;

	for(i = 0; i < SIZE; i++)
		for(j = 0;j < SIZE; j++)
			w[i][j] = (drand48() - 0.5) / 0.5;

	return 0;
}

int destroy()
{
	return 0;
}

// ############################################################################

int get_name(const bool is_param, const unsigned ind, char * name, const unsigned name_len)
{
	if(ind)
		return -1;

	if(is_param)
	    strncpy(name, "Sourse image", name_len);
    else
        strncpy(name,"Destination image", name_len);

	return 0;
}

int get_type(const bool is_param, const unsigned ind, e_type * type)
{
	if(ind)
		return -1;

    * type = IMAGE_TYPE;

	return 0;
}

int get_value(const bool is_param, const unsigned ind, void * value)
{
	if(ind)
		return -1;

    if (is_param)
        * (s_image **) value = src;
    else
        * (s_image **) value = dst;

	return 0;
}

int set_value(const bool is_param, const unsigned ind, const void * value)
{
    if (ind || !is_param)
        return -1;

    src = * (s_image **) value;

	return 0;
}

// ############################################################################

double f(const double value)
{
	return value * value * (value < 0 ? -1 : 1);
}

double g(const double value)
{
	return 3 * tanh(10 * value);
}

int run()
{
	unsigned i, j, t;
	double teta;
	double x[SIZE], y[SIZE];

	dst = image_create(src->height, src->width, 1);

    const Mat * src_mat = (Mat *) src->mat;
	Mat * dst_mat = (Mat *) dst->mat;

	for(i = 0, t = 0; i < HEIGHT; i++)
		for(j = 0; j < WIDTH; j++, t++)
		{
			const Vec3b pixel = src_mat->at<Vec3b>(i, j);
			x[t] = ((double) pixel[0] - 127.5) / 127.5;
		}

	for(i = 0; i < SIZE; i++)
	{
		y[i] = 0;

		for(j = 0; j < SIZE; j++)
			y[i] += w[i][j] * x[j];
	}

	teta = 0;

	for(i = 0; i < SIZE; i++)
		teta += f(y[i]) * g(y[i]);

	teta = 1 - teta;

	for(i = 0; i < SIZE; i++)
		for(j = 0; j < SIZE; j++)
			w[i][j] += teta * w[i][j];

	for(i = 0, t = 0; i < HEIGHT; i++)
		for(j = 0; j < WIDTH; j++, t++)
			dst_mat->at<uint8_t>(i, j) = y[t] * 127.5 + 127.5;
	
	return 0;
}

