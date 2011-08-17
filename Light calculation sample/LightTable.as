package  {
	import flash.geom.Point;
	
	public class LightTable
	{
		public var sourceLoc:Point;
		public var table:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		public var level:Vector.<Vector.<int>>;
		
		public function LightTable(sourcelocation:Point, Level:Vector.<Vector.<int>>, maxAlpha:Number)
		{
			sourceLoc = sourcelocation;
			level = Level;
			resetTable(maxAlpha);
		}
		
		public function resetTable(maxAlpha:Number, startX:int = 0, startY:int = 0, width:int = -1, height:int =-1):void
		{
			if (width < 0)
			{
				width = level.length;
			}
			
			if (height < 0)
			{
				height = level[0].length;
			}
			
			for (var i = startX; i < level.length && i < width; i++)
			{
				table[i] = new Vector.<Number>();
				for (var j = startY; j < level.length && j < height; j++)
				{
					table[i][j] = maxAlpha;
				}
			}
		}
	}
}
