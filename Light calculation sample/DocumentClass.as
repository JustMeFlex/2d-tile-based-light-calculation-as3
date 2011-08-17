package 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;

	public class DocumentClass extends flash.display.MovieClip
	{
		//These are variables used by the program to store some things
		//Don't touch them
		public var level:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
		public var lightTables:Vector.<LightTable> = new Vector.<LightTable>();
		public var globalLightTable:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		public var mousedown:Boolean = false;
		public var mouseSquare:Point;
		public var _background:Sprite = new Sprite();
		public var overlay:Sprite = new Sprite();
		
		//You may change the values of these to variables to achieve different results. Be aware: this is pretty slow so you are likely to crash flash if you set them too demanding
		//In your game it might be better to have individual lightpowers and maxalphas for each size.
		//Power is how far the light spreads
		//maxalpha is how much alpha the the darkness can have
		//My plan would be to have an overlay like this on your normal map
		public var lightPower:int = 10;
		public var tilesize:int = 20;
		public var maxAlpha:Number = 0.8;

		//These won't ever change so I calculate them once and save them
		//Do not touch
		public var ratio:Number = 1 / tilesize;
		public var stepValueAlpha = maxAlpha / lightPower;

		public function makeBackGround()
		{
			for (var i:int = 0; i < level.length; i++)
			{
				for (var j:int = 0; j < level[i].length; j++)
				{
					var rock:Rock = new Rock();
					rock.x = i * tilesize;
					rock.y = j * tilesize;
					rock.width = tilesize;
					rock.height = tilesize;
					_background.addChild(rock);
				}
			}
		}
		
		public function DocumentClass():void
		{
			//I'm sorry it isn't properly commented, I didn't have time
			addChild(_background);
			addChild(overlay);
			intializeLevel(level);
			calculateGlobalLightTable3();
			drawLevel(level);
			makeBackGround();

			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}

		//Event handlers
		public function handleKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == 32)
			{
				intializeLevel(level);
				drawLevel(level);
			}
		}

		public function handleMouseDown(e:MouseEvent):void
		{
			this.mousedown = true;
			mouseSquare = getSquare(mouseX,mouseY,level);
			handleMouseMove(null);
		}

		public function handleMouseMove(e:MouseEvent):void
		{
			if (this.mousedown)
			{
				var mouseSquare = getSquare(mouseX,mouseY,level);
				
				var i:int = 0;
				for each (var lightTable:LightTable in lightTables)
				{
					i++;
					if (lightTable.sourceLoc.x > mouseSquare.x - lightPower)
					{
						if (lightTable.sourceLoc.x < mouseSquare.x + lightPower)
						{
							if (lightTable.sourceLoc.y > mouseSquare.y - lightPower)
							{
								if (lightTable.sourceLoc.y < mouseSquare.y + lightPower)
								{
									if (lightTable.sourceLoc.x == mouseSquare.x && lightTable.sourceLoc.y == mouseSquare.y)
									{
										var cornerA:Point = getSquare(mouseX,mouseY,level);
										var cornerB:Point;
										
										lightTables.splice(i - 1, 1);
										calculateGlobalLightTable1(mouseSquare.x - lightPower, mouseSquare.y - lightPower, mouseSquare.x + lightPower, mouseSquare.y + lightPower);
									}
									else
									{
										calculateLightValueTable(lightTable.table, lightTable.sourceLoc, false);
										calculateGlobalLightTable1(mouseSquare.x - lightPower, mouseSquare.y - lightPower, mouseSquare.x + lightPower, mouseSquare.y + lightPower);
									}
								}
							}
						}
					}
					
				}
				
				drawLevel(level);
				level[mouseSquare.x][mouseSquare.y] = 1;
				drawLevel(level);
			}
		}

		public function handleMouseUp(e:MouseEvent):void
		{
			var newMouseSquare:Point = getSquare(mouseX,mouseY,level);
			if (mouseSquare.equals(newMouseSquare))
			{
				level[mouseSquare.x][mouseSquare.y] = 2;
				var table = new LightTable(new Point(mouseSquare.x,mouseSquare.y),level,maxAlpha);
				lightTables.push(table);

				calculateLightValueTable(table.table, table.sourceLoc);
				drawLevel(level);
			}

			this.mousedown = false;
		}

		//The function for drawing the level
		//You probably use library objects so you won't need this
		public function drawLevel(level:Vector.<Vector.<int>>):void
		{
			overlay.graphics.clear();
			//graphics.lineStyle(1);

			for (var i:int = 0; i < level.length; i++)
			{
				for (var j:int = 0; j < level[i].length; j++)
				{
					if (level[i][j] == 1)
					{
						overlay.graphics.beginFill(0x009900);
					}
					else
					{
						overlay.graphics.beginFill(0x000000, globalLightTable[i][j]);
					}

					overlay.graphics.drawRect(i * tilesize, j * tilesize, tilesize, tilesize);
					overlay.graphics.endFill();
				}
			}
		}

		//A function for getting which square a stage coordinate is in
		public function getSquare(x, y, level):Point
		{
			return new Point(Math.round((x + tilesize * .5) * ratio) - 1, Math.round((y + tilesize * .5) * ratio) - 1);
		}

		public function fillVectorNumber(vector:Vector.<Vector.<Number>>, value:Number, width:int, height:int)
		{
			for (var i:int = 0; i < width; i++)
			{
				vector[i] = new Vector.<Number>();
				for (var j:int = 0; j < height; j++)
				{
					vector[i][j] = value;
				}
			}
		}
		
		public function fillVectorInt(vector:Vector.<Vector.<int>>, value:int, width:int, height:int)
		{
			for (var i:int = 0; i < width; i++)
			{
				vector[i] = new Vector.<int>();
				for (var j:int = 0; j < height; j++)
				{
					vector[i][j] = value;
				}
			}
		}
		
		//Reset the level
		public function intializeLevel(level:Vector.<Vector.<int>>):void
		{
			for (var i:int = 0; i < stage.stageWidth * ratio; i++)
			{
				level[i] = new Vector.<int>();
				for (var j:int = 0; j < stage.stageHeight * ratio; j++)
				{
					if (i == 0 || j == 0 || i >= stage.stageWidth * ratio - 1 || j >= stage.stageHeight * ratio - 1)
					{
						level[i][j] = 1;
					}
					else
					{
						level[i][j] = 0;
					}
				}
			}
		}

		//Calculate the light values
		//This is a full check that calculates light values for all light sources
		//You might want to split it up to only affect lightsources actually affected by the thing happended
		public function calculateLightValueTable(table:Vector.<Vector.<Number>>, lightSource:Point, calcGlobal:Boolean = true):void
		{
			//I know I keep a lot of data here, but that is just to save on the cpu
			//Most of the data will be garbage collected as soon as it's done calculating (Atleast I hope too)
			//but it will be using a lot of ram
			var checkedTiles:Vector.<Point> = new Vector.<Point>();
			var tilesToCheck:Vector.<Point> = new Vector.<Point>();
			var stepValues:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			
			
			fillVectorInt(stepValues, -1, level.length, level[0].length);
			fillVectorNumber(table, maxAlpha, level.length, level[0].length);
			
			tilesToCheck[0] = lightSource;
			stepValues[lightSource.x][lightSource.y] = 0;

			while (tilesToCheck.length > 0)
			{
				var currentTile:Point = tilesToCheck.pop();
				var currentStepValue:int = stepValues[currentTile.x][currentTile.y];
				
				checkedTiles.push(currentTile);

				if (currentStepValue < lightPower && level[currentTile.x][currentTile.y] != 1)
				{
					stepValues[currentTile.x][currentTile.y] = currentStepValue;
					if (currentTile.x > 0)
					{
						if (currentStepValue + 1 < stepValues[currentTile.x - 1][currentTile.y] || stepValues[currentTile.x - 1][currentTile.y] < 0)
						{
							tilesToCheck.push(new Point(currentTile.x - 1, currentTile.y));
							stepValues[currentTile.x - 1][currentTile.y] = currentStepValue + 1;
						}
					}
					if (currentTile.x < level.length)
					{
						if (currentStepValue + 1 < stepValues[currentTile.x + 1][currentTile.y] || stepValues[currentTile.x + 1][currentTile.y] < 0)
						{
							tilesToCheck.push(new Point(currentTile.x + 1, currentTile.y));
							stepValues[currentTile.x + 1][currentTile.y] = currentStepValue + 1;
						}
					}

					if (currentTile.y > 0)
					{
						if (currentStepValue + 1 < stepValues[currentTile.x][currentTile.y - 1] || stepValues[currentTile.x][currentTile.y - 1] < 0)
						{
							tilesToCheck.push(new Point(currentTile.x, currentTile.y - 1));
							stepValues[currentTile.x][currentTile.y - 1] = currentStepValue + 1;
						}
					}
					if (currentTile.y < level[currentTile.x].length)
					{
						if (currentStepValue + 1 < stepValues[currentTile.x][currentTile.y + 1] || stepValues[currentTile.x][currentTile.y + 1] < 0)
						{
							tilesToCheck.push(new Point(currentTile.x, currentTile.y + 1));
							stepValues[currentTile.x][currentTile.y + 1] = currentStepValue + 1;
						}
					}
				}

				for each (var tile:Point in checkedTiles)
				{
					if (stepValues[tile.x][tile.y] * stepValueAlpha < table[tile.x][tile.y])
					{
						table[tile.x][tile.y] = stepValues[tile.x][tile.y] * stepValueAlpha;
					}
				}
				
				if (calcGlobal)
				{
					calculateGlobalLightTable2(checkedTiles);
				}
			}

			function tileStep(x, y):int
			{
				return stepValues[x][y];

				return lightPower + 1;
			}
		}

		function calculateGlobalLightTable1(x, y, width, height):void
		{
			if (x < 0) x = 0;
			if (y < 0) y = 0;
			
			for (var i:int = x; i < level.length && i < width; i++)
			{
				for (var j:int = y; j < level[i].length && j < height; j++)
				{
					globalLightTable[i][j] = maxAlpha;
					for each (var table in lightTables)
					{
						if (table.table[i][j] < globalLightTable[i][j])
						{
							globalLightTable[i][j] = table.table[i][j];
						}
					}
				}
			}
		}
		
		function calculateGlobalLightTable2(points:Vector.<Point> = null):void
		{
			for each (var updatedTile:Point in points)
			{
				globalLightTable[updatedTile.x][updatedTile.y] = maxAlpha;
				for each (var table:LightTable in lightTables)
				{
					if (table.table[updatedTile.x][updatedTile.y] < globalLightTable[updatedTile.x][updatedTile.y])
					{
						globalLightTable[updatedTile.x][updatedTile.y] = table.table[updatedTile.x][updatedTile.y];
					}
				}
			}
		}
		
		function calculateGlobalLightTable3():void
		{
			for (var i:int = 0; i < level.length; i++)
			{
				globalLightTable[i] = new Vector.<Number>();
				for (var j:int = 0; j < level[i].length; j++)
				{
					globalLightTable[i][j] = maxAlpha;
					for each (var table in lightTables)
					{
						if (table.table[i][j] < globalLightTable[i][j])
						{
							globalLightTable[i][j] = table.table[i][j];
						}
					}
				}
			}
		}
	}
}