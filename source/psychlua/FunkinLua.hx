package funk;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.addons.display.FlxRuntimeShader;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.StringTools;
import flixel.addons.FlxAnimate;
import backend.BaseStage.Countdown;
import backend.PsychCamera;
import backend.Conductor;
import backend.ClientPrefs;
import backend.Achievements;
import backend.Mods;
import backend.PlayState;
import backend.Paths;
import backend.Alphabet;
import backend.Note;
import backend.CustomSubstate;
import backend.Character;
import backend.LuaUtils;

class FunkinLua {

    public var scriptName:String;
    public var modFolder:String;
    public var hscript:HScript;

    public function new(scriptName:String, modFolder:String) {
        this.scriptName = scriptName;
        this.modFolder = modFolder;
        this.hscript = new HScript(this);
    }

    public function initHaxeModule(code:String, varsToBring:Dynamic = null) {
        hscript.initHaxeModuleCode(this, code, varsToBring);
    }

    public function addLocalCallback(name:String, func:Dynamic) {
        hscript.set(name, func);
    }

    public function executeFunction(funcToRun:String, funcArgs:Array<Dynamic>):Dynamic {
        var callValue = hscript.executeFunction(funcToRun, funcArgs);
        if (callValue != null && callValue.succeeded) {
            return callValue.returnValue;
        }
        return null;
    }

    public function addHaxeLibrary(libName:String, libPackage:String = '') {
        hscript.addHaxeLibrary(libName, libPackage);
    }

    public function createGlobalCallback(name:String, func:Dynamic) {
        // Implement global callback functionality
        for (script in PlayState.instance.luaArray) {
            if (script != null && script.lua != null && !script.closed) {
                LuaHelper.addCallback(script.lua, name, func);
            }
        }
        this.addLocalCallback(name, func);
    }

    public function setVar(name:String, value:Dynamic) {
        PlayState.instance.variables.set(name, value);
    }

    public function getVar(name:String):Dynamic {
        return PlayState.instance.variables.get(name);
    }

    public function removeVar(name:String):Bool {
        return PlayState.instance.variables.remove(name);
    }

    public function debugPrint(text:String, color:Int = FlxColor.WHITE) {
        PlayState.instance.addTextToDebug(text, color);
    }

    public function getModSetting(saveTag:String, modName:String = null):Dynamic {
        if (modName == null) {
            if (this.modFolder == null) {
                debugPrint('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', FlxColor.RED);
                return null;
            }
            modName = this.modFolder;
        }
        return LuaUtils.getModSetting(saveTag, modName);
    }

    public function keyboardJustPressed(name:String):Bool {
        return Reflect.getProperty(FlxG.keys.justPressed, name);
    }

    public function keyboardPressed(name:String):Bool {
        return Reflect.getProperty(FlxG.keys.pressed, name);
    }

    public function keyboardReleased(name:String):Bool {
        return Reflect.getProperty(FlxG.keys.justReleased, name);
    }

    public function gamepadJustPressed(id:Int, name:String):Bool {
        var controller = FlxG.gamepads.getByID(id);
        if (controller != null) {
            return Reflect.getProperty(controller.justPressed, name) == true;
        }
        return false;
    }

    public function gamepadPressed(id:Int, name:String):Bool {
        var controller = FlxG.gamepads.getByID(id);
        if (controller != null) {
            return Reflect.getProperty(controller.pressed, name) == true;
        }
        return false;
    }

    public function gamepadReleased(id:Int, name:String):Bool {
        var controller = FlxG.gamepads.getByID(id);
        if (controller != null) {
            return Reflect.getProperty(controller.justReleased, name) == true;
        }
        return false;
    }

    public function keyJustPressed(name:String):Bool {
        name = name.toLowerCase();
        switch (name) {
            case 'left': return Controls.instance.NOTE_LEFT_P;
            case 'down': return Controls.instance.NOTE_DOWN_P;
            case 'up': return Controls.instance.NOTE_UP_P;
            case 'right': return Controls.instance.NOTE_RIGHT_P;
            default: return Controls.instance.justPressed(name);
        }
    }

    public function keyPressed(name:String):Bool {
        name = name.toLowerCase();
        switch (name) {
            case 'left': return Controls.instance.NOTE_LEFT;
            case 'down': return Controls.instance.NOTE_DOWN;
            case 'up': return Controls.instance.NOTE_UP;
            case 'right': return Controls.instance.NOTE_RIGHT;
            default: return Controls.instance.pressed(name);
        }
    }

    public function keyReleased(name:String):Bool {
        name = name.toLowerCase();
        switch (name) {
            case 'left': return Controls.instance.NOTE_LEFT_R;
            case 'down': return Controls.instance.NOTE_DOWN_R;
            case 'up': return Controls.instance.NOTE_UP_R;
            case 'right': return Controls.instance.NOTE_RIGHT_R;
            default: return Controls.instance.justReleased(name);
        }
    }

    public function destroy() {
        // Clean up resources
        scriptName = null;
        modFolder = null;
        hscript = null;
    }
}
