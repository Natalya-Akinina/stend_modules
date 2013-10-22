
/*!

\file

\brief Интерфейс сторонних модулей - реализаций алгоритмов

Заголовочный файл совместим со стандартами C90 и C++03.

В пользовательских модулях необходимо реализовать следующие функции:

- init();
- destroy();
- run();
- get_name();
- get_type();
- get_value();
- set_value().

Следующие функции являются служебными и предоставляются стендом для пользовательских модулей:

- image_create();
- image_delete();
- matrix_create();
- matrix_delete();
- matrix_copy();
- matrix_load_image();
- matrix_save_image();
- matrix_get_value();
- matrix_set_value();
- matrix_height();
- matrix_width();
- matrix_number_of_channel();
- matrix_element_type().

Модуль <B>должен</B> выделять в функции init() и самостоятельно очищать в функции destroy() память под свои возвращаемые значения. Память под свои параметры модуль может самостоятельно выделять, а может и не выделять. В том случае, если модуль не выделяет память под свои параметры, он <B>ни коим образом не должен</B> управлять памятью, выделенной под его параметры.

*/

#ifndef INTERFACE_HPP
#define INTERFACE_HPP

#ifndef EXPORT_VARIABLE

	/*! \brief Константа компилятора, отмечающая переменные, экспортируемые из модуля
	 *
	 * Устанавливается в зависимости от используемого компилятора
	 */
	#define EXPORT_VARIABLE

#endif

#ifndef EXPORT_FUNCTION

	/*! \brief Константа компилятора, отмечающая функции, экспортируемые из модуля
	 *
	 * Устанавливается в зависимости от используемого компилятора
	 */
	#define EXPORT_FUNCTION

#endif

#ifdef __cplusplus
extern "C"
{
#endif

	/* ############################################################################ */
	/* Типы данных входных и выходных параметров алгоритма */

	// TODO Документация
	/*! \brief Типы элементов матриц */
	
	/*! Целое, 8-ми битное, беззнаковое (uint8_t) */
	#define UNSIGNED_INT_8_BIT_ELEMENT 0

	/*! Вещественное двойной точности (double) */
	#define DOUBLE_ELEMENT 1

	// ############################################################################ 

	/*! \brief Описатель матрицы */
	typedef void * matrix;

	/*!
	
	\brief Структура данных, описывающая изображения

	Изображение может иметь произвольное количество каналов.

	Каждый канал изображения должен быть восьмибитным беззнаковым.

	*/
	struct s_image
	{
		/*! Количество строк пикселей */
		unsigned height;

		/*! Количество столбцов пикселей */
		unsigned width;

		/*! Количество спектральных каналов */
		unsigned ch_num;

		/*! Матрица пикселей */
		matrix mat;
	};

	/*! \brief Описатель изображения */
	typedef s_image * image;

	// ############################################################################ 
	/*! \brief Типы входных и выходных параметров алгоритма */
	
	// TODO

	/*! Целое со знаком (int) */
	#define INT_TYPE 0
	
	/*! Вещественное двойной точности (double) */
	#define DOUBLE_TYPE 1

	/*! Строка (char *) */
	#define STRING_TYPE 2

	/*! Булев тип (int) */
	#define BOOLEAN_TYPE 3

	/*! Матрица (matrix) */
	#define MATRIX_TYPE 4

	/*! Изображение (image) */
	#define IMAGE_TYPE 5

	// ############################################################################ 

#ifdef SHARED_OBJECT

	/* ############################################################################ */
	/* Служебные функции - изображения */

	/*!

	\brief Создание изображения

	\param height - количество строк в изображении;
	\param width - количество столбцов в изображении;
	\param ch_num - количество каналов в изображении.

	\return указатель на созданное изображение - в случае успешного создания изображения;
	\return NULL - в случае, если создать изображение не удалось.

	*/
	EXPORT_VARIABLE image (* image_create)(const unsigned height, const unsigned width, const unsigned ch_num);

	/*!
	
	\brief Удаление изображения

	\param img - указатель на описатель изображения.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.
	*/
	EXPORT_VARIABLE int (* image_delete)(const image img);

	/* ############################################################################  */
	/* Служебные функции - матрицы */
	
	/* TODO */
	EXPORT_VARIABLE matrix (* matrix_create)(const unsigned height, const unsigned width, const unsigned ch_num, const int element_type);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_delete)(matrix mtx);

	/* TODO */
	EXPORT_VARIABLE matrix (* matrix_copy)(matrix mtx);

	/* TODO */
	EXPORT_VARIABLE matrix (* matrix_load_image)(const char * fname);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_save_image)(matrix mtx, const char * fname);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_get_value)(matrix mtx, const unsigned row, const unsigned column, const unsigned channel, void * value);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_set_value)(matrix mtx, const unsigned row, const unsigned column, const unsigned channel, const void * value);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_height)(matrix mtx, unsigned * value);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_width)(matrix mtx, unsigned * value);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_number_of_channel)(matrix mtx, unsigned * value);

	/* TODO */
	EXPORT_VARIABLE int (* matrix_element_type)(matrix mtx, int * value);

#endif

	/* ############################################################################  */
	/* Интерфейс модуля */

	/*!

	\brief Инициализация модуля

	\param module_name - строка, в которой будет возвращено название модуля;
	\param module_name_len - максимальное количество байт в названии модуля (считая конечный нулевой байт).
	\param param_num - указатель на целочисленную переменную, в которой должно быть возвращено количество параметров алгоритма, реализуемого модулем;
	\param return_value_num - указатель на целочисленную переменную, в которой должно быть возвращено количество значений, возвращаемых алгоритмом в вызывающую процедуру.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION init(char * module_name, const unsigned module_name_len, unsigned * param_num, unsigned * return_value_num);

	/*!

	\brief Деструктор модуля

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION destroy();

	/*!

	\brief Запуск алгоритма на выполнение

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION run();

	/* ############################################################################  */
	/* Параметры и возвращаемые значения алгоритма */

	/*!

	\brief Получение имени внешней переменной алгоритма (параметра или возвращаемого значения)

	\param is_param - флаг обращения к внешней переменной алгоритма (true, если обращение производится к параметру алгоритма, false - если обращение производится к возвращаемому значению алгоритма);
	\param ind - индекс внешней переменной, считая от нуля;
	\param name - строка, в которой будет возвращено имя внешней переменной;
	\param name_len - максимальное количество байт (!) в имени внешней переменной (считая конечный нулевой байт).

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION get_name(const bool is_param, const unsigned ind, char * name, const unsigned name_len);

	/*!

	\brief Получение типа внешней переменной алгоритма (параметра или возвращаемого значения)

	\param is_param - флаг обращения к внешней переменной алгоритма (true, если обращение производится к параметру алгоритма, false - если обращение производится к возвращаемому значению алгоритма);
	\param ind - индекс внешней переменной, считая от нуля;
	\param type - указатель на переменную, в которой будет возвращен индекс типа внешней переменной.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION get_type(const bool is_param, const unsigned ind, int * type);

	/*!

	\brief Получение фактического значения внешней переменной алгоритма (параметра или возвращаемого значения)

	\param is_param - флаг обращения к внешней переменной алгоритма (true, если обращение производится к параметру алгоритма, false - если обращение производится к возвращаемому значению алгоритма);
	\param ind - индекс внешней переменной алгоритма, считая от нуля;
	\param value - указатель на переменную, в которую будет сохранено фактическое значение внешней переменной алгоритма.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION get_value(const bool is_param, const unsigned ind, void * value);

	/*!

	\brief Установ фактического значения внешней переменной алгоритма (параметра или возвращаемого значения)

	\param is_param - флаг обращения к внешней переменной алгоритма (true, если обращение производится к параметру алгоритма, false - если обращение производится к возвращаемому значению алгоритма);
	\param ind - индекс внешней переменной алгоритма, считая от нуля;
	\param value - указатель на переменную, хранящую фактическое значение внешней переменной алгоритма.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	int EXPORT_FUNCTION set_value(const bool is_param, const unsigned ind, const void * value);

#ifdef __cplusplus
}
#endif

#endif

