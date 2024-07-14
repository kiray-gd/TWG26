package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class FinalState extends FlxState
{
	private var mainTitle:FlxText;
    private var statsTitle:FlxText;
	private var bsTitle:FlxSprite;
    private var qrTitle:FlxSprite;
    private var duckTitle:FlxSprite;

    private var speedOfTitle:Float = 0.3;
    private var timeToGo:Int = 500;
	private var currentTime:Int = 0;

    // gems
    private var gemsGroup:FlxGroup;


	override public function create()
	{
		super.create();
        FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		FlxG.timeScale = 1;

        var gemSumm:Int = 0;
        for(elem in Reg.gems){
            if(elem)gemSumm++;
        }
        
       

		FlxG.camera.flash(0xFFFFFD98, 0.6);

        mainTitle = new FlxText(0, 240, 320);
		// mainTitle.setFormat("assets/data/pixelcyrr.ttf", 11, 0x58e66b, FlxTextAlign.CENTER);
		mainTitle.setFormat("assets/data/pixelcyrr.ttf", 11, 0xFFFFE4AB, "center");
		// 333333
		// mainTitle.y = 156;
		add(mainTitle);

        bsTitle = new FlxSprite();
		bsTitle.loadGraphic("assets/images/finaltitle.png");
		bsTitle.y = 0;
		add(bsTitle);

        qrTitle = new FlxSprite();
        qrTitle.loadGraphic("assets/images/qr.png");
        qrTitle.x = 90;
        
		add(qrTitle);

        statsTitle = new FlxText(0, 140, 320);
		statsTitle.setFormat("assets/data/pixelcyrr.ttf", 11, 0xFFFFAE00, "center");
		// statsTitle.y = 76;
		add(statsTitle);
		statsTitle.text = "Крови сохранено: " + Reg.blood;
		statsTitle.text += "
Гемов собрано: " + gemSumm + " из 5";

        duckTitle = new FlxSprite();
        

        if(gemSumm >= 5){
            FlxG.sound.playMusic("assets/music/dreaming.ogg", 0.4, true);
            FlxG.cameras.bgColor = 0xFFFFFFFF;
            mainTitle.setFormat("assets/data/pixelcyrr.ttf", 11, 0xFF815EFF, "center");
            duckTitle.loadGraphic("assets/images/goodduck.png");
            statsTitle.text += "
открыта истинная концовка";
        }   else{
            // bad music
            FlxG.sound.playMusic("assets/music/drift.ogg", 0.4, true);
            FlxG.cameras.bgColor = 0xFF000000;
            duckTitle.loadGraphic("assets/images/badduck.png");
            statsTitle.text += "
открыта темная концовка";
        }

        qrTitle.y = 1000;
        duckTitle.x = -4;
        duckTitle.y = 940;
        add(duckTitle);

        //gems sprite
        gemsGroup = new FlxGroup();
        add(gemsGroup);
        for(index in 0...Reg.gems.length){
            var gemSprite:FlxSprite = new FlxSprite();
            gemSprite.loadGraphic("assets/images/guitiles.png", true, 16, 16, false);
			if (Reg.gems[index])
			{
				// 	gemSprite.animation.add("idle", [Reg.gems.indexOf(gemElement)+1])
				// 	Reg.gems.indexOf(gemElement)
				switch index
				{
					case 0:
						gemSprite.animation.add("idle", [1], 10, false);
					case 1:
						gemSprite.animation.add("idle", [2], 10, false);
					case 2:
						gemSprite.animation.add("idle", [3], 10, false);
					case 3:
						gemSprite.animation.add("idle", [4], 10, false);
					case 4:
						gemSprite.animation.add("idle", [5], 10, false);
				}
			}
			else
			{
				gemSprite.animation.add("idle", [6], 10, false);
			}
			gemSprite.animation.play("idle");
            gemsGroup.add(gemSprite);
            gemSprite.x = 120 + (16 * index);
			gemSprite.y = 120;
        }


		mainTitle.text = "
Благодарности
P1nk_x1
Pururin
Нульч
cojam
		
Музыка
kiraygd - dreaming
kiraygd - drift
kiraygd - forgoten
kiraygd - midnight
		
Звуки
Чешуегорлый мохо
		
Инструменты разработки
HaxeFlixel
VS code
Adobe Photoshop
audacity
Bfxr Standalone
Suno
Leonardo.ai
		
		

Спасибо, что прошли мою игру!";
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		currentTime++;
		if (currentTime > timeToGo && currentTime < 3600)
		{
			bsTitle.alpha -= 0.01;
			statsTitle.y -= speedOfTitle;
			mainTitle.y -= speedOfTitle;
            qrTitle.y -= speedOfTitle;
            duckTitle.y -= speedOfTitle;
			// sprGroup.y -= speedOfTitle;
			// trace(currentTime);
            for(spr in gemsGroup){
                cast(spr, FlxSprite).y -= speedOfTitle;
            }
		}
	}
}
