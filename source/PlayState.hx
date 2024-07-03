package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxDirectionFlags;
import sys.io.File;

class PlayState extends FlxState
{
	private var player:Player;

	private var lava:Lava;

	//groups wallbounds
	private var tileMapGroup:FlxGroup;
	private var enemyGroup:FlxGroup;
	private var particleGroup:FlxGroup;

	//params
	private var currentHeight:Int = 0;
	private var tileSize:Int = 16;

    override public function create():Void
    {
        super.create();

		// FlxG.autoPause = false;
		FlxG.mouse.visible = false;

		//init groups
		tileMapGroup = new FlxGroup();
		add(tileMapGroup);
		enemyGroup = new FlxGroup();
		add(enemyGroup);
		particleGroup = new FlxGroup();
		add(particleGroup);

		//Формирование одного этажа
		creatingFloor();
		creatingFloor();

		// Создаем игрока
        player = new Player(32, 400);
        add(player);

		//lava
		// lava = new Lava(-60, player.y + 200);
		// add(lava);
	
		//доп условия сцены
		// FlxG.camera.setScrollBoundsRect(32, 0, 288, 1000);
		FlxG.camera.setScrollBounds(32, 288, null, null);
		FlxG.camera.follow(player);
		// FlxG.camera.setPosition(50, 50);
		// trace(FlxG.camera.x, FlxG.camera.y);
    }

	override public function update(elapsed:Float):Void
		{
		// Обработка коллизий игрока и стен
			FlxG.collide(player, tileMapGroup, onCollideFunction);
		// Обработка коллизий мобов и стен
		FlxG.collide(enemyGroup, tileMapGroup);
		// Обработка коллизий игрока и мобов
		FlxG.collide(player, enemyGroup, onCollidePlayerEnemy);
		// Обработка оверлапов крови и стен
		FlxG.collide(particleGroup, tileMapGroup, onOverlapParticleWall);

			// FlxG.collide(player, tileMapGroup, function(player:FlxObject, tilemap:FlxObject):Void {
			// 	// if (player.touching == FlxObject.LEFT || player.touching == FlxObject.RIGHT)
			// 	if (player.touching == FlxDirectionFlags.LEFT || player.touching == FlxDirectionFlags.RIGHT)
			// 	{
			// 		(cast player:Player).onWallCollision();
			// 	}
			// });

			//обновление области коллизий по положению игрока
			FlxG.worldBounds.setPosition(player.x, player.y);
			// FlxG.worldBounds.setSize(320, 240);

			// Обработка коллизий с лавой
			FlxG.overlap(player, lava, onLavaCollision);
			super.update(elapsed);
		}

		//ON UPDATE FUNCTIONS
		private function onCollideFunction(player:FlxObject, sprGroup:FlxObject):Void
		{
			if (player.touching == FlxDirectionFlags.LEFT || player.touching == FlxDirectionFlags.RIGHT)
			{
				(cast player:Player).onWallCollision();
			}
			if(Std.is(sprGroup, Tile)){
				if (cast(sprGroup, Tile).getType() == 2 && cast(player, Player).isWantFall){
					player.y += 8;
				}
			}
		}

	private function onCollidePlayerEnemy(player:FlxObject, sprGroup:FlxObject):Void
	{
		if (player.touching == FlxDirectionFlags.DOWN)
		{
			(cast sprGroup : FlxObject).kill();
			creatBlood(sprGroup.x + sprGroup.width / 2, sprGroup.y + sprGroup.height / 2);
			player.velocity.y = -600;
		}
	}

	private function onOverlapParticleWall(particle:FlxObject, sprGroup:FlxObject):Void
	{
		particle.velocity.set(0, 0);
		particle.acceleration.set(0, 0);
		// particle.angularAcceleration = 0;
	}

		private function onLavaCollision(player:FlxObject, lava:FlxObject):Void
		{
			// Заканчиваем игру, если игрок касается лавы
			// FlxG.switchState(new EndState());
			trace("END GAME");
		}

		
	// other functions
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
		//creatingFloor function
		private function creatingFloor():Void {
			
			// // Создаем и загружаем карту
			// tilemap = new FlxTilemap();
			// // Путь к вашему тайлсету и данные карты
			// var tilesetPath:String = "assets/images/tilesetimage.png";
			// var tilemapdata:String = "assets/data/room-004.csv";
			// tilemap.loadMapFromCSV(tilemapdata, tilesetPath, 16, 16);
	
			// tileMapGroup.add(tilemap);

			// новый вариант
			// Загрузка данных CSV в строковую переменную
			// var csvData:String = Assets.getText("assets/data/room-004.csv");
			var csvData:String = File.getContent("assets/data/room-004.csv");
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
								tempTile.y = i * 16 + currentHeight;
								tempTile.immovable = true;
								tempTile.allowCollisions = FlxDirectionFlags.ANY;
								tempTile.setType(1);
								tileMapGroup.add(tempTile);
							case 2:
						// platform
								var tempTile:Tile = new Tile(0,0);
								tempTile.x = j * 16;
								tempTile.y = i * 16 + currentHeight;
								tempTile.immovable = true;
								tempTile.allowCollisions = FlxDirectionFlags.UP;
								tempTile.setType(2);
								tileMapGroup.add(tempTile);
							case 3:
						// enemy
						var tempEnemy:Enemy = new Enemy(0, 0);
						tempEnemy.x = j * 16;
						tempEnemy.y = i * 16 + currentHeight;
						tempEnemy.immovable = true;
						enemyGroup.add(tempEnemy);
						}
					
				}
			}

			trace("flooar created");
			currentHeight -= tileSize * 32;
		}
}
