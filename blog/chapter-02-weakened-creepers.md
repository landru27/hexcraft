# Hacking Minecraft

## Chapter 0x02 - Weakened Creepers

### Intro

Now we start the actual hacking.

For this first hack, I will proceed through the steps in some detail.  Later chapters will summarize routine steps; refer back to this chapter if you need a reminder on the associated details.


### unpack the Minecraft .jar file



### find the class file or files involved in the logic I wanted to change (primarily using the MPC source code)



### find the area within the appropriate class file(s) where that logic resides (using a decompiled view of those class file(s))



### read the existing bytecode to understand the actual program flow (which can differ from the MPC sources, for various reasons)



### determine the bytecode changes that will implement the desired logic change



### alter the bytecode (dump the class file to text-hex, edit, and reconstitute into binary)



### repackage the Minecraft .jar file



