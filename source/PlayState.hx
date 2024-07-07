package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxDirection;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import sys.io.File;

class PlayState extends FlxState
{
	private var player:Player;
	private var playerStartPosition:FlxPoint = new FlxPoint(0, 0);
	private var visionMax:Int = 6;

	//groups wallbounds
	private var tileMapGroup:FlxGroup;
	private var enemyGroup:FlxGroup;
	private var itemGroup:FlxGroup;
	// particle
	private var particleGroup:FlxGroup;

	//params
	// private var currentHeight:Int = (32 * 16);
	private var tileSize:Int = 16;
	private var roomAmount:Int = 5;
	// timer
	private var restartTimer:FlxTimer;
	private var isGameOver:Bool = false;
	private var isTimerStart:Bool = false;

    override public function create():Void
    {
        super.create();

		// // background test
		// var tempBack1:FlxBackdrop = new FlxBackdrop();
		// tempBack1.loadGraphic("assets/images/back1.png");
		// tempBack1.scrollFactor.set(0, 0.08);
		// tempBack1.alpha = 0.5;
		// add(tempBack1);

		// var tempBack2:FlxBackdrop = new FlxBackdrop();
		// tempBack2.loadGraphic("assets/images/back2.png");
		// tempBack2.scrollFactor.set(0, 0.2);
		// tempBack2.alpha = 0.7;
		// add(tempBack2);

		FlxG.autoPause = false;
		FlxG.mouse.visible = false;

		//init groups
		tileMapGroup = new FlxGroup();
		add(tileMapGroup);
		enemyGroup = new FlxGroup();
		add(enemyGroup);
		itemGroup = new FlxGroup();
		add(itemGroup);
		particleGroup = new FlxGroup();
		add(particleGroup);

		//Формирование одного этажа
		creatingMap(1);
		// creatLevel(roomAmount);

		// Создаем игрока
		player = new Player(playerStartPosition.x, playerStartPosition.y);
        add(player);

		//доп условия сцены
		// FlxG.camera.setScrollBoundsRect(32, 0, 288, 1000);
		// FlxG.camera.setScrollBounds(32, 288, null, null);
		FlxG.camera.follow(player);
		// FlxG.camera.focusOn(player.getMidpoint());

		// FlxG.camera.setPosition(50, 50);
		// trace(FlxG.camera.x, FlxG.camera.y);
		restartTimer = new FlxTimer();
    }

	override public function update(elapsed:Float):Void
		{
		// Обработка коллизий игрока и стен
		FlxG.collide(player, tileMapGroup, onCollideFunction);
		// Обработка коллизий игрока и мобов
		FlxG.overlap(player, enemyGroup, onCollidePlayerEnemy);
		// Обработка коллизий мобов и стен
		FlxG.collide(enemyGroup, tileMapGroup);
		// Обработка коллайдов игрока и объектов
		FlxG.collide(player, itemGroup, onCollidePlayerItems);
		// Обработка коллайдов объектов и стен
		FlxG.collide(itemGroup, tileMapGroup, onCollideItemsWall);
		// Обработка коллайдов объектов и стен
		FlxG.collide(itemGroup, itemGroup);
		// Обработка оверлапов крови и стен
		FlxG.collide(particleGroup, tileMapGroup, onOverlapParticleWall);

			// FlxG.collide(player, tileMapGroup, function(player:FlxObject, tilemap:FlxObject):Void {
			// 	// if (player.touching == FlxObject.LEFT || player.touching == FlxObject.RIGHT)
			// 	if (player.touching == FlxDirectionFlags.LEFT || player.touching == FlxDirectionFlags.RIGHT)
			// 	{
			// 		(cast player:Player).onWallCollision();
			// 	}
			// });

		// обновление области коллизий по положению игрока
		FlxG.worldBounds.setPosition(player.x - 320, player.y - 240);
		FlxG.worldBounds.setSize(640, 480);
		// FlxG.worldBounds.setSize(320, 240);

		// обновление области видимости игрока
		visionRegionUpdate();

			super.update(elapsed);
		}

		//ON UPDATE FUNCTIONS
	private function onCollideFunction(player:FlxObject, sprGroup:FlxObject):Void
		{
		// if (player.touching == FlxDirectionFlags.LEFT || player.touching == FlxDirectionFlags.RIGHT)
		// {
		// 	(cast player:Player).onWallCollision();
		// }
		if (Std.isOfType(sprGroup, Tile))
		{
			var _tile:Tile = cast(sprGroup, Tile);
			if (_tile.getType() == 2 && cast(player, Player).isWantFall)
			{
				player.y += 8;
			}
			else if ((_tile.getType()) >= 4 && (_tile.getType()) <= 7)
			{
				// получение урона при коллизии с тайлом кольями
				// trace("получение урона при коллизии с тайлом кольями");
				// FlxG.camera.shake(0.05, 0.5);
				var _pl:Player = cast(player, Player);
				_pl.onTrapCollision();

				if (_pl.healthPoint <= 0)
				{
					creatBlood(_pl.x + _pl.width / 2, _pl.y + _pl.height / 2);
					_pl.kill();
					isGameOver = true;
					gameOver();
				}
				else if (_pl.touching == FlxDirectionFlags.UP)
				{
					_pl.velocity.y += 300;
				}
				else if (_pl.touching == FlxDirectionFlags.RIGHT)
				{
					_pl.velocity.x -= 300;
				}
				else if (_pl.touching == FlxDirectionFlags.DOWN)
				{
					_pl.velocity.y -= 300;
				}
				else if (_pl.touching == FlxDirectionFlags.LEFT)
				{
					_pl.velocity.x += 300;
				}
			}
			else if ((_tile.getType()) == 8)
			{
				_tile.wasTouched = true;
			}
			}
		}

	private function onCollidePlayerEnemy(player:FlxObject, sprGroup:FlxObject):Void
	{
		// if (player.touching == FlxDirectionFlags.DOWN)
		// {
		// 	(cast sprGroup : FlxObject).kill();
		// 	creatBlood(sprGroup.x + sprGroup.width / 2, sprGroup.y + sprGroup.height / 2);
		// 	player.velocity.y -= 400;
		// 	// player.acceleration.y = -1000;
		// }
		// test for overlap method
		if (player.y < sprGroup.y)
		{
			(cast sprGroup : FlxObject).kill();
			creatBlood(sprGroup.x + sprGroup.width / 2, sprGroup.y + sprGroup.height / 2);
			if (player.velocity.y > 0)
			{
				player.velocity.y = -300;
			}
			else
			{
				player.velocity.y -= 300;
				// player.acceleration.y = -1000;
			}
		}
	}

	private function onCollidePlayerItems(player:FlxObject, sprGroup:FlxObject)
	{
		// some logic
	}

	private function onCollideItemsWall(itemsObj:FlxObject, sprGroup:FlxObject)
	{
		// some logic
	}

	private function onOverlapParticleWall(particle:FlxObject, sprGroup:FlxObject):Void
	{

		particle.velocity.set(0, 0);
		particle.acceleration.set(0, 0);
		// cast(particle, Particle).isSpot = true;
		// particle.angularAcceleration = 0;

	}

	private function visionRegionUpdate()
	{
		// visionMax 6 default
		// 	private var tileMapGroup:FlxGroup;
		// private var enemyGroup:FlxGroup;
		// private var particleGroup:FlxGroup;

		// hide wall
		for (everyTile in tileMapGroup)
		{
			if (FlxMath.distanceBetween(player, cast(everyTile, FlxSprite)) < tileSize * visionMax)
			{
				everyTile.visible = true;
			}
			else
			{
				everyTile.visible = false;
			}
		}
		// hide enemys
		for (everyEnemy in enemyGroup)
		{
			if (FlxMath.distanceBetween(player, cast(everyEnemy, FlxSprite)) < tileSize * visionMax)
			{
				everyEnemy.visible = true;
			}
			else
			{
				everyEnemy.visible = false;
			}
		}
	}

	// прочее
	private function gameOver():Void
	{
		if (isGameOver && !isTimerStart)
		{
			trace("game over");
			isTimerStart = true;
			isGameOver = false;
			var wasted:FlxSprite = new FlxSprite(0);
			wasted.x += FlxG.camera.scroll.x;
			wasted.y += FlxG.camera.scroll.y;
			wasted.loadGraphic("assets/images/wasted.png", false, 320, 240, true);
			add(wasted);
			restartTimer.start(3, function(timer:FlxTimer)
			{
				FlxG.switchState(new PlayState());
			});
		}
	}
		
	// other functions
	// Генерация партиклов крови
	private function creatBlood(xPos:Float = 0, yPos:Float = 0):Void
	{
		for (i in 0...20)
		{
			var tempBlood:Particle = new Particle(0, 0);
			tempBlood.setPosition(xPos, yPos);
			tempBlood.velocity.set(FlxG.random.int(-100, 100) * 10, FlxG.random.int(-100, 100) * 10) * 5;
			// tempBlood.angularAcceleration = FlxG.random.int(-30, 30);
			particleGroup.add(tempBlood);
		}
	}

	// Генерация одного этажа
	private function creatingMap(_which:Int = 1):Void
	{
			
			// новый вариант
			// Загрузка данных CSV в строковую переменную
		// var csvData:String = File.getContent("assets/data/room-004.csv");
		// var csvData:String = File.getContent("assets/data/room-004.csv");
		// var dataMapString:String = "assets/data/" + _which + ".csv";
		var dataMapString:String = "assets/data/map1.csv";
		var csvData:String = File.getContent(dataMapString);
			// Функция для преобразования CSV данных в двумерный массив
			var rows:Array<String> = csvData.split("\n");
			var result:Array<Array<Int>> = [];
			
			for (row in rows) {
				if (row != "") { // Игнорируем пустые строки
					var values:Array<String> = row.split(",");
					var intValues:Array<Int> = [];
					for (value in values) {
						intValues.push(Std.parseInt(value));
					}
					result.push(intValues);
				}
			}

			// trace(result);

			for (i in 0...result.length)
				{
					for (j in 0...result[i].length)
					{
						switch result[i][j] {
							case 0:
								//nothing;
							case 1:
						// wall
								var tempTile:Tile = new Tile(0,0);
								tempTile.x = j * 16;
						tempTile.y = i * 16;
								tempTile.immovable = true;
								tempTile.allowCollisions = FlxDirectionFlags.ANY;
								tempTile.setType(1);
								tileMapGroup.add(tempTile);
							case 2:
						// platform
								var tempTile:Tile = new Tile(0,0);
								tempTile.x = j * 16;
						tempTile.y = i * 16;
								tempTile.immovable = true;
								tempTile.allowCollisions = FlxDirectionFlags.UP;
								tempTile.setType(2);
								tileMapGroup.add(tempTile);
							case 3:
						// enemy
						var tempEnemy:Enemy = new Enemy(0, 0);
						tempEnemy.x = j * 16;
						tempEnemy.y = i * 16;
						tempEnemy.immovable = true;
						enemyGroup.add(tempEnemy);
					case 4:
						var tempTile:Tile = new Tile(0, 0);
						tempTile.x = j * 16;
						tempTile.y = i * 16;
						tempTile.immovable = true;
						tempTile.allowCollisions = FlxDirectionFlags.ANY;
						tempTile.setType(4);
						tileMapGroup.add(tempTile);
					case 5:
						var tempTile:Tile = new Tile(0, 0);
						tempTile.x = j * 16;
						tempTile.y = i * 16;
						tempTile.immovable = true;
						tempTile.allowCollisions = FlxDirectionFlags.ANY;
						tempTile.setType(5);
						tileMapGroup.add(tempTile);
					case 6:
						var tempTile:Tile = new Tile(0, 0);
						tempTile.x = j * 16;
						tempTile.y = i * 16;
						tempTile.immovable = true;
						tempTile.allowCollisions = FlxDirectionFlags.ANY;
						tempTile.setType(6);
						tileMapGroup.add(tempTile);
					case 7:
						var tempTile:Tile = new Tile(0, 0);
						tempTile.x = j * 16;
						tempTile.y = i * 16;
						tempTile.immovable = true;
						tempTile.allowCollisions = FlxDirectionFlags.ANY;
						tempTile.setType(7);
						tileMapGroup.add(tempTile);
					case 8:
						// temporary platform
						var tempTile:Tile = new Tile(0, 0);
						tempTile.x = j * 16;
						tempTile.y = i * 16;
						tempTile.immovable = true;
						tempTile.allowCollisions = FlxDirectionFlags.UP;
						tempTile.setType(8);
						tileMapGroup.add(tempTile);
					case 11:
						// objects
						var tempObj:ObjectItem = new ObjectItem(0, 0);
						tempObj.x = j * 16;
						tempObj.y = i * 16;
						tempObj.allowCollisions = FlxDirectionFlags.ANY;
						itemGroup.add(tempObj);
					case 14:
						// player start position
						trace("player start position:", playerStartPosition);
						playerStartPosition.set(j * tileSize, i * tileSize);
						}
					
				}
			}

		// currentHeight -= tileSize * 32;
		}
}
