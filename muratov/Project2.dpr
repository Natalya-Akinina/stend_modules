library Project2;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  math,
  stend_interface in 'stend_interface.pas';

{$R *.res}

{$LIBPREFIX '../build/lib'}

type
ptbitmap=^Tbitmap;
TRGBTripleArray = array[0..10000] of TRGBTriple;
PRGBTripleArray = ^TRGBTripleArray;
param_gisto=record
kf_kontrast:byte;
pr_kontrast:byte;
kontrast:boolean;
kf_fragment:byte;
pr_fragment:byte;
pr_fragment2:byte;
fragment:boolean;
end;

var

 src, dst : image;

 bmp:TBitmap;  //рабочий кадр
 bmp1:TBitmap; //кадр подложка
 gisto_init:param_gisto;
 p_bmp:ptbitmap;

 gisto:array[0..255]of integer;
 rm:integer;
 lgk,lgk2,rgk,lgp:integer;
 mask:array[0..4,0..4]of single;
 minzone,minzone2:integer;
// edit42:integer;
 flag_autocontrast:byte;

procedure Push_bmp(source:pTbitmap;types:boolean);cdecl;
begin
bmp:=source^;
p_bmp:=@bmp;
//bmp.Canvas.Pen.Color:=clred;
//bmp.Canvas.MoveTo(10,10);
//bmp.Canvas.lineTo(100,100);

if types then
bmp1.assign(bmp);
end;

procedure Pop_bmp(dest:pTbitmap;num:integer);cdecl;
begin
if num = 1 then
dest^.assign(bmp);
end;


procedure gistogramm_nm(x_start,y_start,x_stop,y_stop:integer;gmode:byte;types,pf:boolean);  //types отсечение краев
var
 i,j:integer;
 c,c1:integer;
 dest:PRGBTripleArray;
kf:single;
kfgisto:integer;
//srs:integer;
p2:integer;

begin
//pf:=pf and false;//рисовать гистограмму
p2:=gisto_init.pr_fragment2;//regul//strtoint(form1.edit42.text);
if  gmode=1 then
begin
kfgisto:=gisto_init.pr_kontrast; //strtoint(form1.edit22.text);
kf:=gisto_init.kf_kontrast; //strtofloat(form1.edit21.text);
end
else
begin
kfgisto:=gisto_init.pr_fragment; //strtoint(form1.edit24.text);
kf:=gisto_init.kf_fragment //strtofloat(form1.edit23.text);
end;

 for i:=0 to 255 do
 gisto[i]:=0;

//srs:=0;
//только для серого
for j:=y_start to y_stop do
 begin
   dest:=p_bmp^.ScanLine[j];
      for i:=x_start to x_stop do
      begin
        inc(gisto[dest[i].rgbtGreen{,1}]);
//        srs:=srs+dest[i].rgbtGreen;
      end;
end;
//srs:=round(srs/((y_stop-y_start)*(x_stop-x_start)));
//находим максимум для масштабирования
rm:=0;
if types then
begin
for i:=1 to 254 do
  if gisto[i]>rm then rm:=gisto[i];
end
else
for i:=0 to 255 do
  if gisto[i]>rm then rm:=gisto[i];


if gisto_init.kontrast then //form1.checkbox18.checked then
begin
//левая граница по порогу
for i:=1 to 253 do
begin
c:=gisto[i];
c:=round(kf*(100/rm)*c);if c>255 then c:=255;
c1:=gisto[i+1{,1}];
c1:=round(kf*(100/rm)*c1);if c1>255 then c1:=255;
if (c>kfgisto)and(c1>kfgisto) then break;
end;
lgk:=i;

for i:=1 to 253 do
begin
c:=gisto[i{,1}];
c:=round(kf*(100/rm)*c);if c>255 then c:=255;
c1:=gisto[i+1{,1}];
c1:=round(kf*(100/rm)*c1);if c1>255 then c1:=255;
if (c>kfgisto*p2)and(c1>kfgisto*p2) then break;
end;
//k:=i;
lgk2:=i;

//правая граница по порогу
for i:=254 downto lgk+1 do
begin
c:=gisto[i{,1}];
c:=round(kf*(100/rm)*c);if c>255 then c:=255;
c1:=gisto[i-1{,1}];
c1:=round(kf*(100/rm)*c1);if c1>255 then c1:=255;
if (c>kfgisto)and(c1>kfgisto) then break;
end;
rgk:=i;
end;
{}
end;

procedure avtolevel_mn(x_start,y_start,x_stop,y_stop:integer{;mflag:boolean});
var
 i,j:integer;
 c:integer;
 dest:PRGBTripleArray;
 kr:single;
 dbv:integer;
begin
if ((rgk-lgk)<=minzone2) then
begin
dbv:=round((minzone-(rgk-lgk))/2);
lgk:=lgk-dbv;
rgk:=rgk+dbv;
if lgk<0 then begin lgk:=0; rgk:=minzone;end;
if rgk>255 then begin lgk:=255-minzone; rgk:=255;end;
if flag_autocontrast=1 then begin lgk:=0; rgk:=255; end;
end;

if (rgk-lgk)=0 then
 kr:=255
else
kr:=255/(rgk-lgk);

for j:=y_start to y_stop do
 begin
   dest:=p_bmp^.ScanLine[j];
   for i:=x_start to x_stop do
    begin
      c:=round((dest[i].rgbtRed-lgk)*kr);
      if c>255 then c:=255;
      if c<0 then c:=0;

     dest[i].rgbtBlue:=c;
     dest[i].rgbtGreen:=c;
     dest[i].rgbtRed:=c;
    end;
end;
end;


procedure del_up();
var k,l,c,c1{,c2}:integer;
 dest:PRGBTripleArray;
// flag_2p:boolean;
begin
//flag_2p:=form1.checkbox49.checked;
c1:=lgk;
//c2:=lgk2;
      for l:=0 to  p_bmp^.Height-1 do
      begin
       dest:=p_bmp^.ScanLine[l];
        for k:=0 to p_bmp^.Width-1  do
        begin
     c:=dest[k].rgbtGreen;
{
if flag_2p then
begin
if is_tonell(l1,l2,k,l) then c3:=c2 else c3:=c1;
        if c>=c3 then
        begin
             dest[k].rgbtBlue:=255;
             dest[k].rgbtGreen:=255;
             dest[k].rgbtRed:=255;
        end
        else
        begin
             dest[k].rgbtBlue:=c;
             dest[k].rgbtRed:=c;
        end;

end
else
}       if c>=c1 then
        begin
             dest[k].rgbtBlue:=255;
             dest[k].rgbtGreen:=255;
             dest[k].rgbtRed:=255;
        end
        else
        begin
             dest[k].rgbtBlue:=c;
             dest[k].rgbtRed:=c;
        end;
       end;
      end;//end for i
end;


procedure del_ramka();
var
 i,j:integer;
 dest:PRGBTripleArray;
begin
//bmp.PixelFormat:=pf24bit;

dest:=p_bmp^.ScanLine[0];
   for i:=0 to p_bmp^.Width-1 do
    begin
     dest[i].rgbtBlue:=255;
     dest[i].rgbtGreen:=255;
     dest[i].rgbtRed:=255;
    end;

dest:=p_bmp^.ScanLine[p_bmp^.Height-1];
   for i:=0 to p_bmp^.Width-1 do
    begin
     dest[i].rgbtBlue:=255;
     dest[i].rgbtGreen:=255;
     dest[i].rgbtRed:=255;
    end;

for j:=1 to p_bmp^.Height-2 do
 begin
   dest:=p_bmp^.ScanLine[j];
     dest[0].rgbtBlue:=255;
     dest[0].rgbtGreen:=255;
     dest[0].rgbtRed:=255;
     dest[p_bmp^.Width-1].rgbtBlue:=255;
     dest[p_bmp^.Width-1].rgbtGreen:=255;
     dest[p_bmp^.Width-1].rgbtRed:=255;
  end;
end;



type
p_element=^element;
element=record
i:integer;
j:integer;
node:integer;
next:p_element;
end;

type fn_num=record
fn:integer;
p_el_start:p_element;
p_el_end:p_element;
end;

type pl=record
num:integer;//номер в цепочке
xn,{yn,}xk{,yk}:integer;//координаты площадки
//fn:integer;//номер в фигуре
p:^fn_num;
//!!!spix:byte;
//previos:integer;
end;

var
line_pl: array [1..2000,1..2000] of pl; //площадки
vector_pl: array [1..2000] of integer;//колво площадок в строке
new_pl: array [1..20000,1..2] of integer;//1ст - номер 2 ст площадь
fig_num:integer;

Glob_lines:integer;
Glob_figrs:integer;

numerator:array of fn_num;
el:array of element;



procedure frag_lines(id_s:integer);
var fig_nline,i,j:integer;
fnh:boolean;//флаг начала плошадки
flag:boolean;//флаг найденной площадки
dest:PRGBTripleArray;
flag_ok:boolean;
begin
if id_s=0 then del_ramka();
fig_num:=1;
for i:=1 to 2000 do
vector_pl[i]:=0;

for j:=1 to p_bmp^.Height do
begin

 fnh:=true; //ищем начало - t конец - f
 flag:=false; //ищем конец линии - t
 fig_nline:=1;
 //сканируем линию
 dest:=p_bmp^.ScanLine[j-1];
 for i:=0 to p_bmp^.Width-1 do  //исправил индекс -1
 begin
  //всеравно в каком канале работать в случае серого изображения
  //будем работать в красном

  if id_s=0 then
  flag_ok:=(fnh and (dest[i].rgbtRed<>255))
  else
  flag_ok:=(fnh and (dest[i].rgbtRed=255)and (dest[i].rgbtGreen<>255));

  if flag_ok then
  begin
   //найдено начало пл.
   line_pl[fig_nline,j].xn:=i;
   fnh:=not fnh;
   flag:=true;
  end
  else
  begin
  if id_s=0 then
  flag_ok:=(not(fnh))and(dest[i].rgbtRed=255)
  else
   flag_ok:=(not(fnh))and(((dest[i].rgbtRed<>255)and(dest[i].rgbtGreen<>255))or(dest[i].rgbtGreen=255));
  if flag_ok then
  begin
   //найден конец пл.
   //закрываем площадку
   line_pl[fig_nline,j].xk:=i-1;
   fnh:=not fnh;
   flag:=false;
   line_pl[fig_nline,j].num:=fig_num;
   inc(fig_num);
   vector_pl[j]:=fig_nline;
   inc(fig_nline);
  end;
  end;
 end; //end for i
   if flag and (not fnh) then
   begin
    //закрываем площадку
    line_pl[fig_nline,j].xk:=i-1;
    line_pl[fig_nline,j].num:=fig_num;
    vector_pl[j]:=fig_nline;
    inc(fig_num);
   end;
end;//end for j

Glob_lines:=fig_num-1;

setlength(numerator,Glob_lines+1);
setlength(el,Glob_lines+1);

for j:=1 to p_bmp^.Height do //инициализация элементов
begin
 for i:=1 to vector_pl[j] do
 begin
  line_pl[i,j].p:=@numerator[line_pl[i,j].num];
  (line_pl[i,j].p)^.fn:=line_pl[i,j].num;
  (line_pl[i,j].p)^.p_el_start:=@el[line_pl[i,j].num];
  (line_pl[i,j].p)^.p_el_end:=@el[line_pl[i,j].num];
  ((line_pl[i,j].p)^.p_el_start)^.i:=i;
  ((line_pl[i,j].p)^.p_el_start)^.j:=j;
  ((line_pl[i,j].p)^.p_el_start)^.node:=0;//0 - нет узла
  ((line_pl[i,j].p)^.p_el_start)^.next:=nil;
 end;
end;

end;

procedure union_lines();
var i,j,k,r{,n,p,m}:integer;
//nn,nk,kl:integer;
new_numcount:integer;
flag:boolean;
p:{e,pl}fn_num;
cou:integer;
begin
r:=1{strtoint(edit18.text)}; //razriv+1;//удаление пикселей друг от друга

for j:= 1 to p_bmp^.Height-1 do
begin
 for i:=1 to vector_pl[j] do
 begin
//вводим диапазон разброса для склеивания
   for k:=1 to vector_pl[j+1] do
     begin
     if (line_pl[i,j].xn <= line_pl[k,j+1].xk+r) and (line_pl[k,j+1].xn-r <= line_pl[i,j].xk) then
     begin {1+}
      //плошадки принадлежат одной фигуре, объединяем!
      if   (line_pl[i,j].p)^.fn <  (line_pl[k,j+1].p)^.fn then
      begin  {2+}
        //уровень вниз

      p:=line_pl[k,j+1].p^;//номер этого объекта будет заменен сохраним указатель

      //в конце цепочки ставим метку узла при условии что
      //цепоча не элемент
      if p.p_el_start<>p.p_el_end then
      begin
      ((line_pl[i,j].p)^.p_el_end)^.node:=1;
      (p.p_el_start)^.node:=1;
      end;
      //присоединяем к концу цепочки новую цепочку линеек
      ((line_pl[i,j].p)^.p_el_end)^.next:=p.p_el_start;
      //обновляем указатель конца цепочки
      (line_pl[i,j].p)^.p_el_end:=p.p_el_end;
      //ставим признак неиспользуемого элемента дескриптора
      (line_pl[k,j+1].p)^.p_el_end:=nil;
      //перенумеровываем старую цепочку
      flag:=true;
      while flag do
      begin
       line_pl[(p.p_el_start)^.i,(p.p_el_start)^.j].p:=line_pl[i,j].p;
       if (p.p_el_start)^.next=nil then flag:=false
         else
          p.p_el_start:=(p.p_el_start)^.next;
      end;

      end {2-}
        else
      if   (line_pl[i,j].p)^.fn > (line_pl[k,j+1].p)^.fn then
      begin {3+}
      //уровень вверх
       p:=line_pl[i,j].p^;//номер этого объекта будет заменен сохраним указатель

      //в конце цепочки ставим метку узла при условии что
      //цепоча не элемент
      if p.p_el_start<>p.p_el_end then
      begin
      ((line_pl[k,j+1].p)^.p_el_end)^.node:=1;
      (p.p_el_start)^.node:=1;
      end;

      //присоединяем к концу цепочки новую цепочку линеек
      ((line_pl[k,j+1].p)^.p_el_end)^.next:=p.p_el_start;
      (line_pl[k,j+1].p)^.p_el_end:=p.p_el_end;
       //ставим признак неиспользуемого элемента дескриптора
      (line_pl[i,j].p)^.p_el_end:=nil;
      //перенумеровываем старую цепочку
      flag:=true;
      while flag do
      begin
       line_pl[(p.p_el_start)^.i,(p.p_el_start)^.j].p:=line_pl[k,j+1].p;
       if (p.p_el_start)^.next=nil then flag:=false
         else
          p.p_el_start:=(p.p_el_start)^.next;
      end;

      end; //уровень вверх {3-}
     end;//объединение {1-}
     end;//end k и kl
 end;//end i
end;//end for j

new_numcount:=0;
//for i:=1 to 20000 do new_pl[i,1]:=0;

for i:=1 to Glob_lines do
begin
if numerator[i].p_el_end<>nil then
  begin
   inc(new_numcount);
   new_pl[new_numcount,1]:=i; //новая нумерация по порядку
   new_pl[new_numcount,2]:=0;

   flag:=true;
   p:=numerator[i];
     while flag do
      begin
       new_pl[new_numcount,2]:=new_pl[new_numcount,2]+1+line_pl[(p.p_el_start)^.i,(p.p_el_start)^.j].xk-line_pl[(p.p_el_start)^.i,(p.p_el_start)^.j].xn;
       if (p.p_el_start)^.next=nil then flag:=false
         else
          p.p_el_start:=(p.p_el_start)^.next;
      end;
  end;

end;
Glob_figrs:=new_numcount;
end;

var    r_gisto:array [0..359]of integer;


procedure delta_pix;
var i,j:integer;
mins,maxs:integer;
k,k1:single;
begin
mins:=360000;
maxs:=0;
for i:=0 to Glob_figrs-1 do
begin
if new_pl[i,2]<mins then mins:=new_pl[i,2];
if new_pl[i,2]>maxs then maxs:=new_pl[i,2];
end;
k:=(maxs-mins)/360;

for i:=0 to 355 do
 r_gisto[i]:=0;

for i:=0 to Glob_figrs-1 do
inc(r_gisto[round(new_pl[i,2]/k)]);

maxs:=0;
for i:=0 to 355 do
if r_gisto[i]>maxs then maxs:=r_gisto[i];

if maxs=0 then k1:=200 else
k1:=200/maxs;
for i:=0 to 355 do
begin
if round(r_gisto[i]*k1)>3 then mins:=i;
end;

lgp:=round(k*(mins+1));
//form1.edit3.Text:=inttostr(lgp);
if lgp> 100 then lgp:=100;

end;

procedure del_small_frag(bin:byte{id_s:integer});
var i,j,delta,k,c:integer;
 dest:PRGBTripleArray;
 p:fn_num;
 flag:boolean;
begin
delta:=lgp;

for i:=1 to Glob_figrs do
begin
   p:=numerator[new_pl[i,1]];
   flag:=true;
     while flag do
      begin
        dest:=p_bmp^.ScanLine[(p.p_el_start)^.j-1];

         for k:=line_pl[(p.p_el_start)^.i,(p.p_el_start)^.j].xn to line_pl[(p.p_el_start)^.i,(p.p_el_start)^.j].xk do
         begin

         if new_pl[i,2]<delta then
         begin
         dest[k].rgbtBlue:=255;
         dest[k].rgbtGreen:=255;
         dest[k].rgbtRed:=255;
         end
         else
         if bin=1 then
         begin
         dest[k].rgbtBlue:=0;
         dest[k].rgbtGreen:=0;
         dest[k].rgbtRed:=0;
         end;

       end;
       if (p.p_el_start)^.next=nil then flag:=false
         else
          p.p_el_start:=(p.p_el_start)^.next;
      end;
end;
end;


Procedure bluer3(x_start,y_start,x_stop,y_stop:integer);
var i,j:integer;
 c:single;
 dest,dest_m,dest_p:PRGBTripleArray;
begin
dest:=p_bmp^.ScanLine[0];
dest_p:=p_bmp^.ScanLine[1];
 for j:=y_start to y_stop do
 begin
 dest_m:=dest;
 dest:=dest_p;
 dest_p:=p_bmp^.ScanLine[j+1];
  for i:=x_start to x_stop do
    begin
     c:=0;
//i-1,j-1
  c:=c+dest_m[i-1].rgbtGreen;
//i-1,j
  c:=c+dest[i-1].rgbtGreen;
//i-1,j+1
  c:=c+dest_p[i-1].rgbtGreen;
//i,j-1
  c:=c+dest_m[i].rgbtGreen;
//i,j
  c:=c+dest[i].rgbtGreen;
//i,j+1
  c:=c+dest_p[i].rgbtGreen;
//i+1,j-1
  c:=c+dest_m[i+1].rgbtGreen;
//i+1,j
  c:=c+dest[i+1].rgbtGreen;
//i+1,j+1
  c:=c+dest_p[i+1].rgbtGreen;
c:=c/9;
       if c>255 then c:=255;
       dest[i].rgbtRed:=round(c);
    end;
  end;//end for j
end;

Procedure bluer5();
var
 i,j:integer;
 mask1:array[0..4,0..4]of single;
 c:single;
 dest_mm:PRGBTripleArray;
 dest:PRGBTripleArray;
 dest_m:PRGBTripleArray;
 dest_p:PRGBTripleArray;
 dest_pp:PRGBTripleArray;
begin
 mask1[0,0]:=0.003;mask1[0,1]:=0.013;mask1[0,2]:=0.022;mask1[0,3]:=0.013;mask1[0,4]:=0.003;
 mask1[1,0]:=0.013;mask1[1,1]:=0.059;mask1[1,2]:=0.097;mask1[1,3]:=0.059;mask1[1,4]:=0.013;
 mask1[2,0]:=0.022;mask1[2,1]:=0.097;mask1[2,2]:=0.159;mask1[2,3]:=0.097;mask1[2,4]:=0.022;
 mask1[3,0]:=0.013;mask1[3,1]:=0.059;mask1[3,2]:=0.097;mask1[3,3]:=0.059;mask1[3,4]:=0.013;
 mask1[4,0]:=0.003;mask1[4,1]:=0.013;mask1[4,2]:=0.022;mask1[4,3]:=0.013;mask1[4,4]:=0.003;

dest_m:=p_bmp^.ScanLine[0];
dest:=p_bmp^.ScanLine[1];
dest_p:=p_bmp^.ScanLine[2];
dest_pp:=p_bmp^.ScanLine[3];

 for j:=2 to p_bmp^.Height-3 do
 begin

 dest_mm:=dest_m;
 dest_m:=dest;
 dest:=dest_p;
 dest_p:=dest_pp;

 dest_pp:=p_bmp^.ScanLine[j+2];

 for i:=2 to p_bmp^.Width-3 do
    begin
     c:=0;

//c:=c+dest_mm[i-2].rgbtRed*mask1[0,0];
c:=c+dest_mm[i-2].rgbtGreen*mask1[0,0];
c:=c+dest_mm[i-1].rgbtGreen*mask1[0,1];
c:=c+dest_mm[i].rgbtGreen*mask1[0,2];
c:=c+dest_mm[i+1].rgbtGreen*mask1[0,3];
c:=c+dest_mm[i+2].rgbtGreen*mask1[0,4];

c:=c+dest_m[i-2].rgbtGreen*mask1[1,0];
c:=c+dest_m[i-1].rgbtGreen*mask1[1,1];
c:=c+dest_m[i].rgbtGreen*mask1[1,2];
c:=c+dest_m[i+1].rgbtGreen*mask1[1,3];
c:=c+dest_m[i+2].rgbtGreen*mask1[1,4];

c:=c+dest[i-2].rgbtGreen*mask1[2,0];
c:=c+dest[i-1].rgbtGreen*mask1[2,1];
c:=c+dest[i].rgbtGreen*mask1[2,2];
c:=c+dest[i+1].rgbtGreen*mask1[2,3];
c:=c+dest[i+2].rgbtGreen*mask1[2,4];

c:=c+dest_p[i-2].rgbtGreen*mask1[3,0];
c:=c+dest_p[i-1].rgbtGreen*mask1[3,1];
c:=c+dest_p[i].rgbtGreen*mask1[3,2];
c:=c+dest_p[i+1].rgbtGreen*mask1[3,3];
c:=c+dest_p[i+2].rgbtGreen*mask1[3,4];

c:=c+dest_pp[i-2].rgbtGreen*mask1[4,0];
c:=c+dest_pp[i-1].rgbtGreen*mask1[4,1];
c:=c+dest_pp[i].rgbtGreen*mask1[4,2];
c:=c+dest_pp[i+1].rgbtGreen*mask1[4,3];
c:=c+dest_pp[i+2].rgbtGreen*mask1[4,4];

       if c>255 then c:=255;
//       dest1[i].rgbtBlue:=round(c);
//       dest1[i].rgbtGreen:=round(c);
       dest[i].rgbtRed:=round(c);
    end;
  end;//end for j
end;

procedure GrayScale();cdecl;
var
 i,j:integer;
 c :integer;
 dest:PRGBTripleArray;
begin
for j:=0 to p_bmp^.Height-1 do
 begin
   dest:=p_bmp^.ScanLine[j];
   for i:=0 to p_bmp^.Width-1 do
    begin
//     0.299 R + 0.587 G + 0.114 B
     c:=round(0.144*dest[i].rgbtBlue+0.587*dest[i].rgbtGreen+0.299*dest[i].rgbtRed);

     if c>255 then c:=255;
     dest[i].rgbtBlue:=c;
     dest[i].rgbtGreen:=c;
     dest[i].rgbtRed:=c;
   end;
 end;
end;

Procedure kirsh_fast();
var
 i,j:integer;
 dest:PRGBTripleArray;
 dest_m:PRGBTripleArray;
 dest_p:PRGBTripleArray;
 kirsh:array [1..8] of integer;
begin
dest:=p_bmp^.ScanLine[0];
dest_p:=p_bmp^.ScanLine[1];

 for j:=1 to p_bmp^.Height-2 do
 begin
 dest_m:=dest;
 dest:=dest_p;
 dest_p:=p_bmp^.ScanLine[j+1];

 for i:=1 to p_bmp^.Width-2 do
    begin
  kirsh[1]:=5*(dest_m[i-1].rgbtRed+dest_m[i].rgbtRed+dest_m[i+1].rgbtRed);
  kirsh[1]:=abs(kirsh[1]-3*(dest[i-1].rgbtRed+dest[i+1].rgbtRed+dest_p[i-1].rgbtRed+dest_p[i].rgbtRed+dest_p[i+1].rgbtRed));

  kirsh[2]:=5*(dest_m[i].rgbtRed+dest_m[i+1].rgbtRed+dest[i+1].rgbtRed);
  kirsh[2]:=abs(kirsh[2]-3*(dest_m[i-1].rgbtRed+dest[i-1].rgbtRed+dest_p[i-1].rgbtRed+dest_p[i].rgbtRed+dest_p[i+1].rgbtRed));

  kirsh[3]:=5*(dest_m[i+1].rgbtRed+dest[i+1].rgbtRed+dest_p[i+1].rgbtRed);
  kirsh[3]:=abs(kirsh[3]-3*(dest_m[i-1].rgbtRed+dest_m[i].rgbtRed+dest[i-1].rgbtRed+dest_p[i-1].rgbtRed+dest_p[i].rgbtRed));

  kirsh[4]:=5*(dest[i+1].rgbtRed+dest_p[i+1].rgbtRed+dest_p[i].rgbtRed);
  kirsh[4]:=abs(kirsh[4]-3*(dest_m[i-1].rgbtRed+dest_m[i].rgbtRed+dest_m[i+1].rgbtRed+dest[i-1].rgbtRed+dest_p[i-1].rgbtRed));

  kirsh[5]:=5*(dest_p[i-1].rgbtRed+dest_p[i].rgbtRed+dest_p[i+1].rgbtRed);
  kirsh[5]:=abs(kirsh[5]-3*(dest_m[i-1].rgbtRed+dest_m[i].rgbtRed+dest_m[i+1].rgbtRed+dest[i-1].rgbtRed+dest[i+1].rgbtRed));

  kirsh[6]:=5*(dest_p[i-1].rgbtRed+dest_p[i].rgbtRed+dest[i-1].rgbtRed);
  kirsh[6]:=abs(kirsh[6]-3*(dest_m[i-1].rgbtRed+dest_m[i].rgbtRed+dest_m[i+1].rgbtRed+dest[i+1].rgbtRed+dest_p[i+1].rgbtRed));

  kirsh[7]:=5*(dest_p[i-1].rgbtRed+dest[i-1].rgbtRed+dest_m[i-1].rgbtRed);
  kirsh[7]:=abs(kirsh[7]-3*(dest_m[i].rgbtRed+dest_m[i+1].rgbtRed+dest[i+1].rgbtRed+dest_p[i].rgbtRed+dest_p[i+1].rgbtRed));

  kirsh[8]:=5*(dest[i-1].rgbtRed+dest_m[i-1].rgbtRed+dest_m[i].rgbtRed);
  kirsh[8]:=abs(kirsh[8]-3*(dest_m[i+1].rgbtRed+dest[i+1].rgbtRed+dest_p[i-1].rgbtRed+dest_p[i].rgbtRed+dest_p[i+1].rgbtRed));

 kirsh[1]:=max(kirsh[1],kirsh[2]);
 kirsh[1]:=max(kirsh[1],kirsh[3]);
 kirsh[1]:=max(kirsh[1],kirsh[4]);
 kirsh[1]:=max(kirsh[1],kirsh[5]);
 kirsh[1]:=max(kirsh[1],kirsh[6]);
 kirsh[1]:=max(kirsh[1],kirsh[7]);
 kirsh[1]:=max(kirsh[1],kirsh[8]);
 kirsh[1]:=round(kirsh[1]);
 if kirsh[1]>255 then kirsh[1]:=255;
 if kirsh[1]<0 then kirsh[1]:=0;

 dest[i].rgbtGreen:=255-kirsh[1];
    end;
  end;//end for j
end;

Procedure Convolve_5();
var
 i,j:integer;
 c,c2:single;
 dest_mm:PRGBTripleArray;
 dest:PRGBTripleArray;
 dest_m:PRGBTripleArray;
 dest_p:PRGBTripleArray;
 dest_pp:PRGBTripleArray;
begin

 mask[0,0]:=1;mask[0,1]:=2;mask[0,2]:=0;mask[0,3]:=-2;mask[0,4]:=-1;
 mask[1,0]:=2;mask[1,1]:=3;mask[1,2]:=0;mask[1,3]:=-3;mask[1,4]:=-2;
 mask[2,0]:=3;mask[2,1]:=4;mask[2,2]:=0;mask[2,3]:=-4;mask[2,4]:=-3;
 mask[3,0]:=2;mask[3,1]:=3;mask[3,2]:=0;mask[3,3]:=-3;mask[3,4]:=-2;
 mask[4,0]:=1;mask[4,1]:=2;mask[4,2]:=0;mask[4,3]:=-2;mask[4,4]:=-1;

dest_m:=p_bmp^.ScanLine[0];
dest:=p_bmp^.ScanLine[1];
dest_p:=p_bmp^.ScanLine[2];
dest_pp:=p_bmp^.ScanLine[3];

 for j:=2 to p_bmp^.Height-3 do
 begin

 dest_mm:=dest_m;
 dest_m:=dest;
 dest:=dest_p;
 dest_p:=dest_pp;

 dest_pp:=p_bmp^.ScanLine[j+2];

 for i:=2 to p_bmp^.Width-3 do
    begin
     c:=0;
     c2:=0;

c:=c+dest_mm[i-2].rgbtRed*mask[0,0];
c2:=c2+dest_mm[i-2].rgbtRed*mask[0,0];
c:=c+dest_mm[i-1].rgbtRed*mask[0,1];
c2:=c2+dest_mm[i-1].rgbtRed*mask[1,0];
c:=c+dest_mm[i].rgbtRed*mask[0,2];
c2:=c2+dest_mm[i].rgbtRed*mask[2,0];
c:=c+dest_mm[i+1].rgbtRed*mask[0,3];
c2:=c2+dest_mm[i+1].rgbtRed*mask[3,0];
c:=c+dest_mm[i+2].rgbtRed*mask[0,4];
c2:=c2+dest_mm[i+2].rgbtRed*mask[4,0];

c:=c+dest_m[i-2].rgbtRed*mask[1,0];
c2:=c2+dest_m[i-2].rgbtRed*mask[0,1];
c:=c+dest_m[i-1].rgbtRed*mask[1,1];
c2:=c2+dest_m[i-1].rgbtRed*mask[1,1];
c:=c+dest_m[i].rgbtRed*mask[1,2];
c2:=c2+dest_m[i].rgbtRed*mask[2,1];
c:=c+dest_m[i+1].rgbtRed*mask[1,3];
c2:=c2+dest_m[i+1].rgbtRed*mask[3,1];
c:=c+dest_m[i+2].rgbtRed*mask[1,4];
c2:=c2+dest_m[i+2].rgbtRed*mask[4,1];

c:=c+dest[i-2].rgbtRed*mask[2,0];
c2:=c2+dest[i-2].rgbtRed*mask[0,2];
c:=c+dest[i-1].rgbtRed*mask[2,1];
c2:=c2+dest[i-1].rgbtRed*mask[1,2];
c:=c+dest[i].rgbtRed*mask[2,2];
c2:=c2+dest[i].rgbtRed*mask[2,2];
c:=c+dest[i+1].rgbtRed*mask[2,3];
c2:=c2+dest[i+1].rgbtRed*mask[3,2];
c:=c+dest[i+2].rgbtRed*mask[2,4];
c2:=c2+dest[i+2].rgbtRed*mask[4,2];

c:=c+dest_p[i-2].rgbtRed*mask[3,0];
c2:=c2+dest_p[i-2].rgbtRed*mask[0,3];
c:=c+dest_p[i-1].rgbtRed*mask[3,1];
c2:=c2+dest_p[i-1].rgbtRed*mask[1,3];
c:=c+dest_p[i].rgbtRed*mask[3,2];
c2:=c2+dest_p[i].rgbtRed*mask[2,3];
c:=c+dest_p[i+1].rgbtRed*mask[3,3];
c2:=c2+dest_p[i+1].rgbtRed*mask[3,3];
c:=c+dest_p[i+2].rgbtRed*mask[3,4];
c2:=c2+dest_p[i+2].rgbtRed*mask[4,3];

c:=c+dest_pp[i-2].rgbtRed*mask[4,0];
c2:=c2+dest_pp[i-2].rgbtRed*mask[0,4];
c:=c+dest_pp[i-1].rgbtRed*mask[4,1];
c2:=c2+dest_pp[i-1].rgbtRed*mask[1,4];
c:=c+dest_pp[i].rgbtRed*mask[4,2];
c2:=c2+dest_pp[i].rgbtRed*mask[2,4];
c:=c+dest_pp[i+1].rgbtRed*mask[4,3];
c2:=c2+dest_pp[i+1].rgbtRed*mask[3,4];
c:=c+dest_pp[i+2].rgbtRed*mask[4,4];
c2:=c2+dest_pp[i+2].rgbtRed*mask[4,4];

       c:=sqrt(sqr(c)+sqr(c2));
       if c>255 then c:=255;
       dest[i].rgbtGreen:=round(255-c);
    end;
  end;//end for j
end;


Procedure Convolve_fast();
var
 i,j{,k,l}:integer;
 c,c2:single;
 dest:PRGBTripleArray;
 dest_m:PRGBTripleArray;
 dest_p:PRGBTripleArray;
begin
dest:=p_bmp^.ScanLine[0];
dest_p:=p_bmp^.ScanLine[1];
 for j:=1 to p_bmp^.Height-2 do
 begin
 dest_m:=dest;
 dest:=dest_p;
 dest_p:=p_bmp^.ScanLine[j+1];
 for i:=1 to p_bmp^.Width-2 do
    begin
     c:=0;
     c2:=0;
//i-1,j-1
  c:=c+dest_m[i-1].rgbtRed*mask[0,0];
  c2:=c2+dest_m[i-1].rgbtRed*mask[0,0];
//i-1,j
  c:=c+dest[i-1].rgbtRed*mask[0,1];
  c2:=c2+dest[i-1].rgbtRed*mask[1,0];
//i-1,j+1
  c:=c+dest_p[i-1].rgbtRed*mask[0,2];
  c2:=c2+dest_p[i-1].rgbtRed*mask[2,0];

//i,j-1
  c:=c+dest_m[i].rgbtRed*mask[1,0];
  c2:=c2+dest_m[i].rgbtRed*mask[0,1];
//i,j
  c:=c+dest[i].rgbtRed*mask[1,1];
  c2:=c2+dest[i].rgbtRed*mask[1,1];
//i,j+1
  c:=c+dest_p[i].rgbtRed*mask[1,2];
  c2:=c2+dest_p[i].rgbtRed*mask[2,1];

//i+1,j-1
  c:=c+dest_m[i+1].rgbtRed*mask[2,0];
  c2:=c2+dest_m[i+1].rgbtRed*mask[0,2];
//i+1,j
  c:=c+dest[i+1].rgbtRed*mask[2,1];
  c2:=c2+dest[i+1].rgbtRed*mask[1,2];
//i+1,j+1
  c:=c+dest_p[i+1].rgbtRed*mask[2,2];
  c2:=c2+dest_p[i+1].rgbtRed*mask[2,2];

       c:=sqrt(sqr(c)+sqr(c2));
       if c>255 then c:=255;
       dest[i].rgbtGreen:=round(255-c);
    end;
  end;//end for j
end;

Procedure Convolve_4();
var
 i,j:integer;
 c,c2,c3,c4:single;
 dest:PRGBTripleArray;
 dest_m:PRGBTripleArray;
 dest_p:PRGBTripleArray;
begin
dest:=p_bmp^.ScanLine[0];
dest_p:=p_bmp^.ScanLine[1];

//flag:=form1.checkbox12.checked;
 for j:=1 to p_bmp^.Height-2 do
 begin
 dest_m:=dest;
 dest:=dest_p;
 dest_p:=p_bmp^.ScanLine[j+1];

 for i:=1 to p_bmp^.Width-2 do
    begin
     c:=0;
     c2:=0;
     c3:=0;
     c4:=0;

//i-1,j-1
  c:=c+dest_m[i-1].rgbtRed*mask[0,0];
  c2:=c2-dest_m[i-1].rgbtRed*mask[0,0];
  c3:=c3-dest_m[i-1].rgbtRed*mask[1,0];
  c4:=c4+dest_m[i-1].rgbtRed*mask[0,1];
//i,j-1
  c:=c+dest_m[i].rgbtRed*mask[1,0];
  c2:=c2-dest_m[i].rgbtRed*mask[0,1];
  c3:=c3-dest_m[i].rgbtRed*mask[2,0];
  c4:=c4+dest_m[i].rgbtRed*mask[0,0];
//i+1,j-1
  c:=c+dest_m[i+1].rgbtRed*mask[2,0];
  c2:=c2-dest_m[i+1].rgbtRed*mask[0,2];
  c3:=c3-dest_m[i+1].rgbtRed*mask[2,1];
  c4:=c4+dest_m[i+1].rgbtRed*mask[1,0];

//i-1,j
  c:=c+dest[i-1].rgbtRed*mask[0,1];
  c2:=c2-dest[i-1].rgbtRed*mask[1,0];
  c3:=c3-dest[i-1].rgbtRed*mask[0,0];
  c4:=c4+dest[i-1].rgbtRed*mask[0,2];
//i,j
  c:=c+dest[i].rgbtRed*mask[1,1];
  c2:=c2-dest[i].rgbtRed*mask[1,1];
  c3:=c3-dest[i].rgbtRed*mask[1,1];
  c4:=c4+dest[i].rgbtRed*mask[1,1];
//i+1,j
  c:=c+dest[i+1].rgbtRed*mask[2,1];
  c2:=c2-dest[i+1].rgbtRed*mask[1,2];
  c3:=c3-dest[i+1].rgbtRed*mask[2,2];
  c4:=c4+dest[i+1].rgbtRed*mask[2,0];

//i-1,j+1
  c:=c+dest_p[i-1].rgbtRed*mask[0,2];
  c2:=c2-dest_p[i-1].rgbtRed*mask[2,0];
  c3:=c3-dest_p[i-1].rgbtRed*mask[0,1];
  c4:=c4+dest_p[i-1].rgbtRed*mask[1,2];
//i,j+1
  c:=c+dest_p[i].rgbtRed*mask[1,2];
  c2:=c2-dest_p[i].rgbtRed*mask[2,1];
  c3:=c3-dest_p[i].rgbtRed*mask[0,2];
  c4:=c4+dest_p[i].rgbtRed*mask[2,2];
//i+1,j+1
  c:=c+dest_p[i+1].rgbtRed*mask[2,2];
  c2:=c2-dest_p[i+1].rgbtRed*mask[2,2];
  c3:=c3-dest_p[i+1].rgbtRed*mask[1,2];
  c4:=c4+dest_p[i+1].rgbtRed*mask[2,1];


       c:=sqrt(sqr(c)+sqr(c2)+sqr(c3)+sqr(c4));
       if c>255 then c:=255;
       dest[i].rgbtGreen:=round(255-c);
    end;
  end;//end for j
end;


procedure set_convolve(num:byte);cdecl;
begin
if (num=1) or(num=3) then
begin
 mask[0,0]:=-1;mask[1,0]:=mask[0,0];mask[2,0]:=mask[0,0];
 mask[0,1]:=0;mask[1,1]:=mask[0,1];mask[2,1]:=mask[0,1];
 mask[0,2]:=1;mask[1,2]:=mask[0,2];mask[2,2]:=mask[0,2];
end;
if (num=0) or(num=2) then
begin
 mask[0,0]:=-1;mask[1,0]:=-2;mask[2,0]:=mask[0,0];
 mask[0,1]:=0;mask[1,1]:=mask[0,1];mask[2,1]:=mask[0,1];
 mask[0,2]:=1;mask[1,2]:=2;mask[2,2]:=mask[0,2];
end;
end;



procedure Edge(convolve,bin:byte);cdecl;
begin
bluer5();

  if convolve=0 then //0
  Convolve_4();
  if convolve=1 then //1
  Convolve_4();
  if convolve=2 then //2
  Convolve_fast();
  if convolve=3 then //3
  Convolve_fast();
  if convolve=4 then //4
  Convolve_5();
  if convolve=5 then //5
  kirsh_fast();
//  if form1.ComboBox2.ItemIndex=6 then //6
//  canny1();

gistogramm_nm(0,0,p_bmp^.Width-1,p_bmp^.Height-1,2,false,false);
del_up();
frag_lines(0);//Button12.OnClick(self);//get lines  {Фрагменты}
union_lines();//Button13.OnClick(self);//union lines
delta_pix();
del_small_frag(bin);//Button16.OnClick(self); //убрать мелкие детали
end;

function init(module_name : PChar; module_name_len : DWord; param_num : PDWord; return_value_num : PDWord) : int; cdecl;
begin

  strcopy(module_name, 'muratov');
  param_num^ := 1;
  return_value_num^ := 1;

  init := 0;

end;

function destroy : int; cdecl;
begin

  destroy := 0;

end;

function run : int; cdecl;
begin

  image_to_TBitmap(src, bmp);
//  Edge(5, 0);
  dst := TBitmap_to_image(bmp);

  run := 0;

end;

function get_name(is_param : boolean; ind : dword; name : pchar; name_len : dword) : int; cdecl;
begin

  if is_param then

    strcopy(name, 'Source image')

  else

    strcopy(name, 'Destination image');

  get_name := 0;

end;

function get_type(is_param : boolean; ind : dword; tp : pint) : int; cdecl;
begin

  tp^ := 5;
  get_type := 0;

end;

function get_value(is_param : boolean; ind : dword; value : p_void) : int; cdecl;
begin

  if is_param then

    p_image(value)^ := src

  else

    p_image(value)^ := dst;

  get_value := 0;

end;

function set_value(is_param : boolean; ind : dword; value : p_void) : int; cdecl;
begin

  if is_param then

    src := p_image(value)^

  else

    dst := p_image(value)^;

  set_value := 0;

end;

exports

image_create name 'image_create',
image_delete name 'image_delete',
image_copy name 'image_copy',
matrix_to_image name 'matrix_to_image',
matrix_create name 'matrix_create',
matrix_delete name 'matrix_delete',
matrix_copy name 'matrix_copy',
matrix_load_image name 'matrix_load_image',
matrix_save_image name 'matrix_save_image',
matrix_get_value name 'matrix_get_value',
matrix_set_value name 'matrix_set_value',
matrix_height name 'matrix_height',
matrix_width name 'matrix_width',
matrix_number_of_channels name 'matrix_number_of_channels',
matrix_element_type name 'matrix_element_type',
matrix_pointer_to_data name 'matrix_pointer_to_data',
matrix_pointer_to_row name 'matrix_pointer_to_row',

init Name 'init',
destroy Name 'destroy',
run Name 'run',
get_name Name 'get_name',
get_type Name 'get_type',
get_value Name 'get_value',
set_value Name 'set_value';

procedure FINIT(id:integer);
begin
if id=DLL_PROCESS_DETACH then
begin
bmp.Free;
bmp1.Free;
end;

end;

begin
DLLProc:=@FINIT;

bmp:=TBitmap.Create;
bmp.PixelFormat:=pf24bit;
bmp.Height:=600;
bmp.Width:=800;

bmp1:=TBitmap.Create;
bmp1.PixelFormat:=pf24bit;

gisto_init.kf_kontrast:=1;
gisto_init.pr_kontrast:=1;
gisto_init.kontrast:=true;
gisto_init.kf_fragment:=1;
gisto_init.pr_fragment:=1;
gisto_init.pr_fragment2:=5;
gisto_init.fragment:=true;

minzone:=51;//regul strtoint(form1.edit10.text);
minzone2:=10; //regul strtoint(form1.edit11.text);
flag_autocontrast:=0;

set_convolve(0);

end.

//procedure Push_bmp(source:pTbitmap;types:boolean);
//procedure gistogramm_nm(x_start,y_start,x_stop,y_stop:integer;gmode:byte;types,pf:boolean);  //types отсечение краев
//procedure avtolevel_mn(x_start,y_start,x_stop,y_stop:integer{;mflag:boolean});
//Procedure bluer3(x_start,y_start,x_stop,y_stop:integer);
//Procedure bluer5();
//Procedure Convolve_fast();
//Procedure Convolve_4();
//procedure GrayScale();
//procedure set_convolve(num:byte);
//procedure FINIT(id:integer);
