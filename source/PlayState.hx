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
import openfl.display.Sprite;
import sys.io.File;

class PlayState extends FlxState
{
	private var player:Player;
	private var playerStartPosition:FlxPoint;
	// область видимости игрока
	private var visionMax:Int = 6;

	// для видимости босса (он всегда один на уровне)
	private var boss:Boss;

	//groups wallbounds
	private var tileMapGroup:FlxGroup;
	private var enemyGroup:FlxGroup;
	private var bossGroup:FlxGroup;
	private var itemGroup:FlxGroup;
	// particle
	private var particleGroup:FlxGroup;

	// map building in Array of Integer
	private var mapTilesAndObjects:Array<Array<Int>>;

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
		// группа врагов
		enemyGroup = new FlxGroup();
		add(enemyGroup);
		itemGroup = new FlxGroup();
		add(itemGroup);
		particleGroup = new FlxGroup();
		add(particleGroup);

		// Загрузка уровня
		creatingMap(Reg.currentMap);
		// creatLevel(roomAmount);

		// Создаем игрока
		// если позиция не задана в файле Reg.hx, то берем из данных тайл карты
		playerStartPosition = Reg.playerLastPosition;
		player = new Player(playerStartPosition.x, playerStartPosition.y);
		player.velocity.y -= 10;
		trace("player created at position:", player.getPosition());
        add(player);

		// даем врагам ссылки на игрока
		setSourceToEnemys();

		//доп условия сцены
		// FlxG.camera.setScrollBoundsRect(32, 0, 288, 1000);
		// FlxG.camera.setScrollBounds(32, 288, null, null);
		FlxG.camera.follow(player);
		// FlxG.camera.focusOn(player.getMidpoint());

		// FlxG.camera.setPosition(50, 50);
		// trace(FlxG.camera.x, FlxG.camera.y);
		restartTimer = new FlxTimer();
		// обновление области коллизий
		// v0.2 изменение, поскольку враги вне области видимости игрока проваливались сквозь тайлы
		FlxG.worldBounds.setSize(1024, 1024);
    }

	override public function update(elapsed:Float):Void
		{
		// super.update(elapsed);
		// Обработка коллизий игрока и стен
		FlxG.collide(player, tileMapGroup, onCollideFunction);
		// Обработка коллизий игрока и мобов и босса
		// FlxG.overlap(player, enemyGroup, onCollidePlayerEnemy);
		FlxG.collide(player, enemyGroup, onCollidePlayerEnemy);
		FlxG.collide(player, boss, onCollidePlayerBoss);
		// Обработка оверлапа мили атаки игрока и врагов
		FlxG.overlap(player.meleeAttack, enemyGroup, onMeleeAttackOvelap);
		// Обработка оверлапа мили атаки и объектов
		FlxG.overlap(player.meleeAttack, itemGroup, onMeleeAttackItemOvelap);
		// Обработка коллайдов игрока и объектов
		// FlxG.collide(player, itemGroup, onCollidePlayerItems);
		FlxG.collide(player, itemGroup);

		// обработка коллизий стен и босса
		// FlxG.collide(boss, tileMapGroup, onColBossWalls);
		FlxG.collide(boss, tileMapGroup);
		FlxG.collide(boss, itemGroup);

		// Обработка коллизий мобов и стен
		FlxG.collide(enemyGroup, tileMapGroup, onColEnemyWalls);
		// ОБработка коллайдов врагов и объектов
		FlxG.collide(enemyGroup, itemGroup);

		// Обработка коллайдов объектов и стен
		// FlxG.collide(itemGroup, itemGroup);
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
		// v0,1
		// FlxG.worldBounds.setPosition(player.x - 320, player.y - 240);
		// FlxG.worldBounds.setSize(640, 480);
		// FlxG.worldBounds.setSize(320, 240);


		// обновление области видимости игрока
		visionRegionUpdate();
		// Проверяем живы ли враги по их ХП поинтам
		checkEnemyAlive();
		checkPlayerAlive();
		checkObjectsNearby();
		checkKeysAndDoors();
		// Контроль числа партиклов, чтобы комп не умер
		if (particleGroup.length > 100)
		{
			while (particleGroup.length > 100)
			{
				var tmp:FlxSprite = cast(particleGroup.getFirstExisting(), FlxSprite);
				if (tmp != null)
				{
					tmp.kill();
					particleGroup.remove(tmp, true);
				}
			}
		}
	

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

				// if (_pl.healthPoint <= 0)
				// {
				// 	creatBlood(_pl.x + _pl.width / 2, _pl.y + _pl.height / 2);
				// 	_pl.kill();
				// 	isGameOver = true;
				// 	gameOver();
				// }
				// else
				if (_pl.touching == FlxDirectionFlags.UP)
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

	// Collide function Enemys and Walls
	private function onColEnemyWalls(enemGroup:FlxObject, sprGroup:FlxObject):Void
	{
		var _tile:Tile = cast(sprGroup, Tile);
		if ((_tile.getType()) >= 4 && (_tile.getType()) <= 7)
		{
			// получение урона при коллизии с тайлом кольями
			// trace("получение урона при коллизии с тайлом кольями");
			// FlxG.camera.shake(0.05, 0.5);
			var _enemy:Enemy = cast(enemGroup, Enemy);
			_enemy.onTrapCollision();

			if (_enemy.touching == FlxDirectionFlags.UP)
			{
				_enemy.velocity.y += 300;
			}
			else if (_enemy.touching == FlxDirectionFlags.RIGHT)
			{
				_enemy.velocity.x -= 300;
			}
			else if (_enemy.touching == FlxDirectionFlags.DOWN)
			{
				_enemy.velocity.y -= 300;
			}
			else if (_enemy.touching == FlxDirectionFlags.LEFT)
			{
				_enemy.velocity.x += 300;
			}
		}
		else if ((_tile.getType()) == 8)
		{
			_tile.wasTouched = true;
		}
	}

	// Collide function Boss and Walls
	private function onColBossWalls(boss:Boss, sprGroup:FlxObject):Void
	{
		trace("BOSS");
		var _tile:Tile = cast(sprGroup, Tile);
		if ((_tile.getType()) >= 4 && (_tile.getType()) <= 7)
		{
			// получение урона при коллизии с тайлом кольями
			// trace("получение урона при коллизии с тайлом кольями");
			// FlxG.camera.shake(0.05, 0.5);

			boss.onTrapCollision();

			if (boss.touching == FlxDirectionFlags.UP)
			{
				boss.velocity.y += 300;
			}
			else if (boss.touching == FlxDirectionFlags.RIGHT)
			{
				boss.velocity.x -= 300;
			}
			else if (boss.touching == FlxDirectionFlags.DOWN)
			{
				boss.velocity.y -= 300;
			}
			else if (boss.touching == FlxDirectionFlags.LEFT)
			{
				boss.velocity.x += 300;
			}
		}
		else if ((_tile.getType()) == 8)
		{
			_tile.wasTouched = true;
		}
	}

	// перекрытия игрока и врагов
	private function onCollidePlayerEnemy(playerObj:FlxObject, sprGroup:FlxObject):Void
	{
		if (playerObj.y < sprGroup.y - 8)
		{
			if (playerObj.velocity.y > 0)
			{
				playerObj.velocity.y = -300;
			}
			else
			{
				playerObj.velocity.y -= 300;
				// player.acceleration.y = -1000;
			}
			// creatBlood(sprGroup.x + sprGroup.width / 2, sprGroup.y + sprGroup.height / 2);
			// (cast sprGroup : FlxObject).kill();
			cast(sprGroup, Enemy).onAttack(player.x, player.y, 2);
			// sprGroup.kill();
			// enemyGroup.remove(sprGroup, true);
		}
		else
		{
			if (cast(sprGroup, Enemy).canGetDamage)
			{
				cast(playerObj, Player).onEnemyHit();
			}
		}
	}

	// перекрытия игрока и босса
	private function onCollidePlayerBoss(playerObj:Player, bossObj:Boss):Void
	{
		if (playerObj.y < bossObj.y - 8)
		{
			if (playerObj.velocity.y > 0)
			{
				playerObj.velocity.y = -300;
			}
			else
			{
				playerObj.velocity.y -= 300;
				// player.acceleration.y = -1000;
			}
			// creatBlood(sprGroup.x + sprGroup.width / 2, sprGroup.y + sprGroup.height / 2);
			// (cast sprGroup : FlxObject).kill();
			bossObj.onAttack(player.x, player.y, 2);
			// sprGroup.kill();
			// enemyGroup.remove(sprGroup, true);
		}
		else
		{
			if (bossObj.canGetDamage)
			{
				playerObj.onEnemyHit();
			}
		}
	}

	// private function onCollidePlayerItems(player:FlxObject, sprGroup:FlxObject)
	// {
	// 	// some logic
	// }

	private function onOverlapParticleWall(particle:FlxObject, sprGroup:FlxObject):Void
	{

		particle.velocity.set(0, 0);
		particle.acceleration.set(0, 0);
		// cast(particle, Particle).isSpot = true;
		// particle.angularAcceleration = 0;

	}

	private function onMeleeAttackOvelap(attackObj:FlxObject, enemyObj:FlxObject)
	{
		if (attackObj.visible == true && cast(enemyObj, Enemy).canGetDamage)
		{
			cast(enemyObj, Enemy).onAttack(player.x, player.y, 1);
		}
	}

	private function onMeleeAttackItemOvelap(attackObj:FlxObject, itemObj:FlxObject)
	{
		if (cast(itemObj, ObjectItem).type == 0 && attackObj.visible)
		{
			cast(itemObj, ObjectItem).onAttack();
		}
		if (cast(itemObj, ObjectItem).alpha <= 0.5)
		{
			itemObj.kill();
			itemGroup.remove(itemObj, true);
		}
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
				// work with fake walls
				// 9 - fake wall
				if (cast(everyTile, Tile).type == 9)
				{
					if (FlxMath.distanceBetween(player, cast(everyTile, FlxSprite)) < tileSize)
					{
						cast(everyTile, Tile).alpha = 0.2;
					}
				}
			}
			else
			{
				everyTile.visible = false;
				// work with fake walls
				// 9 - fake wall
				if (cast(everyTile, Tile).type == 9)
				{
					cast(everyTile, Tile).alpha = 1;
				}
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
				if (cast(everyEnemy, Enemy).canHide)
				{
					// not hiding
					everyEnemy.visible = false;
				}
			}
		}
		// hide objects
		for (elementItem in itemGroup)
		{
			if (FlxMath.distanceBetween(player, cast(elementItem, FlxSprite)) < tileSize * visionMax)
			{
				elementItem.visible = true;
			}
			else
			{
				elementItem.visible = false;
			}
		}
	}

	private function checkEnemyAlive():Void
	{
		for (enem in enemyGroup)
		{
			var tempEnemySpr:Enemy = cast(enem, Enemy);
			if (!tempEnemySpr.isAlive)
			{
				if (tempEnemySpr.type != 4)
				{
					creatBlood(tempEnemySpr.x + tempEnemySpr.width / 2, tempEnemySpr.y + tempEnemySpr.height / 2);
				}
				
				tempEnemySpr.kill();
				enemyGroup.remove(enem, true);
			}
		}
	}
	private function checkPlayerAlive():Void
	{
		if (!player.isAlive)
		{
			if (!isGameOver)
			{
				creatBlood(player.x + player.width / 2, player.y + player.height / 2);
			}

			player.kill();
			isGameOver = true;
			gameOver();
		}
	}
	
	// проверка расположенных поблизости объектов на активацию игроком
	private function checkObjectsNearby():Void
	{
		var isAnyObjectHere:Bool = false;
		for (itemObject in itemGroup)
		{
			var _item:FlxSprite = cast(itemObject, FlxSprite);
			// если дистанция между объектом и игроком меньше 30 то появляется текстовое окно
			// if (FlxMath.distanceBetween(player, cast(itemObject, FlxSprite)) < 30)
			if (Math.abs(player.x + 4 - _item.x) < 24 && Math.abs(player.y - _item.y) < 8)
			{
				player.activateObject(cast(_item, ObjectItem).type, cast(_item, ObjectItem).special);
				isAnyObjectHere = true;
				// continue;
			}
		}
		if (!isAnyObjectHere)
		{
			player.activateObject(0);
		}
	}

	private function checkKeysAndDoors()
	{
		if (Reg.keysArray.length > 0)
		{
			for (index in Reg.keysArray)
			{
				// keys
				for (obj in itemGroup)
				{
					if (cast(obj, ObjectItem).special == index && cast(obj, ObjectItem).type == 3)
					{
						obj.kill();
						itemGroup.remove(obj, true);
					}
					if (cast(obj, ObjectItem).special == index && cast(obj, ObjectItem).type == 2)
					{
						obj.kill();
						itemGroup.remove(obj, true);
					}
				}
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
		// var dataMapString:String = "assets/data/map1.csv";
		var dataMapString:String = "assets/data/map" + _which + ".csv";
		var csvData:String = File.getContent(dataMapString);
			// Функция для преобразования CSV данных в двумерный массив
			var rows:Array<String> = csvData.split("\n");
		mapTilesAndObjects = [];
		// var liveFormPosition:Array<Array<Int>> = [];
			
			for (row in rows) {
				if (row != "") { // Игнорируем пустые строки
					var values:Array<String> = row.split(",");
					var intValues:Array<Int> = [];
					for (value in values) {
						intValues.push(Std.parseInt(value));
					}
				mapTilesAndObjects.push(intValues);
				}
			}

			// trace(result);

		for (i in 0...mapTilesAndObjects.length)
				{
			for (j in 0...mapTilesAndObjects[i].length)
					{
				switch mapTilesAndObjects[i][j]
				{
							case 0:
								//nothing;
							case 1:
						// wall
						creatWall(j, i, true, FlxDirectionFlags.ANY, 1);
							case 2:
						// platform
						creatWall(j, i, true, FlxDirectionFlags.UP, 2);
							case 3:
						// enemy skull
						creatEnemy(j, i, false, 0);
					case 4:
						creatWall(j, i, true, FlxDirectionFlags.ANY, 4);
					case 5:
						creatWall(j, i, true, FlxDirectionFlags.ANY, 5);
					case 6:
						creatWall(j, i, true, FlxDirectionFlags.ANY, 6);
					case 7:
						creatWall(j, i, true, FlxDirectionFlags.ANY, 7);
					case 8:
						// temporary platform
						creatWall(j, i, true, FlxDirectionFlags.UP, 8);
					case 9:
						// door
						creatObject(j, i, true, FlxDirectionFlags.ANY, 2);
					case 10:
						// exit
						creatObject(j, i, true, FlxDirectionFlags.NONE, 4);
					case 11:
						// разрушаемые стены (пока в виде ящиков)
						creatObject(j, i, true, FlxDirectionFlags.ANY, 0);
					case 12:
						// bonfire
						creatObject(j, i, true, FlxDirectionFlags.NONE, 1);
					case 13:
						// key
						creatObject(j, i, true, FlxDirectionFlags.NONE, 3, 0);
					case 14:
						// player start position
						// playerStartPosition.set(j * tileSize, i * tileSize);
						if (Reg.playerLastPosition.x == 0 && Reg.playerLastPosition.y == 0)
						{
							Reg.playerLastPosition.set(j * tileSize, i * tileSize);
						}
						trace("player start position:", playerStartPosition);
					case 15:
						// fake wall
						creatWall(j, i, true, FlxDirectionFlags.NONE, 9);
					case 16:
						// eye enemy
						creatEnemy(j, i, false, 1);
					case 17:
						// runner enemy
						creatEnemy(j, i, false, 2);
					case 18:
						// spider enemy
						creatEnemy(j, i, false, 3);
					case 19:
						// ghost enemy
						creatEnemy(j, i, false, 4);
					case 20:
						// serpent enemy
						creatEnemy(j, i, false, 5);
					case 21:
						// invisible wall
						creatWall(j, i, true, FlxDirectionFlags.ANY, 10);
					case 26:
						// boss 1
						creatBoss(j, i, false, 1);
				}
			}
		}

		// currentHeight -= tileSize * 32;
	}

	private function creatWall(jPos:Int = 0, iPos:Int = 0, isImmovable:Bool = true, dir:FlxDirectionFlags = FlxDirectionFlags.ANY, _type:Int = 1):Void
	{
		var tempTile:Tile = new Tile(jPos * 16, iPos * 16);
		// tempTile.x = jPos * 16;
		// tempTile.y = iPos * 16;
		tempTile.immovable = isImmovable;
		tempTile.allowCollisions = dir;
		tempTile.setType(_type);
		tileMapGroup.add(tempTile);
	}
	private function creatEnemy(jPos:Int = 0, iPos:Int = 0, isImmovable:Bool = true, _type:Int = 0):Void
	{
		var tempEnemy:Enemy = new Enemy(jPos * 16, iPos * 16);
		// tempEnemy.x = jPos * 16;
		// tempEnemy.y = iPos * 16;
		tempEnemy.immovable = isImmovable;
		tempEnemy.setType(_type);
		enemyGroup.add(tempEnemy);
	}

	// создаем босса
	private function creatBoss(jPos:Int = 0, iPos:Int = 0, isImmovable:Bool = false, _type:Int = 1):Void
	{
		boss = new Boss(jPos * 16, iPos * 16);
		boss.immovable = isImmovable;
		boss.setType(_type);
		boss.allowCollisions = ANY;
		add(boss);
		// enemyGroup.add(boss);
	}


	private function creatObject(jPos:Int = 0, iPos:Int = 0, isImmovable:Bool = true, dir:FlxDirectionFlags = FlxDirectionFlags.ANY, type:Int = 0, spec:Int = 0)
	{
		var tempObj:ObjectItem = new ObjectItem(jPos * 16, iPos * 16);
		// tempObj.x = jPos * 16;
		// tempObj.y = iPos * 16;
		tempObj.immovable = isImmovable;
		tempObj.setType(type);
		tempObj.setSpecial(spec);
		tempObj.allowCollisions = dir;
		itemGroup.add(tempObj);
		if (type == 13)
		{
			// if keys
			Reg.keysSpriteGroup.add(tempObj);
		}
		else if (type == 9)
		{
			// if door
			Reg.doorsSpriteGroup.add(tempObj);
		}

	}

	private function setSourceToEnemys()
	{
		for (enemyElement in enemyGroup)
		{
			cast(enemyElement, Enemy).setPlayerSource(player);
		}
		boss.setPlayerSource(player);
	}
}
