package funkin.mobile;

import funkin.mobile.FunkinButton;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.FlxG;
import openfl.geom.Matrix;
import openfl.display.Shape;
import openfl.display.BitmapData;

/**
 * A zone with 4 buttons (A hitbox).
 * It's really easy to customize the layout.
 */
class FunkinHitbox extends FlxTypedSpriteGroup<FunkinButton>
{
  /**
   * The array containing the hitbox's buttons.
   */
  public var hints(default, null):Array<FunkinButton> = [];

  /**
   * A `FlxTypedSignal` that triggers every time a button was pressed.
   */
  public var onHintDown:FlxTypedSignal<(FunkinHitbox, FunkinButton) -> Void> = new FlxTypedSignal<(FunkinHitbox, FunkinButton) -> Void>();

  /**
   * A `FlxTypedSignal` that triggers every time a button was released.
   */
  public var onHintUp:FlxTypedSignal<(FunkinHitbox, FunkinButton) -> Void> = new FlxTypedSignal<(FunkinHitbox, FunkinButton) -> Void>();

  /**
   * Create the zone.
   *
   * @param ammo The ammount of buttons you want to create.
   * @param perHintWidth The width that the buttons will use.
   * @param perHintHeight The height that the buttons will use.
   * @param colors The color per button.
   */
  public function new(ammo:UInt, perHintWidth:Int, perHintHeight:Int, colors:Array<FlxColor>):Void
  {
    super();

    if (colors == null || colors.length < ammo) colors = [for (i in 0...ammo) 0xFFFFFFFF];

    for (i in 0...ammo)
      add(hints[i] = createHint(i * perHintWidth, 0, perHintWidth, perHintHeight, colors[i]));

    scrollFactor.set();

    zIndex = 100000;
  }

  private function createHint(x:Float, y:Float, width:Int, height:Int, color:FlxColor = 0xFFFFFFFF):FunkinButton
  {
    var hint:FunkinButton = new FunkinButton(x, y, DIRECTION_BUTTON);
    hint.loadGraphic(createHintGraphic(width, height, color));
    hint.solid = false;
    hint.immovable = true;
    hint.alpha = 0.00001;
    hint.onDown = hint.onOver = function():Void
    {
      onHintDown.dispatch(this, hint);

      if (hint.alpha != 0.2) hint.alpha = 0.2;
    }
    hint.onUp = hint.onOut = function():Void
    {
      onHintUp.dispatch(this, hint);

      if (hint.alpha != 0.00001) hint.alpha = 0.00001;
    }
    #if FLX_DEBUG
    hint.ignoreDrawDebug = true;
    #end
    return hint;
  }

  private function createHintGraphic(width:Int, height:Int, baseColor:FlxColor = 0xFFFFFFFF):FlxGraphic
  {
    var shape:Shape = new Shape();

    var matrix:Matrix = new Matrix();
    matrix.createGradientBox(width, height, 0, 0, 0);
    shape.graphics.beginGradientFill(RADIAL, [baseColor, baseColor], [0, 1], [60, 255], matrix, PAD, RGB, 0);
    shape.graphics.drawRect(0, 0, width, height);
    shape.graphics.endFill();

    var bitmap:BitmapData = new BitmapData(width, height, true, 0);
    bitmap.draw(shape, true);
    return FlxGraphic.fromBitmapData(bitmap, false, null, false);
  }

  /**
   * Clean up memory.
   */
  override public function destroy():Void
  {
    super.destroy();

    hints = FlxDestroyUtil.destroyArray(hints);
  }
}
