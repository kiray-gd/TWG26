package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		// true
		// addChild(new FlxGame(320, 240, StartState));
		
		// test
		addChild(new FlxGame(320, 240, PlayState));
		// addChild(new FlxGame(320, 240, FinalState));
	}
}
