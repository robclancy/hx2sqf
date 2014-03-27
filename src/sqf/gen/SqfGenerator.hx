package sqf.gen;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
 
class SqfGenerator {
    
    var buf:StringBuf;
    var outputFile:String;
    
    var transformTime:Float;
    var printTime:Float;
    
    public function new(outputFile:String)
    {
        printTime = 0.0;
        transformTime = 0.0;
        this.outputFile = outputFile;

        buf = new StringBuf();
    }
    
    inline function print(str)
    {
        buf.add(str);
    }
    inline function printLine(str)
    {
        print(str + "\n");
    }

    inline function newline()
    {
        print("\n");
    }
    
    function genTypes(types:Array<Type>) 
    {
        for (type in types) 
        {
            genType(type);
        }
    }
    
    function genType(type:Type)
    {
        switch(type) {
            case TInst(c, _):
                genClass(c.get(), type, c);
            /*case TEnum(r, _):
                var e = r.get();
                if(! e.isExtern) genEnum(e);*/
            case _ :
        }
    }
    
    function genClass(c:ClassType, type:Type, cRef:Ref<ClassType>)
    {
        //genPreCodeMeta(c.meta.get());
        printLine("// print " + c.module + "." + c.name);
        
        if ( ! c.isExtern) {
            print(getFullName(c));
        }
    }
    
    function getFullName (t:BaseType) 
    {
       var hasPack = t.pack.length > 0;
       var pack1 = t.pack.join(".");
       var pack2 = t.pack.join("_");

       var moduleName = { var p = t.module.split("."); p[p.length-1];};
       
       var hasModule = (moduleName != t.name);



       var hasModulePrefix = (hasPack && hasModule);
       var hasTypePrefix = (hasPack || hasModule);

       var modulePrefix1 = hasModulePrefix ? "." : "";
       

       var typePrefix1 = hasTypePrefix ? "." : "";
       

       var moduleStr = hasModule ? "_" + moduleName : "";
       return if (!t.isPrivate) {
            var typePrefix1 = hasPack ? "." : ""; 
            pack1 + typePrefix1 + t.name;
       } else {
            pack1 + modulePrefix1 + moduleStr + typePrefix1 + t.name;
       }
       
    }
    
    /*function genPreCodeMeta(m:Metadata) {
        var entry = m.find(function (e) return e.name == ":preCode");
        if (entry != null) {
            if (entry.params == null || entry.params.length != 1) throw "assert";

            switch (entry.params[0].expr) {
                case EConst(CString(s)): print(s);
                case _ : throw "assert";
            }
        }
    }*/
    
    function generate(types:Array<Type>) {
        // types contains all the compiled types, see http://api.haxe.org/haxe/macro/Type.html
        // Typically you now do something like this:
        /*
        for (type in types ){
            switch(type) {
                case TInst(c, _):
                    printLine('Class');
                    trace('Generating class $c');
                case TEnum(en, _):
                    printLine('Enum');
                    trace('Generating enum $en');
                case TAbstract(a, _):
                    printLine('abstract');
                    trace('Generating abstract $a');
                case TType(t, _):
                    // Ignore, I guess.
                case t:
                    printLine('noooo');
                    trace("This never happens: " + t);
            }
        }*/
        
        genTypes(types);
        
        writeFile();
    }
    
    function writeFile ()
    {
        sys.io.File.saveContent(outputFile, buf.toString());
    }
    
    static public function use(outputFile : String) {
        Compiler.allowPackage('sys');
        
        Context.onGenerate(function(types) {
            new SqfGenerator(outputFile).generate(types);
        });
    }
}