#property strict

enum ENUM_ALT_COLOR_MODE{
	NONE,
	ALT_ROW_WISE,
	ALT_COLUMN_WISE,
	VALUE_WISE,
	CUSTOM_WISE
};

class Table
{
	private:
		long 		_id;
		int 		_subwin, _x, _y, _xOffset, _yOffset, _w, _h, _cellW, _cellH, _cellSpace, _fontSize, _cols, _rows;
		string 		_name, _bgName, _fontName;
		bool 		_showBg, _showCellBg, _showCellAltBg, _autoWidth, _autoHeight;
		color 		_fontColor, _altFontColor, _panelBgColor, _bgColor, _altBgColor;
		int 		_GetChartWidth(){
						long result;
						if(!ChartGetInteger(_id, CHART_WIDTH_IN_PIXELS, _subwin, result)) 
							Print(__FUNCTION__," - Error in getting chart width! Error Code:", GetLastError());
						return (int)result;};
		int 		_GetChartHeight(){
						long result;
						if(!ChartGetInteger(_id, CHART_HEIGHT_IN_PIXELS, _subwin, result))
							Print(__FUNCTION__," - Error in getting chart height! Error Code:", GetLastError());
						return (int)result;};
		bool 		_SetFont(string name, string font){
						if(!ObjectSetString(_id, name, OBJPROP_FONT, font)){
							Print(__FUNCTION__, ", error code:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetFontSize(string name, int fontSize){
						if(!ObjectSetInteger(_id, name, OBJPROP_FONTSIZE, fontSize)){
							Print(__FUNCTION__, ", error code:", GetLastError());
							return false;
						}
						return true;};	
		bool 		_SetFontColor(string name,int fontColor){
						if(!ObjectSetInteger(_id, name, OBJPROP_COLOR, fontColor)){
							Print(__FUNCTION__, ", error code:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetBgColor(string name, int bgColor){
						if(!ObjectSetInteger(_id, name, OBJPROP_BGCOLOR, bgColor)){
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetX(string name, int x){
							if(!ObjectSetInteger(_id, name, OBJPROP_XDISTANCE, x)){
								Print(__FUNCTION__, ", error:", GetLastError());
								return false;
							}
							return true;};
		bool 		_SetY(string name, int y){
						if(!ObjectSetInteger(_id, name, OBJPROP_YDISTANCE, y)){
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetWidth(string name, int width){
						if(!ObjectSetInteger(_id, name, OBJPROP_XSIZE, width)){
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetHeight(string name, int height){
						if(!ObjectSetInteger(_id, name, OBJPROP_YSIZE, height)){
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetText(string name, string text){
						if(!ObjectSetString(_id, name, OBJPROP_TEXT, text)){
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true; };
		bool 		_SetLock(string name){
						if(!ObjectSetInteger(_id, name, OBJPROP_SELECTABLE, false)){
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true;};
		bool 		_SetHide(string name){
						if(!ObjectSetInteger(_id, name, OBJPROP_HIDDEN, true))
						{
							Print(__FUNCTION__, ", error:", GetLastError());
							return false;
						}
						return true;};
		bool 		_IsObjectExist(string name){
						if(ObjectFind(_id, name)>0) return true;
						return false; };
		void 		_ComputeCellWidth(string &cells[][]){
						if(_autoWidth){
							_ComputeDimension(cells);
							if(_cols>0 && _w>0)
								_cellW = _w/_cols;
							else
								Print(__FUNCTION__, ", Error. Empty table column. Cell width set to 0.");
						}};
		void		_ComputeCellHeight(string &cells[][]){
						if(_autoHeight){
							_ComputeDimension(cells);
							if(_rows > 0 && _h>0)
								_cellH = _h/_rows;
							else
								Print(__FUNCTION__, ", Error. Empty table row. Cell height set to 0.");
						}};
		void 		_ComputeDimension(string &cells[][]){
						_cols = ArrayRange(cells, 1);
						_rows = ArrayRange(cells, 0); };		
		int 		_GetX(int col){ return(_x+_xOffset+col*(_cellW+_cellSpace));};
		int 		_GetY(int row){	return(_y+_yOffset+row*(_cellH+_cellSpace));};
		color 		_GetColor(ENUM_ALT_COLOR_MODE clrMode, color clrNormal, color clrAlt, int r, int c, bool condition=false){
						color result = clrNormal;
						if(clrMode == NONE)
							return result;
						switch(clrMode)
						{
							case ALT_COLUMN_WISE:
								if(c%2==1) result = clrAlt;
								break;
							case ALT_ROW_WISE:
								if(r%2==1) result = clrAlt;
								break;
							case VALUE_WISE:
								if(condition) result = clrAlt;
								break;
							case CUSTOM_WISE:
								//you implementation goes here
								break;
						}
						return result; };
		ENUM_ALT_COLOR_MODE _fgAltClrMode, _bgAltClrMode;
		
	public:
		void		Table(long id, int subwin, string name);
		void 		Create(int x=0, int y=0, int w=0, int h=0, int xOffset=3, int yOffset=3, int cellWidth=0, int cellHeight=0, int cellSpace=2, int fontSize=8, string fontName="Terminal");
		void 		SetFontColors(color fontColor, color altFontColor);
		void 		SetBgColors(color bgColor, color cellBgColor);
		void 		SetAltFontColorMode(ENUM_ALT_COLOR_MODE altMode){
		}
		bool 		Show(string &cells[][]);
		void		~Table();
};	

bool Table::Show(string &cells[][]){
	_ComputeDimension(cells);
	_ComputeCellWidth(cells);
	_ComputeCellHeight(cells);
	for(int r=0; r<_rows; r++)
	{
		for(int c=0; c<_cols; c++)
		{
			string name = _name+StringConcatenate("r", r, "c", c);
			string cellBgName = name+"bg";
			color fontColor = _GetColor(_fgAltClrMode, _fontColor, _altFontColor, r, c, false);
			color bgColor = _GetColor(_bgAltClrMode, _bgColor, _altBgColor, r, c, false);
			int x = _GetX(c);
			int y = _GetY(r);
			if(!_IsObjectExist(name)){
				if(!ObjectCreate(_id, name, OBJ_LABEL, _subwin, 0, 0)){
					Print(__FUNCTION__, ", error in creating cell:", GetLastError());
					return false;
				}
				if(_showCellBg){
					if(!ObjectCreate(_id, cellBgName, OBJ_RECTANGLE_LABEL, _subwin, 0, 0)){
						Print(__FUNCTION__, ", error in creating background object: ", GetLastError());
						return false;
					}
				}
				if(!_SetHide(name)) return false;
				if(!_SetLock(name)) return false;
				if(!_SetFont(name, _fontName)) return false;
				if(!_SetFontSize(name, _fontSize)) return false;
				if(!_SetX(name, x)) return false;
				if(!_SetY(name, y)) return false;
			}
			if(!_SetFontColor(name, fontColor)) return false;
			if(!_SetText(name, cells[r][c])) return false;
		}
	}
	return true;
}
void Table::Create(int x=0, int y=0, int w=0, int h=0, int xOffset=3, int yOffset=3, int cellWidth=0, int cellHeight=0, int cellSpace=2, int fontSize=8, string fontName="Terminal"){
	_x = x;
	_y = y;
	_w = w;
	_h = h;
	_xOffset = xOffset;
	_yOffset = yOffset;
	_cellW = cellWidth;
	_cellH = cellHeight;
	_cellSpace = cellSpace;
	_fontSize = fontSize;
	_fontName = fontName;
	_cols = -1;
	_rows = -1;
	if(w==0){
		_autoWidth = true;
		_w = (int) ChartGetInteger(_id, CHART_WIDTH_IN_PIXELS, _subwin);
	}
	if(h==0){
		_autoHeight = true;
		_h = (int) ChartGetInteger(_id, CHART_HEIGHT_IN_PIXELS, _subwin);
	}}
void Table::Table(long id, int subwin, string name){
	_id = id;
	_subwin = subwin;
	_name = name;
	_fontColor = ChartGetInteger(_id, CHART_COLOR_FOREGROUND, _subwin);
	_altFontColor = _fontColor;
	_bgColor = ChartGetInteger(_id, CHART_COLOR_BACKGROUND, _subwin);
	_altBgColor = _bgColor;
}
void Table::~Table(){
	if(_subwin==0){
		int i = ObjectsTotal(_id, _subwin) - 1;
		while(i>=0){
			string name = ObjectName(i);
			if(StringFind(name, _name)>-1)
				ObjectDelete(name);
			i--;
		}
	}}
void Table::SetFontColors(color fontColor, color altFontColor = clrNONE){
	color chartBgColor = (color) ChartGetInteger(_id, CHART_COLOR_BACKGROUND, _subwin);
	if(fontColor == chartBgColor || fontColor == clrNONE){
		Print(__FUNCTION__, ", Error! Font color should not be the same as the background color. The font color will set to the foreground color of the chart.");
		_fontColor = (color) ChartGetInteger(_id, CHART_COLOR_FOREGROUND, _subwin);
	}
	_fontColor = fontColor;
	_altFontColor = altFontColor;
	if(altFontColor == clrNONE){
		Print(__FUNCTION__, ", Warning, altFontColor set to clrNONE! Now altFontColor set to fontColor.");
		_altFontColor = _fontColor;
	}}
