package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 240, PlayState));
		// addChild(new FlxGame(320, 240, StartState));
		// addChild(new FlxGame(320, 240, FinalState));
	}
}
