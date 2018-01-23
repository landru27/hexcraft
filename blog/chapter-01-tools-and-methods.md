# Hacking Minecraft

## Chapter 0x01 - Tools and Methods

### How I Learned to Loath the Creeper-Bomb

Those pesky creepers!

I find Minecraft's creepers annoying, and unbalanced.  If you happen to stay up just a little past sundown, the next morning you can be minding your own business, tending your garden or breeding your livestock ... and ssss-BOOM! a creeper, unannounced (they creep, after all) explodes right behind you, and you are dead.  Likely, your crops, or fence, or cow, or all three, are gone, too.  Or, occupied by fighting another mob who has your full attention because, well, it's trying to kill you, the same thing can happen.  There are certainly in-game ways around this, and some people play Minecraft for it's combat-oriented challenges.  But for me, I play Survival for the foothold-and-sustainability challenge.

But, those pesky creepers!

So, programmer that I am, I got to thinking: I wonder how the explosive power of a creeper is controlled?  There are other things that explode, such as TNT and ghast fireballs, and charged creepers are even more explosive, so it would only be natural for the game engine to have a general explosion functionality, with inputs for the size / power of the explosion.

... And if that's the case, then the definition of a creeper must supply some value to that general functionality.

... And if that's the case, then that definition could be changed to make creepers **less** powerful.

... And if I could locate that spot in the code, then I could change it, and not worry nearly so much about those damn pesky creepers!

Thus, I set about my first attempt at hacking Minecraft.

My first go at it was classic mod'ing, using Forge.  This was sucessful, but cumbersome.  The mod'ing hook felt heavy to me, particularly because I wanted to make such a small change.  So I switched back to contemplating altering the engine code itself.


### hexxing

Any executale is, of course, just a file, and a file is just a bunch of bytes.  There is nothing magical about software.  A program is a set of instructions to be fed to the CPU.  Working exclusively in high-level languages like C, Java, Perl, and Ruby can distance one from what's really going on inside the CPU, and a realization or a reminder of how `print("Hello world!")` actually puts the characters `H-e-l-l-o- -W-o-r-l-d-!` on the screen can close that distance, de-mystify the software, and deepen one's understanding of programming.

More specifically, any executable program is a series of op-codes meaningful to the CPU on which it is targetted to run, and compilation is the process of turning source code into op-codes.  This is equally true whether the source code is compiled once ahead of time, compiled just-in-time (JiT) as with 'scripting' languages, or interpreted by an interpreter.  And, it turns out, the same motif applies to compile-once-run-anywhere (CORA) languages like Java.  Java and all widely-used CORA languages compile to bytecodes, which look, feel, and operate just like opcodes.  The run-time environment (e.g., the JVM) translates the (universal) bytecodes into (CPU architecture-specific) opcodes, a task made more practical by having a bytecode language exceedingly similar to opcode language.

So, altering the behavior of a Java program is simply a matter of altering the bytecodes that make up its .class files.

... "simple" being determined, of course, by how extensive is the alteration you want to make.  In the course of this blog series, we will go from a simple, single-byte alteration to adding a new method to the Java class file.


### method of procedure

When I began this hacking project, Minecraft v1.11.2 was the current version, and that's what I used throughout.  For this series, I will be working with Minecraft v1.12.2.  I am confident that the concepts and approaches used here will continue to apply for v1.13, or really any version written in Java.

The general method of operation I employed for these hacks ended up being something like this:

1. unpack the Minecraft .jar file
1. find the class file or files involved in the logic I wanted to change (primarily using the MCP / Forge source code)
1. find the area within the appropriate class file(s) where that logic resides (using a decompiled view of those class file(s))
1. read the existing bytecode to understand the actual program flow (which can differ from the MCP / Forge sources, for various reasons)
1. determine the bytecode changes that will implement the desired logic change
1. alter the bytecode (dump the class file to text-hex, edit, and reconstitute into binary)
1. repackage the Minecraft .jar file

The tools I used for this include:

1. commonly-available general-purpose Linux command-line utilities, such as find, grep, sed, and so forth
1. xxd, a Linux commmand-line utility for hex editing of so-called binary files
1. the MCP / Forge sources : [MDK for v1.12.2](https://files.minecraftforge.net/maven/net/minecraftforge/forge/index_1.12.2.html) -- (1.12.2-14.23.1.2555)
1. [BytecodeViewer](https://bytecodeviewer.com/) -- (v2.9.8)
1. [jboss-javassist](http://jboss-javassist.github.io/javassist/) -- (v3.22.0 (GA))
1. [a Perl program](https://github.com/landru27/hexcraft/tree/master/utils) I wrote to improve upon javap
1. [a Java program](https://github.com/landru27/hexcraft/tree/master/utils) I wrote to re-write a class method's stack map
1. tech specs / references
  * [Wikipedia - Java bytecode instruction listings](https://en.wikipedia.org/wiki/Java_bytecode_instruction_listings)
  * [Wikipedia - Java class file](https://en.wikipedia.org/wiki/Java_class_file)
  * [Oracle Java spec - Chapter 4. The class File Format](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html)
1. numeric converters:
  * [Decimal to Hexadecimal Converter](http://www.binaryhexconverter.com/decimal-to-hex-converter)
  * [Ascii Text to Hexadecimal Converter](http://www.binaryhexconverter.com/ascii-text-to-hex-converter)
  * [Decimal to Floating-Point Converter](http://www.exploringbinary.com/floating-point-converter)
1. shell scripting
  * to make the process consistent and repeatable; could be any suitable form of scripting, but shell is my bailiwick


### craft your craftingtable

One of the first things to do in Minecraft is to craft your craftingtable.  One of the first things we need to do is set up an area where we have the proper tools available.  Below are the steps to do that.  These steps set things up in your home directory (~), but of course you should adapt that to suit your needs.

1. make a working area
  * `mkdir ~/hmcb/`  (short for 'hacking-minecraft-blog', but use whatever makes sense to you)
  * `cd ~/hmcb/`
  * `mkdir tmp/`
  * `mkdir archive/`
  * `mkdir craftingtable/`
  * `mkdir forge/`
  * `mkdir util/`
1. clone this repo into the working area
  * `cd ~/hmcb/`
  * `git clone git@github.com:landru27/hexcraft.git`
1. download the installation files from the above list of tools; save them into `~/hmcb/tmp/`
  * forge-1.12.2-14.23.1.2555-mdk.zip
  * BytecodeViewer.2.9.8.zip
  * javassist-3.22.0-GA.zip
1. go through the installation process for each tool
   1. Forge
      * `cd ~/hmcb/forge/`
      * `unzip ../tmp/forge-1.12.2-14.23.1.2555-mdk.zip`
      * `mkdir modding/`
      * `mv -i build.gradle  gradlew.bat gradlew gradle modding/`
      * `cd modding/`
      * `./gradlew setupDecompWorkspace`
        * from [Getting Started with Forge](http://mcforge.readthedocs.io/en/latest/gettingstarted/) : "This will download a bunch of artifacts from the internet needed to decompile and build Minecraft and forge. This might take some time, as it will download stuff and then decompile Minecraft."
        * gradle has a caching mechanism, so if you want/need to redo this step, you can `mv -i ~/.gradle/caches/ ~/.gradle/caches.prev.001` or similar
      * when this is done, the .java source files for the Forge derivative of Minecraft will be in `~/hmcb/forge/modding/build/tmp/recompileMc/sources/net/minecraft/`
   1. BytecodeViewer
      * `cd ~/hmcb/tmp/`
      * `mkdir bytecodeviewer/`
      * `cd bytecodeviewer/`
      * `unzip ../BytecodeViewer.2.9.8.zip`
      * `cp -ip 'BytecodeViewer 2.9.8.jar' ../../util/BytecodeViewer_2.9.8.jar`
      * `cd ~/hmcb/`
      * `java -jar util/BytecodeViewer_2.9.8.jar`
        * the first run will download a number of dependencies; subsequent runs are much faster
   1. JavaAssist
      * `cd ~/hmcb/tmp/`
      * `unzip javassist-3.22.0-GA.zip`
      * `cp -ip javassist-3.22.0-GA/javassist.jar ../util/`
   1. hexcraft utilities
      * `cd ~/hmcb/`
      * `cp -ip hexcraft/utils/javap.pl util/`
      * `cp -ip hexcraft/utils/ReadWriteClass.java util/`
1. set browser bookmarks for the tech specs, references, and numeric converters listed above


### next chapter

When you are ready, proceed to [Chapter 0x02 -- Weakened Creepers](/hexcraft/blog/chapter-02-weakened-creepers.html).
