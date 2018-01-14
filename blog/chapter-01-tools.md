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

My first go at it was classic mod'ing, using MPC / Forge.  This was sucessful, but cumbersome.  The mod'ing hook felt heavy to me, particularly because I wanted to make such a small change.  So I switched back to contemplating altering the engine code itself.

### Hexxing

Any executale is, of course, just a file, and a file is just a bunch of bytes.  There is nothing magical about software.  A program is a set of instructions to be fed to the CPU.  Working exclusively in high-level languages like C, Java, Perl, and Ruby can distance one from what's really going on inside the CPU, and a realization or a reminder of how `print("Hello world!")` actually puts the characters `H-e-l-l-o- -W-o-r-l-d-!` on the screen can close that distance, de-mystify the software, and deepen one's understanding of programming.

More specifically, any executable program is a series of op-codes meaningful to the CPU on which it is targetted to run, and compilation is the process of turning source code into op-codes.  This is equally true whether the source code is compiled once ahead of time, compiled just-in-time (JiT) as with 'scripting' languages, or interpreted by an interpreter.  And, it turns out, the same motif applies to compile-once-run-anywhere (CORA) languages like Java.  Java and all widely-used CORA languages compile to bytecodes, which look, feel, and operate just like opcodes.  The run-time environment (e.g., the JVM) translates the (universal) bytecodes into (CPU architecture-specific) opcodes, a task made more practical by having a bytecode language exceedingly similar to opcode language.

So, altering the behavior of a Java program is simply a matter of altering the bytecodes that make up its .class files.

... "simple" being determined, of course, by how extensive is the alteration you want to make.  In the course of this blog series, we will go from a simple, single-byte alteration to adding a new method to the Java class file.

### Method of Operation

The general method of operation I employed for these hacks ended up being something like this:

1. unpack the Minecraft .jar file
1. find the class file or files involved in the logic I wanted to change (primarily using the MPC source code)
1. find the area within the appropriate class file(s) where that logic resides (using a decompiled view of those class file(s))
1. read the existing bytecode to understand the actual program flow (which can differ from the MPC sources, for various reasons)
1. determine the bytecode changes that will implement the desired logic change
1. alter the bytecode (dump the class file to text-hex, edit, and reconstitute into binary)
1. repackage the Minecraft .jar file

The tools I used for this include:

1. commonly-available general-purpose Linux command-line utilities, such as find, grep, sed, and so forth
1. xxd, a Linux commmand-line utility for hex editing of so-called binary files
1. the MPC / Forge sources []
1. tech specs / references
  * https://en.wikipedia.org/wiki/Java_bytecode_instruction_listings
  * https://en.wikipedia.org/wiki/Java_class_file
  * https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html
1. numeric converters:
  * http://www.binaryhexconverter.com/decimal-to-hex-converter
  * http://www.binaryhexconverter.com/ascii-text-to-hex-converter
  * http://www.exploringbinary.com/floating-point-converter/
1. BytecodeViewer []
1. jd-gui []
1. jboss-javassist []
1. a Perl program I wrote to improve upon javassist

Quite naturally, after a couple of iterations while getting the process worked out, I wrote a shell script to simplify repeated steps.  And by "simplify", I mean make it so I stopped making typos and inadvertently skipping steps.  In other words, I made the process repeatable, which is a part of any good SDLC.  So mentally add the (what I think of as implicit) "shell scripting" to the above set of tools.  Of course, other forms of scripting are available, and you should use whatever scripting you find most suitable to you, your skills, and the task at hand.

### Craft Your Craftingtable

One of the first things to do in Minecraft is to craft your craftingtable.  One of the first things we need to do is set up an area where we have the proper tools available.  Here are the steps to do that:

1. make a working area
  * cd ~
  * cd [whatever folder structure you use for project organization]
  * mkdir minecraft
  * cd minecraft
  * mkdir archive
  * mkdir craftingtable
  * mkdir xtra
1. download and unpackage the MPC sources
  * ...
  * ...
  * ...
1. download and stash third-party tools
  * ...
  * ...
  * ...
1. set browser bookmarks for pages you will refer to often
  * https://en.wikipedia.org/wiki/Java_bytecode_instruction_listings
  * https://en.wikipedia.org/wiki/Java_class_file
  * https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html
  * http://www.binaryhexconverter.com/decimal-to-hex-converter
  * http://www.binaryhexconverter.com/ascii-text-to-hex-converter
  * http://www.exploringbinary.com/floating-point-converter/


When you are ready, proceed to [Chapter 0x02 -- Weakened Creepers](/hexcraft/blog/chapter-02-weakend-creepers.html).