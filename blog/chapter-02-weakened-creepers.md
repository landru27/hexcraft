# Hacking Minecraft

## Chapter 0x02 - Weakened Creepers

### intro

Now we start the actual hacking.

For this first hack, I will proceed through the steps in some detail.  Later chapters will summarize routine steps; refer back to this chapter if you need a reminder on the associated details.


### unpack the Minecraft .jar file

Both for searching within the Minecraft engine for where to make the change we want to make, and for making that change, we need to deal with the individual .class files that collectively comprise the Minecraft engine.  So, we unpack the Minecraft .jar file.

The .jar file format is the same as used for .zip files; the JAR file format is a vaient of the [ZIP file format](https://en.wikipedia.org/wiki/Zip_%28file_format%29).  A .jar file's contents can therefore easily be extracted with an ordinary Zip utility.

First, make a working area for this blog chapter.  Second, copy in the v1.12.2 .jar from your installation of Minecraft.  Third, unzip it.  Finally, rename it so that later when we put the 1.12.2.jar file back together it does not collide with the original.

```
cd ~/hmcb/craftingtable/
mkdir chapter-02-weakened-creepers/
cd    chapter-02-weakened-creepers/

## e.g., on my Mac, Minecraft is installed in my user's 'Library/Application Support/minecraft' directory
cp -ip '/Users/USERNAME/Library/Application Support/minecraft/versions/1.12.2/1.12.2.jar' ./1.12.2.jar

unzip 1.12.2.jar
mv -i 1.12.2.jar 1.12.2.jar--orig
```


### find the class file or files involved in the logic to be changed

This step takes a bit of detective work.  We need to think about what it is we want to change about the Minecraft engine, and search the MCP / Forge souce files for candidates.  In doing so, it is useful to search for both (1) likely .java file **names**, and (2) likely .java file **contents**.

For hacking creepers' explosion strength, it makes sense to look for source files with 'creeper' in the name, and it makes sense to look for source files with contents related to explosions.  Some searches I used for doing this include:

```
find                ~/hmcb/forge/modding/build/tmp/recompileMc/sources/net/ | grep -i creeper
grep -ril explosion ~/hmcb/forge/modding/build/tmp/recompileMc/sources/net/
grep -ril explod    ~/hmcb/forge/modding/build/tmp/recompileMc/sources/net/
```

The `find` command turns up a nice short list of files, and some we can guess right away have nothing to do with behavior (e.g., `.../client/model/ModelCreeper.java` and `.../client/renderer/entity/RenderCreeper.java` both seem more related to appearance).  There are a great many files with 'explosion', but fewer with 'explod'.  The file `.../entity/monster/EntityCreeper.java` shows up in all three lists, and sounds like a fine place to at least start ...

... and bingo!  Right there near the top of the EntityCreeper class is a class variable: `private int explosionRadius = 3;`  Just what we are looking for.  If we can change that to "1", life in the Minecraft world should be a lot less hazardous.

In a normal programming life cycle, we'd chage this .java file, recompile it to an updated .class file, rebuild the .jar file, and call it a day.  If we were modding, we'd write a new .java file that would in some way or another override this class variable with a new one.  But we are **hacking**, and bytecode hacking at that.  So we are going to alter the .class file directly.

#### a side trip into obfuscated Java .class files

However!  Mojang obfuscates their Java code as part of their build process, so when we unpack the Minecraft .jar file, we don't see any .class files named anything remotely relating to creepers.  There are some asset files named like that, but unless we just want to change how creepers look, those aren't going to help us.

Thus, we need a way to find the correct .class file.

In non-obfuscated .class files, there are structures that preserve the variable names used in the .java source code, so we could normally search for those in the .class file, or in the output of `strings` on the .class file.  But part of Mojang's obfuscation is to replace every variable name with the unicode snowman character.  In a .class file, variable names are just handy references that tie back to the source code; the .class file has a different way to refer to each variable individually, which is why it's safe for Mojang to obfuscate the local variable names.  (Why they chose the snoman glyph, I have no idea.)  We will deal with local variables in more detail in later chapters.

In both non-obfuscated and obfuscated .class files, any use of classes outside of itself must be done with an actual name for that other class, so we could normally search for .class files that make reference to all the classes that show up in `.../entity/monster/EntityCreeper.java`.  But part of Mojang's obfuscation is to obfuscate *all* the class names, so while the references are intact, they refer to other classes that have themselves had their names obfuscated.

We need to search for things relatively unique to our target class file that cannot withstand obfuscation.

After trying several things, I hit upon a few reliable markers.  One of them is the [NBT tags](https://minecraft.gamepedia.com/NBT_format) that a class makes use of.  NBT data is stored with an ordinary name (the 'N' in NBT) to mark its associated data in the NBT files (usually, .dat files).  The one that works best for the task at hand is "ExplosionRadius".  It stands to reason, as not many things in the Minecraft world have an explosion radius, and it can be confirmed with another grep of the MCP / Forge sources: `grep -rl ExplosionRadius ~/hmcb/forge/modding/build/tmp/recompileMc/sources/net/` finds only one file: the same `.../entity/monster/EntityCreeper.java` in which we found `private int explosionRadius = 3;`.  Golden.

Back in `craftingtable/chapter-02-weakened-creepers/', when we `grep ExplosionRadius *` the only .class file listed is `acs.class`.  That file will be the subject of our edits, below.


### find the area within the appropriate class file(s) where that logic resides

Obfuscated Java .class files are, of course, still quite operable, which means that decompilers can still decompile them.  They still function perfectly logically -- otherwise, they could not execute properly -- they are simply hard for a human to read.  One of the principal tactics used is to rename all classes, methods, and constants with meaningless names.

If, in your own programming work, you ever thought having clear and meaningful function and variable names was unneccsary, attempting to read some of the decompiled obfuscated code here will convince you otherwise.  As programmers, we really do read source code like a document or even a story.  The program makes sense to us when we can follow the flow.  Reading code where all the classes, methods, constants, and such have been replaced with one- to three-letter names makes the brain **hurt**.  You cannot follow it at all.  When the names of classes, methods, constants, and varibles relate to things we already understand, we can build up a sophisticated and elaborate narrative of what a program is doing.  When the names of things have nothing but internal relationships, while logically sound, we quickly lose track of what that logic is.  Our brains can only keep a handful of things in active memory, so in order to hold in our mind something involved and complex, we need referants whose story we are already familiar with.  Hence the purpose of meaningful class, method, constant, and varible names in ordinary programming.

So, despite the obfuscation, we can decompile the target .class file.  With effort, we can see what it is doing.  Issue: `java -jar ../../util/BytecodeViewer_2.9.8.jar`, and use the File menu to Add 'acs.class'.  The BytecodeViewer inteface is not the most intuitive thing, but one gets the hang of it with some poking around.  By default, BytecodeViewer presents us with two alternative decompilations of our selected class.  One is good for some things, and the other is good for other things.  Together, they tell us a lot about the target .class file.

As example of the kind of brain-hurt I mentioned just above, code like this found near the top of the JD-GUI view of acs.class ...
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

... is exaclty what I mean.  Overall, this looks just like the sort of initialization code one would see near the top of most any class.  Bits of it are even crystal clear: there's no question about the numbers, and the booleans `true` and `false`.  But with class names like `br`, `aab`, and `aed`, and with method names like `r`, `wz`, `yj`, and `xl`, we have **no idea** what could be going on here.

Thank goodness (and a lot of work by dedicated people) for the MCP / Forge sources, which we can correlate to what we see in this decompilation, in order to make some semblence of sense of it.

For example, the line:
```
this.br.a(3, new ws(this, aab.class, 6.0F, 1.0D, 1.2D));
```

is this call to add avoidance behavior to a creeper's AI rules:
```
this.tasks.addTask(3, new EntityAIAvoidEntity(this, EntityOcelot.class, 6.0F, 1.0D, 1.2D));
```

By the same token we use the MCP / Forge sources to see that the area of code we are interested in is here:
```
private int bx;       corresponds to  private int lastActiveTime;
private int by;                       private int timeSinceIgnited;
private int bz = 30;                  private int fuseTime = 30;
private int bA = 3;                   private int explosionRadius = 3;
private int bB;                       private int droppedSkulls;
```

That "3" is what we want to change.  It's a small value, and we want to change the "3" to a "1", so it would be reasonable to assume this is a one-byte change to the .class file.  It is indeed a one-byte change, but not perhaps in the way one would predict, and it would be both naive and mis-informed to start looking near the top of the .class file for "0x03" bytes.


### read the existing bytecode to understand the actual program flow

Here is where we can make good use of the Bytecode view of acs.class.  The JD-GUI view looks like normal .java source code, and we see things like `private int bA = 3;`.  In reality, operations such as assignment don't take place anywhere except inside of a function.  The code `bA = 3` is really shorthand for "during instantiation, assign bA the value of 3".  Instantiation, of course, takes place in the constructor, whose name, even though obfuscated, must match the class name.  And, indeed, we see a method `public acs(amu arg0)`.  Checking the MCP / Forge source code, we see that EntityCreeper does in fact have a 1-argument constructor (from which, by the way, we can conclude that the name `amu` is the obfuscated name for the World class).

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

In fact, they do correspond.  `acs a()` is clearly a call do `a()` within `acs`, and `(FF)V` indicates that two floats are passed.  This matches very well with `a(0.6F, 1.7F)`, an in-class call to `a()`, passing two Floats.  The `ldc` lines are clearly involved, because they provide the specific values of those Floats.  This all ties together by reading and understanding the **bytecode** that corresponds to these operations.  The Wikipedia references I included in Chapter 0x01 are very valuable for reading Java bytecode, and after doing it enough, one begins to be able to read it like any language one is familiar with.

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

Like with `ldc` and `invokevirtual`, `putfield` takes a reference to the constant pool; that's what the '23' and '25' are.  These each resolve to a distinct descriptor for a variable.  `putfield` pops from the stack the value pushed there by `bipush` / `iconst_3`, storing it in the indicated variable.

So, in order to change the "3" to a "1", we do indeed need to make a 1-byte change, ...  But we need to change the `06` for `iconst_3` to `04` for `iconst_1`.  That will push a '1' onto the stack, which `putfield` will pop and store in `acs.bA`.


### alter the bytecode

All files are "binary files", in the sense that all files are stored as bytes, each byte made up of 8 bits, each bit having 2 possible values.  But, colloquially, we make a distinction between "plain-text" files and "binary" files.  Text editors such as `vi`, `emacs`, the editor in most IDEs, and so forth deal just fine with plain-text files, because source code is generally written in plain text.  Executable files, on the other hand, are so-called binary files, which really just means that the bytes that comprise them aren't meant for human consumption.  This is all for good reason, of course: low-level instructions encoded as opcodes emphasizes storage and execution efficiency, and high-level instructions encoded as human-language words and syntax emphasizes developer/development efficiency.

Java .class files of course are in the low-level, "binary" camp, so to edit them, we need to bridge the gap between plain-text editing and binary files.  There are a number of ways to do this.  I chose a method that focuses on being universal and scriptable (at least in part).  The method I present here has these basic steps:

1. dump the .class file to a plain-text representation of its bytes
1. use an ordinary text editor to search for the bytes to be edited
1. use an ordinary text editor to modify the (representation of) those bytes
1. transform the plain-text representation back into actual bytes as a new .class file

The Linux utility `xxd` is the workhorse here.  It translates a file's actual bytes into various textual representations of those bytes.  (Just in case it's not clear, by "textual representation" I simply mean the difference we see between a byte whose value is '0', and the byte for representing the character '0', a byte with a decimal value of '48'.)  We'll use hexadecimal representation, because the other tools and references we are using deal with Java bytecodes in terms of their hexadecimal values.  Of course, a file's byte values can be represented in any base -- they are just numbers.  But hexadecimal is a very common and very handy encoding for byte values.

The full set of steps I use includes some steps to make safety copies, and to make copies we can use for `diff` comparisons.

Here are the steps for nerfing creeprs, based on what we found above:
```
cd ~/hmcb/craftingtable/chapter-02-weakened-creepers/

## make some safety and comparison copies
cp  -ip        acs.class      /tmp/acs.class.orig
xxd -p         acs.class  - > /tmp/acs.class.orig--xxd

## copy the original to a new file we will edit
cp  -ip                       /tmp/acs.class.orig--xxd  /tmp/acs.class.next--xxd

## use the text editor of your choice, tho I don't know why anyone would choose anything other than vi ...
vi        /tmp/acs.class.next--xxd

## search for the bytes that encode the logic you want to change;
## in this case, those bytes are : 2a 10 1e b5 00 17 2a 06 b5 00 19
## in vi, '/' is the search command, so:
/2a101eb500172a06b50019
## ... except that the bytes we want might cross a line-wrapping boundary,
## so it might be necessary to do partial searches; in this case:
/2a101eb50017
## does the trick; confirm this by looking at the start of the next line
## for the rest of the target string of bytes

##
## !!! also always search repeatedly for the target string of bytes !!!
## by chance, the same bytes might occur elsewhere, too, and you don't
## want to edit the wrong set of bytes!
##

## position the cursor over the '06', and change it to an '04', resulting in:
2a101eb500172a04b50019

## save-and-quit out of your editor, then turn the edited bytes back into a 'binary' file
xxd -p -r /tmp/acs.class.next--xxd - > /tmp/acs.class.next

## here we can run some diffs to see the effect of our edit
diff /tmp/acs.class.orig--xxd    /tmp/acs.class.next--xxd
diff <(od -A x -t x1 acs.class)  <(od -A x -t x1 /tmp/acs.class.next)

## finally, copy the edited .class file into place, overwriting the original
cp -ip  /tmp/acs.class.next  acs.class
```


### repackage the Minecraft .jar file


