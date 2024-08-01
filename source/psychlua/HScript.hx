package psychlua;

import flixel.FlxBasic;
import objects.Character;
import psychlua.LuaUtils;
import psychlua.CustomSubstate;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

class SimpleHScript extends SScript {
    public var modFolder:String;
    
    #if LUA_ALLOWED
    public var parentLua:FunkinLua;
    #end

    override public function new(?parent:Dynamic, ?file:String = '', ?varsToBring:Dynamic = null) {
        super(file, false, false);

        #if LUA_ALLOWED
        parentLua = parent;
        #end
        
        if (file != null && file.length > 0) {
            this.modFolder = extractModFolder(file);
        }
        
        preset();
        execute();
    }

    private function extractModFolder(file:String):String {
        var parts:Array<String> = file.split('/');
        return (parts.length > 1) ? parts[1] : '';
    }

    override function preset() {
        super.preset();

        // Commonly used classes and functions
        set('FlxG', flixel.FlxG);
        set('FlxSprite', flixel.FlxSprite);
        set('PlayState', PlayState);
        set('Character', Character);
        set('CustomSubstate', CustomSubstate);
        
        set('setVar', function(name:String, value:Dynamic) {
            PlayState.instance.variables.set(name, value);
            return value;
        });
        set('getVar', function(name:String) {
            return PlayState.instance.variables.exists(name) ? PlayState.instance.variables.get(name) : null;
        });
        set('removeVar', function(name:String) {
            if (PlayState.instance.variables.exists(name)) {
                PlayState.instance.variables.remove(name);
                return true;
            }
            return false;
        });

        // Input handling
        set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
        set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
        set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));
    }

    public function executeCode(?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):TeaCall {
        if (funcToRun == null || !exists(funcToRun)) {
            PlayState.instance.addTextToDebug('No function named: ' + funcToRun, FlxColor.RED);
            return null;
        }

        var callValue:TeaCall = call(funcToRun, funcArgs);
        if (!callValue.succeeded) {
            PlayState.instance.addTextToDebug('Execution error: ' + callValue.exceptions[0].toString(), FlxColor.RED);
        }
        return callValue;
    }

    override public function destroy() {
        #if LUA_ALLOWED
        parentLua = null;
        #end

        super.destroy();
    }
}
