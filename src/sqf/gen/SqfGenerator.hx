package sqf.gen;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Type;
 
class SqfGenerator {
    static public function use(outputFile : String) {
        Context.onGenerate(generate);
        
        Compiler.allowPackage('sys');
        sys.io.File.saveContent(outputFile, 'test');
    }
    
    static function generate(types:Array<Type>) {
        // types contains all the compiled types, see http://api.haxe.org/haxe/macro/Type.html
        // Typically you now do something like this:
        
        for (type in types ){
            switch(type) {
                case TInst(c, _):
                    trace('Generating class $c');
                case TEnum(en, _):
                    trace('Generating enum $en');
                case TAbstract(a, _):
                    trace('Generating abstract $a');
                case TType(t, _):
                    // Ignore, I guess.
                case t:
                    trace("This never happens: " + t);
            }
        }
    }
}