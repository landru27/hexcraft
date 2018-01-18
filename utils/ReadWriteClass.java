package sample;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import javassist.*;
import javassist.bytecode.*;

public class ReadWriteClass {
    public static void main(String[] args) throws Exception {
        ClassPool pool = ClassPool.getDefault();

        System.out.println("args are :  classfile: " + args[0] + ", method: " + args[1]);

        ClassPool cp = ClassPool.getDefault();
        InputStream ins = new FileInputStream(new File(args[0]));
        CtClass cc = cp.makeClass(ins);

        ClassFile cf = cc.getClassFile();
        MethodInfo mi = cf.getMethod(args[1]);
        mi.rebuildStackMap(pool);

        cc.writeFile("/tmp");
    }
}
