# Hacking Minecraft

## Chapter 0x02 - Weakened Creepers

### Intro

Now we start the actual hacking.

For this first hack, I will proceed through the steps in some detail.  Later chapters will summarize routine steps; refer back to this chapter if you need a reminder on the associated details.


### unpack the Minecraft .jar file

A .jar file is just a .zip file with a different file extension.  Its contents can be easily extracted with an ordinary Zip utility.

Both for searching within the Minecraft engine for where to make the change we want to make, and for making that change, we need to deal with the individual .class files that collectively comprise the Minecraft engine.  So, we unpack the Minecraft .jar file.  First, make a working area.  Second, copy in the v1.12.2 .jar from your installation of Minecraft.  Third, unzip it.  Finally, rename it so that later when we put the 1.12.2.jar file back together it does not collide with the original.

```
cd ~/hexcraft-blog/minecraft/craftingtable/
mkdir chapter-02-weakened-creepers
cd chapter-02-weakened-creepers/

## e.g., on my Mac, Minecraft is installed in my user's 'Library/Application Support/minecraft' directory
cp -ip '/Users/USERNAME/Library/Application Support/minecraft/versions/1.12.2/1.12.2.jar' ./1.12.2.jar

unzip 1.12.2.jar
mv -i 1.12.2.jar 1.12.2.jar--orig
```


### find the class file or files involved in the logic to be changed

We begin with a bit of detective work.  We need to think about what it is we want to change about the Minecraft engine, and search the Forge/MPC souce files for candidates.  In doing so, it is useful to search for both (1) likely .java file **names**, and (2) likely .java file **contents**.

For hacking creepers' explosion strength, it makes sense to look for source files with 'creeper' in the name, and it makes sense to look for source files with contents related to explosions.  Some searches I used for doing this include:

```
find                ~/hexcraft-blog/minecraft/forge/modding/build/tmp/recompileMc/sources/net/ | grep -i creeper
grep -ril explosion ~/hexcraft-blog/minecraft/forge/modding/build/tmp/recompileMc/sources/net/
grep -ril explod    ~/hexcraft-blog/minecraft/forge/modding/build/tmp/recompileMc/sources/net/
```

The `find` command turns up a nice short list of files, and some we can guess right away have nothing to do with behavior (e.g., `.../client/model/ModelCreeper.java` and `.../client/renderer/entity/RenderCreeper.java` both seem more related to appearance).  There are a great many files with 'explosion', but fewer with 'explod'.  The file `.../entity/monster/EntityCreeper.java` shows up in all three lists, and sounds like a fine place to at least start ...

... and bingo!  Right there near the top of the EntityCreeper class is a class variable: `private int explosionRadius = 3;`  Just what we are looking for.  If we can change that to "1", life in the Minecraft world should be a lot less hazardous.

In a normal programming life cycle, we'd chage this .java file, recompile it to an updated .class file, rebuild the .jar file, and call it a day.  If we were modding, we'd write a new .java file that would in some way or another override this class variable with a new one.  But we are **hacking**, and bytecode hacking at that.  So we are going to alter the .class file directly.

However!  Mojang obfuscates their Java code as part of their build process, so when we unpack the Minecraft .jar file, we don't see any .class files named anything remotely relating to creepers.  There are some asset files named like that, but unless we just want to change how creepers look, those aren't going to help us.

Thus, we need a way to find the correct .class file.

In non-obfuscated .class files, there are structures that preserve the variable names used in the .java source code, so we could normally search for those in the .class file, or in the output of `strings` on the .class file.  But part of Mojang's obfuscation is to replace every variable name with the unicode snowman character.  In a .class file, variable names are just handy references that tie back to the source code; the .class file has a different way to refer to each variable individually, which we will see more of in later chapters.

In both non-obfuscated and obfuscated .class files, any use of classes outside of itself must be done with an actual name for that other class, so we could normally search for .class files that make reference to all the classes that show up in `.../entity/monster/EntityCreeper.java`.  But part of Mojang's obfuscation is to obfuscate *all* the class names, so while the references are in tact, they refer to other classes that have themselves had their names obfuscated.

We need to search for things relatively unique to our target class file that cannot withstand obfuscation.

After trying several things, I hit upon a few reliable markers.  One of them is the NBT tags that a class makes use of.  NBT data is stored with an ordinary name (the 'N' in NBT) to mark its associated data in the NBT files (usually, .dat files).  The one that works best for the task at hand is "ExplosionRadius".  It stands to reason, as not many things in the Minecraft world have an explosion radius, and it can be confirmed with another grep of the Forge sources: `grep -rl ExplosionRadius ~/hexcraft-blog/minecraft/forge/modding/build/tmp/recompileMc/sources/net/` finds only one file: the same `.../client/model/ModelCreeper.java` in which we found `private int explosionRadius = 3;`.  Golden.

Back in `craftingtable/chapter-02-weakened-creepers/', when we `grep ExplosionRadius *` the only .class file listed is `acs.class`.  That file will be the subject of our edits, below.


### find the area within the appropriate class file(s) where that logic resides

Obfuscated Java .class files are, of course, still quite operable, which means that decompilers can still decompile them.  They still function perfectly logically -- otherwise, they could not execute properly -- they are simply hard for a human to read.  One of the principal tactics used is to rename all classes, methods, and constants with meaningless names.

If you ever thought having meaningful function and variable names was unneccsary, attempting to read some of the decompiled obfuscated code here will convince you otherwise.  As programmers, we really do read source code like a document or even a story.  The program makes sense to us when we can follow the flow.  Reading code where all the classes, methods, constants, and such have been replaced with one- to three-letter names makes the brain **hurt**.  You cannot follow it at all.  When the names of classes, methods, constants, and varibles relate to things we already understand, we can build up a sophisticated and elaborate narrative of what a program is doing.  When the names of things have nothing but internal relationships, while logically sound, we quickly lose track of what that logic is.  Our brains can only keep a handful of things in active memory, so in order to hold in our mind something involved and complex, we need referants whose story we are already familiar with.  Hence the purpose of meaningful class, method, constant, and varible names in ordinary programming.

So, despite the obfuscation, we can decompile the target .class file.  With effort, we can see what it is doing.  Issue: `java -jar ../../util/BytecodeViewer_2.9.8.jar`, and use the File menu to Add 'acs.class'.  The BytecodeViewer inteface is not the most intuitive thing, but one gets the hang of it with some poking around.  By default, BytecodeViewer presents us with two alternative decompilations of our selected class.  One is good for some things, and the other is good for other things.  Together, they tell us a lot about the target .class file.

As example of the kind of brain-hurt I mentioned just above, we see near the top of the JD-GUI view of acs.class code like this:

```
protected void r()
{
  this.br.a(1, new wz(this));
  this.br.a(2, new yj(this));
  this.br.a(3, new ws(this, aab.class, 6.0F, 1.0D, 1.2D));
  this.br.a(4, new xo(this, 1.0D, false));
  this.br.a(5, new yp(this, 0.8D));
  this.br.a(6, new xl(this, aed.class, 8.0F));
  this.br.a(6, new yb(this));

  this.bs.a(1, new yw(this, aed.class, true));
  this.bs.a(2, new yt(this, false, new Class[0]));
}
```

is exaclty what I mean.  Overall, this looks just like the sort of initialization code one would see near the top of most any class.  Bits of it are even crystal clear: there's no question about the numbers, and the booleans `true` and `false`.  But with class names like `br`, `aab`, and `aed`, and with method names like `r`, `wz`, `yj`, and `xl`, we have **no idea** what could be going on here.

Thank goodness (and a lot of work by dedicated people) for the Forge/MPC sources, which we can correlate to what we see in this decompilation, in order to make some semblence of sense of it.

For example, the line:
```
this.br.a(3, new ws(this, aab.class, 6.0F, 1.0D, 1.2D));
```

is this call to add avoidance behavior to a creeper's AI rules:
```
this.tasks.addTask(3, new EntityAIAvoidEntity(this, EntityOcelot.class, 6.0F, 1.0D, 1.2D));
```

By the same token we use the Forge/MPC sources to see that the area of code we are interested in is here:
```
private int bx;
private int by;
private int bz = 30;
private int bA = 3;
private int bB;
```

That "3" is what we want to change.  It's a small value, and we want to change the "3" to a "1", so it would be reasonable to assume this is a one-byte change to the .class file.  It is indeed a one-byte change, but not perhaps in the way one would predict, and it would be both naive and mis-informed to start looking near the top of the .class file for "0x03" bytes.


### read the existing bytecode to understand the actual program flow

Here is where we can make good use of the Bytecode view of acs.class.  The JD-GUI view looks like normal .java source code, and we see things like `private int bA = 3;`.  In reality, operations such as assignment don't take place anywhere except inside of a function.  The code `bA = 3` is really shorthand for "during instantiation, assign bA the value of 3".  Instantiation, of course, takes place in the constructor, whose name, while obfuscated, must match the class name.  And, indeed, we see a method `public acs(amu arg0)`.  Checking the Forge/MPC source code, we see that EntityCreeper does in fact have a 1-argument constructor (from which, by the way, we can conclude that the name `amu` is the obfuscated name for the World class).

In that constructor method, we find things that reflect what we see in the source code for the constructor, such as:
```
ldc 0.6 (java.lang.Float)
ldc 1.7 (java.lang.Float)
invokevirtual acs a((FF)V);
```

which because of the numbers involved sure looks like it corresponds to:
```
a(0.6F, 1.7F);
```

In fact, they do correspond.  `acs a()` is clearly a call do `a()` within `acs`, and `(FF)V` indicates that two floats are passed.  This matches very well with `a(0.6F, 1.7F)`, an in-class call to `a()`, passing two Floats.  The `ldc` lines are clearly involved, because they provide the specific values of those Floats.  This all ties together by reading and understanding the **bytecode** that corresponds to these operations.  The Wikipedia references I included in Chapter 0x01 are very valuable for reading Java bytecode, and after doing it enough, one begins to beable to read it like any language one is familiar with.

Using the Wikipedia bytecode reference, we see that the opcodes for the above are:
```
12 __    (__ here means "followed by one byte")
12 __
b6 __ __
```

That is, `ldc` (opcode `12`) pushes a value onto the stack, and `invokevirtual` calls a method, taking values off of the stack.  In both cases, the bytes after these opcodes are references to the class file's **constant pool**.  We can find these refernces in the constant pool, and for most of the hacks in this blog we will do just that.  Here I am just illustrating how the source code in the JD-GUI view relates to the readable bytecode in the Bytecode view, and how that relates to the opcodes that comprise a Java .class file.


### determine the bytecode changes that will implement the desired logic change

Applying the same method, we can find the assingnment of "3" for explosion radius.  Bear in mind that in the source code the initialization assignment seems to appear outside of any method, but that's just shorthand (all source code is just shorthand); the actual assignment takes place inside the constructor.  Applying the above method, we find:
```
aload0
bipush 30
putfield acs.bz:int

aload0
iconst_3
putfield acs.bA:int
```

Which is the human-readable form of the bytecode:
```
2a                [aload_0]
10 1e             [bipush 30]
b5 0017           [putfield 23    [acs bz, I]]

2a                [aload_0]
06                [iconst_3]
b5 0019           [putfield 25    [acs bA, I]]
```

Notice a couple of things about `bipush` and `iconst_3`.  First, `bipush` is like `ldc` in that it is followed by an argument byte, but *unlike* `ldc` because that byte is the actual value to use, not a reference to the constant pool.  Second, notice that `iconst_3` is *not* followed by an argument byte.  One thing to notice about the collection of Java opcodes is that those dealing with the frequently-used values of 0, 1, 2, and 3 have bytecodes that *imply* these argument values.  For integers, there are opcodes that imply -1, 4, and 5 as well.  At the cost of precious space on the bytecode table (there can only be a maximum of 256 distinct bytecodes), Java cuts in half the number of program bytes that need to be processed by the JVM in order to deal with the most frequently used values.  Just think about the number of times while writing a program you set something to '0' or '1'.  The space and execution time saved adds up when the JVM can do these things with 1 byte instead of 2 bytes.

Like with `ldc` and `invokevirtual`, `putfield` takes a reference to the constant pool; that's what the '23' and '25' are.  These resolve to a descriptor for a variable.  `putfield` pops from the stack the value pushed there by `bipush` / `iconst_3`, storing it in the indicated variable.

So, to change the '3' to a '1', we do indeed need to make a 1-byte change, ...  But we need to change the `06` for `iconst_3` to `04` for `iconst_1`.  That will push a '1' onto the stack, which `putfield` will pop and store in `acs.bA`.


### alter the bytecode (dump the class file to text-hex, edit, and reconstitute into binary)



### repackage the Minecraft .jar file


