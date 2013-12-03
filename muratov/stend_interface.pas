
unit stend_interface;

interface
     
uses Windows, graphics, types;

type

  p_void = pointer;
  pp_void = ^ p_void;
  int = dword;
  p_int = ^int;
  unsigned = dword;
  p_unsigned = ^unsigned;

  matrix = pointer;
  p_matrix = ^matrix;

  s_image = record

    height : unsigned;
    width : unsigned;
    ch_num : unsigned;
    mat : matrix;

  end;

  image = ^s_image;
  p_image = ^image;

	t_image_create = function(height : unsigned; width : unsigned; ch_num : unsigned) : image; cdecl;
  t_image_delete = function(img : image) : int; cdecl;
  t_image_copy = function(img : image) : image; cdecl;
  t_matrix_to_image = function(mtx : matrix) : image; cdecl;
  t_matrix_create = function(height : unsigned; width : unsigned; ch_num : unsigned) : matrix; cdecl;
  t_matrix_delete = function(mtx : matrix) : int; cdecl;
  t_matrix_copy = function(mtx : matrix) : matrix; cdecl;
  t_matrix_load_image = function(fname : pchar) : matrix; cdecl;
  t_matrix_save_image = function(mtx : matrix; fname : pchar) : int; cdecl;
  t_matrix_get_value = function(mtx : matrix; row : unsigned; column : unsigned; channel : unsigned) : int; cdecl;
  t_matrix_set_value = function(mtx : matrix; row : unsigned; column : unsigned; channel : unsigned; value : p_void) : int; cdecl;
  t_matrix_height = function(mtx : matrix; value : p_unsigned) : int; cdecl;
  t_matrix_width = function(mtx : matrix; value : p_unsigned) : int; cdecl;
  t_matrix_number_of_channels = function(mtx : matrix; value : p_unsigned) : int; cdecl;
  t_matrix_element_type = function(mtx : matrix; value : p_int) : int; cdecl;
  t_matrix_pointer_to_data = function(mtx : matrix; value : pp_void) : int; cdecl;
  t_matrix_pointer_to_row = function(mtx : matrix; row : unsigned; value : pp_void) : int; cdecl;

var

  image_create : t_image_create;
  image_delete : t_image_delete;
  image_copy : t_image_copy;
  matrix_to_image : t_matrix_to_image;
  matrix_create : t_matrix_create;
  matrix_delete : t_matrix_delete;
  matrix_copy : t_matrix_copy;
  matrix_load_image : t_matrix_load_image;
  matrix_save_image : t_matrix_save_image;
  matrix_get_value : t_matrix_get_value;
  matrix_set_value : t_matrix_set_value;
  matrix_height : t_matrix_height;
  matrix_width : t_matrix_width;
  matrix_number_of_channels : t_matrix_number_of_channels;
  matrix_element_type : t_matrix_element_type;
  matrix_pointer_to_data : t_matrix_pointer_to_data;
  matrix_pointer_to_row : t_matrix_pointer_to_row;

procedure image_to_TBitmap(img : image; var bmp : TBitmap);
function TBitmap_to_image(bmp : TBitmap) : image;

implementation

procedure image_to_TBitmap(img : image; var bmp : TBitmap);
var

    height, width : unsigned;
    v : dword;
    ptr : p_void;
    mtx : p_matrix;

begin

    // TODO single channel

    height := img^.height;
		width := img^.width;
    mtx := img^.mat;

		bmp.Height := height;
		bmp.Width := width;
    bmp.PixelFormat := pf24bit;
    width := width * 3;

    for v := 0 to height - 1 do
    begin

      matrix_pointer_to_row(mtx, v, @ ptr);
      CopyMemory(bmp.ScanLine[v], ptr, width);

    end;

end;
    
function TBitmap_to_image(bmp : TBitmap) : image;
var

    height, width : unsigned;
    img : image;
		v : dword;
    ptr : p_void;
    mtx : matrix;

begin

    // TODO single channel

    height := bmp.Height;
    width := bmp.Width;

    img := image_create(height, width, 3);
    mtx := img^.mat;
    width := width * 3;

    for v := 0 to height - 1 do
    begin

      matrix_pointer_to_row(mtx, v, @ ptr);
      CopyMemory(ptr, bmp.ScanLine[v], width);

    end;

    TBitmap_to_image := img;

end;

end.
