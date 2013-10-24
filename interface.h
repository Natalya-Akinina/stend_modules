
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
- matrix_element_type();
- matrix_pointer_to_data().

Модуль <B>должен</B> выделять в функции init() и самостоятельно очищать в функции destroy() память под свои возвращаемые значения. Память под свои параметры модуль может самостоятельно выделять, а может и не выделять. В том случае, если модуль не выделяет память под свои параметры, он <B>ни коим образом не должен</B> управлять памятью, выделенной под его параметры.

*/

#ifndef INTERFACE_HPP
#define INTERFACE_HPP

#ifndef EXPORT_VARIABLE

	/*! \brief Константа компилятора, отмечающая переменные, экспортируемые из модуля
	 *
	 * Устанавливается до подключения файла в зависимости от используемого компилятора
	 */
	#define EXPORT_VARIABLE

#endif

#ifndef EXPORT_FUNCTION

	/*! \brief Константа компилятора, отмечающая функции, экспортируемые из модуля
	 *
	 * Устанавливается до подключения файла в зависимости от используемого компилятора
	 */
	#define EXPORT_FUNCTION

#endif

#ifdef __cplusplus
extern "C"
{
#endif

	// ############################################################################ 
	//@{

	//! \name Типы элементов матриц
	
	//! \brief Целое, 8-ми битное, беззнаковое (uint8_t)
	#define UNSIGNED_INT_8_BIT_ELEMENT 0

	//! \brief Вещественное двойной точности (double)
	#define DOUBLE_ELEMENT 1

	//@}
	// ############################################################################ 

	//! \brief Описатель матрицы
	typedef void * matrix;

	/*!
	
	\brief Структура данных, описывающая изображения

	Изображение может иметь произвольное количество каналов.

	Каждый канал изображения должен быть восьмибитным беззнаковым.

	*/
	struct s_image
	{
		//! Количество строк пикселей
		unsigned height;

		//! Количество столбцов пикселей
		unsigned width;

		//! Количество спектральных каналов
		unsigned ch_num;

		//! Матрица пикселей
		matrix mat;
	};

	//! \brief Описатель изображения
	typedef s_image * image;

	// ############################################################################ 
	//@{

	//! \name Типы входных и выходных параметров алгоритма
	
	//! \brief Целое со знаком (int)
	#define INT_TYPE 0
	
	//! \brief Вещественное двойной точности (double)
	#define DOUBLE_TYPE 1

	//! \brief Строка (char *)
	#define STRING_TYPE 2

	//! \brief Булев тип (int)
	#define BOOLEAN_TYPE 3

	//! \brief Матрица (matrix)
	#define MATRIX_TYPE 4

	//! \brief Изображение (image)
	#define IMAGE_TYPE 5

	//@}
	// ############################################################################ 

#ifdef SHARED_OBJECT

	// ############################################################################
	// Служебные функции - изображения

	EXPORT_VARIABLE image (* image_create)(const unsigned height, const unsigned width, const unsigned ch_num);
	EXPORT_VARIABLE int (* image_delete)(const image img);

	// ############################################################################
	// Служебные функции - матрицы
	
	EXPORT_VARIABLE matrix (* matrix_create)(const unsigned height, const unsigned width, const unsigned ch_num, const int element_type);
	EXPORT_VARIABLE int (* matrix_delete)(matrix mtx);
	EXPORT_VARIABLE matrix (* matrix_copy)(matrix mtx);
	EXPORT_VARIABLE matrix (* matrix_load_image)(const char * fname);
	EXPORT_VARIABLE int (* matrix_save_image)(matrix mtx, const char * fname);
	EXPORT_VARIABLE int (* matrix_get_value)(matrix mtx, const unsigned row, const unsigned column, const unsigned channel, void * value);
	EXPORT_VARIABLE int (* matrix_set_value)(matrix mtx, const unsigned row, const unsigned column, const unsigned channel, const void * value);
	EXPORT_VARIABLE int (* matrix_height)(matrix mtx, unsigned * value);
	EXPORT_VARIABLE int (* matrix_width)(matrix mtx, unsigned * value);
	EXPORT_VARIABLE int (* matrix_number_of_channel)(matrix mtx, unsigned * value);
	EXPORT_VARIABLE int (* matrix_element_type)(matrix mtx, int * value);
	EXPORT_VARIABLE int (* matrix_pointer_to_data)(matrix mtx, void ** ptr);

#else

	//! \cond HIDDEN_SYMBOLS

	#define HIDDEN __attribute__ ((visibility ("hidden")))

	//! \endcond

	// ############################################################################
	// Служебные функции - изображения

	/*!

	\brief Создание изображения

	\param height - количество строк в изображении;
	\param width - количество столбцов в изображении;
	\param ch_num - количество каналов в изображении.

	\return указатель на созданное изображение - в случае успешного создания изображения;
	\return NULL - в случае, если создать изображение не удалось.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	image image_create(const unsigned height, const unsigned width, const unsigned ch_num);

	/*!
	
	\brief Удаление изображения

	\param img - указатель на описатель изображения.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int image_delete(const image img);

	// ############################################################################
	// Служебные функции - матрицы

	/*!
	
	\brief Создание матрицы

	\param height - количество строк в матрице;
	\param width - количество столбцов в матрице;
	\param ch_num - количество каналов в матрице;
	\param element_type - тип элемента матрицы.

	\return описатель созданной матрицы - в случае ее успешного создания;
	\return NULL - в случае, если матрицу создать не удалось.

	\sa UNSIGNED_INT_8_BIT_ELEMENT, DOUBLE_ELEMENT

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	matrix matrix_create(const unsigned height, const unsigned width, const unsigned ch_num, const int element_type);

	/*!
	
	\brief Копирование матрицы

	\param mtx - копируемая матрица.

	\return описатель скопированной матрицы - в случае ее успешного копирования;
	\return NULL - в случае, если матрицу скопировать не удалось.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	matrix matrix_copy(matrix mtx);

	/*!
	
	\brief Загрузка изображения

	\param fname - полный путь и имя файла с изображением.

	\return указатель на созданную матрицу - в случае, если загрузка изображения прошла успешно;
	\return NULL - в случае, если загрузить изображение не удалось.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	matrix matrix_load_image(const char * fname);

	/*!
	
	\brief Сохранение изображения

	\param mtx - описатель матрицы;
	\param fname - полный путь и имя файла, в который будет сохранено изображение.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_save_image(matrix mtx, const char * fname);

	/*!
	
	\brief Получение значения элемента матрицы

	\param mtx - описатель матрицы;
	\param row - номер строки;
	\param column - номер стоблца;
	\param channel - номер канала (нумерация от 0);
	\param value - указатель на переменную, в которой будет сохранено получаемое значение.

	В случае, если матрица не является изображением, то в качестве channel можно указывать 0 (индекс единственного канала матрицы).

	Тип value должен совпадать с типом элемента матрицы.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_get_value(matrix mtx, const unsigned row, const unsigned column, const unsigned channel, void * value);

	/*!
	
	\brief Установ значения элемента матрицы

	\param mtx - описатель матрицы;
	\param row - номер строки;
	\param column - номер стоблца;
	\param channel - номер канала (нумерация от 0);
	\param value - указатель на переменную, хранящую устанавливаемое значение.

	В случае, если матрица не является изображением, то в качестве channel можно указывать 0 (индекс единственного канала матрицы).

	Тип value должен совпадать с типом элемента матрицы.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_set_value(matrix mtx, const unsigned row, const unsigned column, const unsigned channel, const void * value);

	/*!
	
	\brief Получение количества строк в матрице

	\param mtx - описатель матрицы;
	\param value - указатель на переменную, в которой будет возвращено количество строк в матрице.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_height(matrix mtx, unsigned * value);

	/*!
	
	\brief Получение количества столбцов в матрице

	\param mtx - описатель матрицы;
	\param value - указатель на переменную, в которой будет возвращено количество столбцов в матрице.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_width(matrix mtx, unsigned * value);

	/*!
	
	\brief Получение количества спектральных каналов в матрице

	\param mtx - описатель матрицы;
	\param value - указатель на переменную, в которой будет возвращено количество каналов в матрице.

	Данная функция используется в случае, если матрица хранит изображение.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_number_of_channel(matrix mtx, unsigned * value);

	/*!
	
	\brief Определение типа элементов матрицы

	\param mtx - описатель матрицы;
	\param value - указатель на переменную, в которой будет возвращен код типа элемента матрицы.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	\sa UNSIGNED_INT_8_BIT_ELEMENT, DOUBLE_ELEMENT

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_element_type(matrix mtx, int * value);

	/*!
	
	\brief Удаление матрицы

	\param mtx - описатель матрицы.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_delete(matrix mtx);

	/*!
	
	\brief Получение указателя на область памяти, в которой хранится содержимое матрицы

	\param mtx - описатель матрицы;
	\param ptr - указатель на указатель, в котором будет возвращен адрес области памяти, содержащей содержимое матрицы.

	\return 0 - в случае успешного завершения операции;
	\return <> 0 - в случае неудачного завершения операции.

	*/
	/*! \cond HIDDEN_SYMBOLS */ HIDDEN /*! \endcond */
	int matrix_pointer_to_data(matrix mtx, void ** ptr);

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

