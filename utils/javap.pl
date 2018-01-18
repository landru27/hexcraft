#!/usr/bin/perl


$| = 1;

use strict;
use IO::File;
use Data::Dumper;


use constant T_BOOLEAN           => 4;
use constant T_CHAR              => 5;
use constant T_FLOAT             => 6;
use constant T_DOUBLE            => 7;
use constant T_BYTE              => 8;
use constant T_SHORT             => 9;
use constant T_INT               => 10;
use constant T_LONG              => 11;
use constant T_VOID              => 12;
use constant T_ARRAY             => 13;
use constant T_OBJECT            => 14;
use constant T_REFERENCE         => 14;
use constant T_UNKNOWN           => 15;
use constant T_ADDRESS           => 16;

use constant Utf8                => 1;
use constant Integer             => 3;
use constant Float               => 4;
use constant Long                => 5;
use constant Double              => 6;
use constant Class               => 7;
use constant Fieldref            => 9;
use constant String              => 8;
use constant Methodref           => 10;
use constant InterfaceMethodref  => 11;
use constant NameAndType         => 12;

use constant ACC_PUBLIC          => 0x0001;
use constant ACC_PRIVATE         => 0x0002;
use constant ACC_PROTECTED       => 0x0004;
use constant ACC_STATIC          => 0x0008;

use constant ACC_FINAL           => 0x0010;
use constant ACC_SYNCHRONIZED    => 0x0020;
use constant ACC_VOLATILE        => 0x0040;
use constant ACC_TRANSIENT       => 0x0080;

use constant ACC_NATIVE          => 0x0100;
use constant ACC_INTERFACE       => 0x0200;
use constant ACC_ABSTRACT        => 0x0400;
use constant ACC_STRICT          => 0x0800;

use constant ACC_SUPER           => 0x0020;
use constant MAX_ACC_FLAG        => ACC_ABSTRACT;
my @CLASSACCESS;
$CLASSACCESS[0] = "public";
$CLASSACCESS[3] = "final";
$CLASSACCESS[5] = "super";
$CLASSACCESS[8] = "interface";
$CLASSACCESS[9] = "abstract";

my @METHODACCESS;
$METHODACCESS[0] = "public";
$METHODACCESS[1] = "private";
$METHODACCESS[2] = "protected";
$METHODACCESS[3] = "static";
$METHODACCESS[4] = "final";
$METHODACCESS[5] = "synchronized";
$METHODACCESS[7] = "native";
$METHODACCESS[9] = "abstract";
$METHODACCESS[10] = "strict";

my @ACCESS = (
    "public", "private", "protected", "static", "final", "synchronized",
    "volatile", "transient", "native", "interface", "abstract");

my %ops = (
  0 => {
             name => 'nop',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 0,
             type => 'noargs',
  },
  1 => {
             name => 'aconst_null',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'n',
             type => 'noargs',
  },
  2 => {
             name => 'iconst_m1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => '-',
             type => 'noargs',
  },
  3 => {
             name => 'iconst_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  4 => {
             name => 'iconst_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  5 => {
             name => 'iconst_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  6 => {
             name => 'iconst_3',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  7 => {
             name => 'iconst_4',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  8 => {
             name => 'iconst_5',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  9 => {
             name => 'lconst_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 2,
             type => 'noargs',
  },
  10 => {
             name => 'lconst_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 2,
             type => 'noargs',
  },
  11 => {
             name => 'fconst_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  12 => {
             name => 'fconst_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  13 => {
             name => 'fconst_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  14 => {
             name => 'dconst_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'D',
             type => 'noargs',
  },
  15 => {
             name => 'dconst_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'D',
             type => 'noargs',
  },
  16 => {
             name => 'bipush',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 'I',
             type => 'byte',
  },
  17 => {
             name => 'sipush',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 'I',
             type => 'int',
  },
  18 => {
             name => 'ldc',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 1,
             type => 'byteindex',
  },
  19 => {
             name => 'ldc_w',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 1,
             type => 'intindex',
  },
  20 => {
             name => 'ldc2_w',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 1,
             type => 'intindex',
  },
  21 => {
             name => 'iload',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 'I',
             type => 'bytevar',
  },
  22 => {
             name => 'lload',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 2,
             type => 'bytevar',
  },
  23 => {
             name => 'fload',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 'F',
             type => 'bytevar',
  },
  24 => {
             name => 'dload',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 'D',
             type => 'bytevar',
  },
  25 => {
             name => 'aload',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 'o',
             type => 'bytevar',
  },
  26 => {
             name => 'iload_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  27 => {
             name => 'iload_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  28 => {
             name => 'iload_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  29 => {
             name => 'iload_3',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'I',
             type => 'noargs',
  },
  30 => {
             name => 'lload_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 2,
             type => 'noargs',
  },
  31 => {
             name => 'lload_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 2,
             type => 'noargs',
  },
  32 => {
             name => 'lload_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 2,
             type => 'noargs',
  },
  33 => {
             name => 'lload_3',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 2,
             type => 'noargs',
  },
  34 => {
             name => 'fload_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  35 => {
             name => 'fload_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  36 => {
             name => 'fload_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  37 => {
             name => 'fload_3',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'F',
             type => 'noargs',
  },
  38 => {
             name => 'dload_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'D',
             type => 'noargs',
  },
  39 => {
             name => 'dload_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'D',
             type => 'noargs',
  },
  40 => {
             name => 'dload_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'D',
             type => 'noargs',
  },
  41 => {
             name => 'dload_3',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'D',
             type => 'noargs',
  },
  42 => {
             name => 'aload_0',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'o',
             type => 'noargs',
  },
  43 => {
             name => 'aload_1',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'o',
             type => 'noargs',
  },
  44 => {
             name => 'aload_2',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'o',
             type => 'noargs',
  },
  45 => {
             name => 'aload_3',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'o',
             type => 'noargs',
  },
  46 => {
             name => 'iaload',
         operands => 0,
    operand_types => [],
         consumed => 'oI',
         produced => 'I',
             type => 'noargs',
  },
  47 => {
             name => 'laload',
         operands => 0,
    operand_types => [],
         consumed => 'oI',
         produced => 'L',
             type => 'noargs',
  },
  48 => {
             name => 'faload',
         operands => 0,
    operand_types => [],
         consumed => 'oI',
         produced => 'F',
             type => 'noargs',
  },
  49 => {
             name => 'daload',
         operands => 0,
    operand_types => [],
         consumed => 'oI',
         produced => 'D',
             type => 'noargs',
  },
  50 => {
             name => 'aaload',
         operands => 0,
    operand_types => [],
         consumed => 'oI',
         produced => 'o',
             type => 'noargs',
  },
  51 => {
             name => 'baload',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 1,
             type => 'noargs',
  },
  52 => {
             name => 'caload',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 1,
             type => 'noargs',
  },
  53 => {
             name => 'saload',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 1,
             type => 'noargs',
  },
  54 => {
             name => 'istore',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 'I',
         produced => 0,
             type => 'bytevar',
  },
  55 => {
             name => 'lstore',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 'L',
         produced => 0,
             type => 'bytevar',
  },
  56 => {
             name => 'fstore',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 'F',
         produced => 0,
             type => 'bytevar',
  },
  57 => {
             name => 'dstore',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 'D',
         produced => 0,
             type => 'bytevar',
  },
  58 => {
             name => 'astore',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 'o',
         produced => 0,
             type => 'bytevar',
  },
  59 => {
             name => 'istore_0',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 0,
             type => 'noargs',
  },
  60 => {
             name => 'istore_1',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 0,
             type => 'noargs',
  },
  61 => {
             name => 'istore_2',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 0,
             type => 'noargs',
  },
  62 => {
             name => 'istore_3',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 0,
             type => 'noargs',
  },
  63 => {
             name => 'lstore_0',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 0,
             type => 'noargs',
  },
  64 => {
             name => 'lstore_1',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 0,
             type => 'noargs',
  },
  65 => {
             name => 'lstore_2',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 0,
             type => 'noargs',
  },
  66 => {
             name => 'lstore_3',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 0,
             type => 'noargs',
  },
  67 => {
             name => 'fstore_0',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 0,
             type => 'noargs',
  },
  68 => {
             name => 'fstore_1',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 0,
             type => 'noargs',
  },
  69 => {
             name => 'fstore_2',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 0,
             type => 'noargs',
  },
  70 => {
             name => 'fstore_3',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 0,
             type => 'noargs',
  },
  71 => {
             name => 'dstore_0',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 0,
             type => 'noargs',
  },
  72 => {
             name => 'dstore_1',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 0,
             type => 'noargs',
  },
  73 => {
             name => 'dstore_2',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 0,
             type => 'noargs',
  },
  74 => {
             name => 'dstore_3',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 0,
             type => 'noargs',
  },
  75 => {
             name => 'astore_0',
         operands => 0,
    operand_types => [],
         consumed => 'o',
         produced => 0,
             type => 'noargs',
  },
  76 => {
             name => 'astore_1',
         operands => 0,
    operand_types => [],
         consumed => 'o',
         produced => 0,
             type => 'noargs',
  },
  77 => {
             name => 'astore_2',
         operands => 0,
    operand_types => [],
         consumed => 'o',
         produced => 0,
             type => 'noargs',
  },
  78 => {
             name => 'astore_3',
         operands => 0,
    operand_types => [],
         consumed => 'o',
         produced => 0,
             type => 'noargs',
  },
  79 => {
             name => 'iastore',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 0,
             type => 'noargs',
  },
  80 => {
             name => 'lastore',
         operands => 0,
    operand_types => [],
         consumed => 4,
         produced => 0,
             type => 'noargs',
  },
  81 => {
             name => 'fastore',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 0,
             type => 'noargs',
  },
  82 => {
             name => 'dastore',
         operands => 0,
    operand_types => [],
         consumed => 4,
         produced => 0,
             type => 'noargs',
  },
  83 => {
             name => 'aastore',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 0,
             type => 'noargs',
  },
  84 => {
             name => 'bastore',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 0,
             type => 'noargs',
  },
  85 => {
             name => 'castore',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 0,
             type => 'noargs',
  },
  86 => {
             name => 'sastore',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 0,
             type => 'noargs',
  },
  87 => {
             name => 'pop',
         operands => 0,
    operand_types => [],
         consumed => 1,
         produced => 0,
             type => 'noargs',
  },
  88 => {
             name => 'pop2',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 0,
             type => 'noargs',
  },
  89 => {
             name => 'dup',
         operands => 0,
    operand_types => [],
         consumed => 1,
         produced => 2,
             type => 'noargs',
  },
  90 => {
             name => 'dup_x1',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 3,
             type => 'noargs',
  },
  91 => {
             name => 'dup_x2',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 4,
             type => 'noargs',
  },
  92 => {
             name => 'dup2',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 4,
             type => 'noargs',
  },
  93 => {
             name => 'dup2_x1',
         operands => 0,
    operand_types => [],
         consumed => 3,
         produced => 5,
             type => 'noargs',
  },
  94 => {
             name => 'dup2_x2',
         operands => 0,
    operand_types => [],
         consumed => 4,
         produced => 6,
             type => 'noargs',
  },
  95 => {
             name => 'swap',
         operands => 0,
    operand_types => [],
         consumed => 2,
         produced => 2,
             type => 'noargs',
  },
  96 => {
             name => 'iadd',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  97 => {
             name => 'ladd',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  98 => {
             name => 'fadd',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'F',
             type => 'noargs',
  },
  99 => {
             name => 'dadd',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'D',
             type => 'noargs',
  },
  100 => {
             name => 'isub',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  101 => {
             name => 'lsub',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  102 => {
             name => 'fsub',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'F',
             type => 'noargs',
  },
  103 => {
             name => 'dsub',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'D',
             type => 'noargs',
  },
  104 => {
             name => 'imul',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  105 => {
             name => 'lmul',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  106 => {
             name => 'fmul',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'F',
             type => 'noargs',
  },
  107 => {
             name => 'dmul',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'D',
             type => 'noargs',
  },
  108 => {
             name => 'idiv',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  109 => {
             name => 'ldiv',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  110 => {
             name => 'fdiv',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'F',
             type => 'noargs',
  },
  111 => {
             name => 'ddiv',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'D',
             type => 'noargs',
  },
  112 => {
             name => 'irem',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  113 => {
             name => 'lrem',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  114 => {
             name => 'frem',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'F',
             type => 'noargs',
  },
  115 => {
             name => 'drem',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'D',
             type => 'noargs',
  },
  116 => {
             name => 'ineg',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'I',
             type => 'noargs',
  },
  117 => {
             name => 'lneg',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 'L',
             type => 'noargs',
  },
  118 => {
             name => 'fneg',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 'F',
             type => 'noargs',
  },
  119 => {
             name => 'dneg',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 'D',
             type => 'noargs',
  },
  120 => {
             name => 'ishl',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  121 => {
             name => 'lshl',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  122 => {
             name => 'ishr',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  123 => {
             name => 'lshr',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  124 => {
             name => 'iushr',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  125 => {
             name => 'lushr',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  126 => {
             name => 'iand',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  127 => {
             name => 'land',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  128 => {
             name => 'ior',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  129 => {
             name => 'lor',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  130 => {
             name => 'ixor',
         operands => 0,
    operand_types => [],
         consumed => 'II',
         produced => 'I',
             type => 'noargs',
  },
  131 => {
             name => 'lxor',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'L',
             type => 'noargs',
  },
  132 => {
             name => 'iinc',
         operands => 2,
    operand_types => [T_BYTE, T_BYTE],
         consumed => 0,
         produced => 0,
             type => 'twobytes',
  },
  133 => {
             name => 'i2l',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'L',
             type => 'noargs',
  },
  134 => {
             name => 'i2f',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'F',
             type => 'noargs',
  },
  135 => {
             name => 'i2d',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'D',
             type => 'noargs',
  },
  136 => {
             name => 'l2i',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 'I',
             type => 'noargs',
  },
  137 => {
             name => 'l2f',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 'F',
             type => 'noargs',
  },
  138 => {
             name => 'l2d',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 'D',
             type => 'noargs',
  },
  139 => {
             name => 'f2i',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 'I',
             type => 'noargs',
  },
  140 => {
             name => 'f2l',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 'L',
             type => 'noargs',
  },
  141 => {
             name => 'f2d',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 'D',
             type => 'noargs',
  },
  142 => {
             name => 'd2i',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 'I',
             type => 'noargs',
  },
  143 => {
             name => 'd2l',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 'L',
             type => 'noargs',
  },
  144 => {
             name => 'd2f',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 'F',
             type => 'noargs',
  },
  145 => {
             name => 'i2b',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'B',
             type => 'noargs',
  },
  146 => {
             name => 'i2c',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'C',
             type => 'noargs',
  },
  147 => {
             name => 'i2s',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'S',
             type => 'noargs',
  },
  148 => {
             name => 'lcmp',
         operands => 0,
    operand_types => [],
         consumed => 'LL',
         produced => 'I',
             type => 'noargs',
  },
  149 => {
             name => 'fcmpl',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'I',
             type => 'noargs',
  },
  150 => {
             name => 'fcmpg',
         operands => 0,
    operand_types => [],
         consumed => 'FF',
         produced => 'I',
             type => 'noargs',
  },
  151 => {
             name => 'dcmpl',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'I',
             type => 'noargs',
  },
  152 => {
             name => 'dcmpg',
         operands => 0,
    operand_types => [],
         consumed => 'DD',
         produced => 'I',
             type => 'noargs',
  },
  153 => {
             name => 'ifeq',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intbranch',
  },
  154 => {
             name => 'ifne',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intbranch',
  },
  155 => {
             name => 'iflt',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intbranch',
  },
  156 => {
             name => 'ifge',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intbranch',
  },
  157 => {
             name => 'ifgt',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intbranch',
  },
  158 => {
             name => 'ifle',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intbranch',
  },
  159 => {
             name => 'if_icmpeq',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'II',
         produced => 0,
             type => 'intbranch',
  },
  160 => {
             name => 'if_icmpne',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'II',
         produced => 0,
             type => 'intbranch',
  },
  161 => {
             name => 'if_icmplt',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'II',
         produced => 0,
             type => 'intbranch',
  },
  162 => {
             name => 'if_icmpge',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'II',
         produced => 0,
             type => 'intbranch',
  },
  163 => {
             name => 'if_icmpgt',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'II',
         produced => 0,
             type => 'intbranch',
  },
  164 => {
             name => 'if_icmple',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'II',
         produced => 0,
             type => 'intbranch',
  },
  165 => {
             name => 'if_acmpeq',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 2,
         produced => 0,
             type => 'intbranch',
  },
  166 => {
             name => 'if_acmpne',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 2,
         produced => 0,
             type => 'intbranch',
  },
  167 => {
             name => 'goto',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 0,
             type => 'intbranch',
  },
  168 => {
             name => 'jsr',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 'A',
             type => 'intbranch',
  },
  169 => {
             name => 'ret',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 0,
         produced => 0,
             type => 'bytevar',
  },
  170 => {
             name => 'tableswitch',
         operands => undef,
    operand_types => [],
         consumed => 1,
         produced => 0,
             type => '',
  },
  171 => {
             name => 'lookupswitch',
         operands => undef,
    operand_types => [],
         consumed => 1,
         produced => 0,
             type => 'longbranch',
  },
  172 => {
             name => 'ireturn',
         operands => 0,
    operand_types => [],
         consumed => 'I',
         produced => 'R',
             type => 'noargs',
  },
  173 => {
             name => 'lreturn',
         operands => 0,
    operand_types => [],
         consumed => 'L',
         produced => 'R',
             type => 'noargs',
  },
  174 => {
             name => 'freturn',
         operands => 0,
    operand_types => [],
         consumed => 'F',
         produced => 'R',
             type => 'noargs',
  },
  175 => {
             name => 'dreturn',
         operands => 0,
    operand_types => [],
         consumed => 'D',
         produced => 'R',
             type => 'noargs',
  },
  176 => {
             name => 'areturn',
         operands => 0,
    operand_types => [],
         consumed => 'o',
         produced => 'R',
             type => 'noargs',
  },
  177 => {
             name => 'return',
         operands => 0,
    operand_types => [],
         consumed => 0,
         produced => 'R',
             type => 'noargs',
  },
  178 => {
             name => 'getstatic',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 1,
             type => 'intindex',
  },
  179 => {
             name => 'putstatic',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 0,
             type => 'intindex',
  },
  180 => {
             name => 'getfield',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 1,
         produced => 1,
             type => 'intindex',
  },
  181 => {
             name => 'putfield',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 2,
         produced => 0,
             type => 'intindex',
  },
  182 => {
             name => 'invokevirtual',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => undef,
         produced => 1,
             type => 'intindex',
  },
  183 => {
             name => 'invokespecial',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => undef,
         produced => 1,
             type => 'intindex',
  },
  184 => {
             name => 'invokestatic',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => undef,
         produced => 1,
             type => 'intindex',
  },
  185 => {
             name => 'invokeinterface',
         operands => 4,
    operand_types => [T_SHORT, T_BYTE, T_BYTE],
         consumed => undef,
         produced => 1,
             type => 'intindex',
  },
  187 => {
             name => 'new',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 0,
         produced => 'o',
             type => 'intindex',
  },
  188 => {
             name => 'newarray',
         operands => 1,
    operand_types => [T_BYTE],
         consumed => 1,
         produced => 1,
             type => 'byte',
  },
  189 => {
             name => 'anewarray',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'I',
         produced => 'o',
             type => 'intindex',
  },
  190 => {
             name => 'arraylength',
         operands => 0,
    operand_types => [],
         consumed => 'o',
         produced => 'I',
             type => 'noargs',
  },
  191 => {
             name => 'athrow',
         operands => 0,
    operand_types => [],
         consumed => 1,
         produced => 1,
             type => 'noargs',
  },
  192 => {
             name => 'checkcast',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'o',
         produced => 'o',
             type => 'intindex',
  },
  193 => {
             name => 'instanceof',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'o',
         produced => 'I',
             type => 'intindex',
  },
  194 => {
             name => 'monitorenter',
         operands => 0,
    operand_types => [],
         consumed => 1,
         produced => 0,
             type => 'noargs',
  },
  195 => {
             name => 'monitorexit',
         operands => 0,
    operand_types => [],
         consumed => 1,
         produced => 0,
             type => 'noargs',
  },
  196 => {
             name => 'wide',
         operands => undef,
    operand_types => [T_BYTE],
         consumed => 'var',
         produced => 'var',
             type => 'noargs',
  },
  197 => {
             name => 'multianewarray',
         operands => 3,
    operand_types => [T_SHORT, T_BYTE],
         consumed => 'var',
         produced => 1,
             type => 'intindex',
  },
  198 => {
             name => 'ifnull',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'o',
         produced => 0,
             type => 'intbranch',
  },
  199 => {
             name => 'ifnonnull',
         operands => 2,
    operand_types => [T_SHORT],
         consumed => 'o',
         produced => 0,
             type => 'intbranch',
  },
  200 => {
             name => 'goto_w',
         operands => 4,
    operand_types => [T_INT],
         consumed => 0,
         produced => 0,
             type => 'longbranch',
  },
  201 => {
             name => 'jsr_w',
         operands => 4,
    operand_types => [T_INT],
         consumed => 0,
         produced => 'A',
             type => 'longbranch',
  },
  202 => {
             name => 'breakpoint',
         operands => 0,
    operand_types => undef,
         consumed => 0,
         produced => 0,
             type => 'noargs',
  },
  254 => {
             name => 'impdep1',
         operands => undef,
    operand_types => undef,
         consumed => undef,
         produced => undef,
             type => '',
  },
  255 => {
             name => 'impdep2',
         operands => undef,
    operand_types => undef,
         consumed => undef,
         produced => undef,
             type => '',
  },
);


####  main

my $FH;
my $hex;
my $raw;
my $stk;

my $indx;
my $tick;
my $vstr;

my $bytecountfile = 0;
my $bytecountclas = 0;
my @bytecountattr = (0, 0, 0, 0);
my $attrdepth = 0;

my $magic;
my($minor, $major, $version, %industry);
my @constant_pool;
my($access_flags, $class, $superclass);
my $interfaces;
my $fields;
my $methods;
my $attributes;

my $constant_pool_count = -1;
my $interfaces_count = -1;
my $fields_count = -1;
my $method_count = -1;
my $attributes_count = -1;

my @constant_pool_str;


$FH = IO::File->new($ARGV[0]) or die("Couldn't read class " . $ARGV[0] . "!");
$hex = '';

$raw = 0;
$stk = 0;
if ($ARGV[1] eq 'RAW') { $raw = 1; shift; }
if ($ARGV[1] eq 'STK') { $stk = 1; shift; }


print(STDOUT "#### class header\n\n");
$magic = &read_u4();
$bytecountclas += 4;
die "Not Java class file!\n" unless ($magic eq 0xCAFEBABE);
printf(STDOUT "[%-16s]  %s  [%s]\n", 'Java magic numbr', &getHexStr(32), $magic);

$minor = &read_u2;
$major = &read_u2;
$bytecountclas += 4;
%industry = ( '45' => 'JDK 1.1',
              '46' => 'JDK 1.2',
              '47' => 'JDK 1.3',
              '48' => 'JDK 1.4',
              '49' => 'Java SE 5.0',
              '50' => 'Java SE 6.0',
              '51' => 'Java SE 7',
              '52' => 'Java SE 8',
              '53' => 'Java SE 9'
            );
printf(STDOUT "[%-16s]  %s  [%s.%s]\n", $industry{$major}, &getHexStr(32), $major, $minor);


print(STDOUT "\n#### constant pool\n\n");
$constant_pool_count = &read_u2;
$bytecountclas += 2;
printf(STDOUT "[%-16s]  %s  [%s]\n", 'count + 1', &getHexStr(32), $constant_pool_count);

for(my $index = 1; $index < $constant_pool_count; $index++) {
    my $type = &read_u1;
    $bytecountclas += 1;
    $hex .= ' ';

    if ($type == Methodref) {
      my $class_index = &read_u2;
      $bytecountclas += 2;
      $hex .= ' ';
      my $name_and_type_index = &read_u2;
      $bytecountclas += 2;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'methodref', 'values' => [$class_index, $name_and_type_index]};
    } elsif ($type == Fieldref) {
      my $class_index = &read_u2;
      $hex .= ' ';
      my $name_and_type_index = &read_u2;
      $bytecountclas += 4;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'fieldref', 'values' => [$class_index, $name_and_type_index]};
    } elsif ($type == InterfaceMethodref) {
      my $class_index = &read_u2;
      $hex .= ' ';
      my $name_and_type_index = &read_u2;
      $bytecountclas += 4;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'interfacemethodref', 'values' => [$class_index, $name_and_type_index]};
    } elsif ($type == Class) {
      my $name_index = &read_u2;
      $bytecountclas += 2;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'class', 'values' => [$name_index]};
    } elsif ($type == Utf8) {
      my $length = &read_u2;
      $bytecountclas += 2;
      $bytecountclas += $length;
      $hex .= ' ';
      my $string;
      foreach (1 .. $length) {
        my $byte = &read_u1;
        $string .= chr($byte);
      }
      $constant_pool[$index] = {'index' => $index, 'type' => 'utf8', 'values' => [$length, $string]};
    } elsif ($type == NameAndType) {
      my $name_index = &read_u2;
      $bytecountclas += 2;
      $hex .= ' ';
      my $descriptor_index = &read_u2;
      $bytecountclas += 2;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'nameandtype', 'values' => [$name_index, $descriptor_index]};
    } elsif ($type == String) {
      my $string_index = &read_u2;
      $bytecountclas += 2;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'string', 'values' => [$string_index]};
    } elsif ($type == Integer) {
      my $bytes = &read_u4;
      $bytecountclas += 4;
      $hex .= ' ';
      $constant_pool[$index] = {'index' => $index, 'type' => 'integer', 'values' => [$bytes]};
    } elsif ($type == Float) {
      my $bytes = &read_u4;
      $bytecountclas += 4;
      $hex .= ' ';
      my $float = &float_value($bytes);
      $constant_pool[$index] = {'index' => $index, 'type' => 'float', 'values' => [$float]};
    } elsif ($type == Long) {
      my $high_bytes = &read_u4;
      my $low_bytes = &read_u4;
      $bytecountclas += 8;
      my $long = &long_value($high_bytes, $low_bytes);
      $constant_pool[$index] = {'index' => $index, 'type' => 'long', 'values' => [$long]};
    } elsif ($type == Double) {
      my $double = &read_IEEE754Double;
      $bytecountclas += 8;
      $constant_pool[$index] = {'index' => $index, 'type' => 'double', 'values' => [$double]};
    } else {
      die "unknown constant type $type in pool!\n";
    }

  my $ref = $constant_pool[$index];
  my %hash = %$ref;

  my $vstr = join(', ', @{$hash{'values'}});
  if ($raw == 0 && length($vstr) > 32) { $vstr = substr($vstr, 0, 29) . '...'; }

  $constant_pool_str[$index] = sprintf("[ %7u / %04x ]  %s  [%-20s%-32s", $index, $index, &getHexStr(32), $hash{'type'}, $vstr);

  # JVM Specs: All 8-byte constants take up two entries in the constant_pool 
  # table of the class file. If a CONSTANT_Long_info or CONSTANT_Double_info 
  # structure is the item in the constant_pool table at index n, then the next 
  # usable item in the pool is located at index n+2. The constant_pool index 
  # n+1 must be valid but is considered unusable. (In retrospect, making 8-byte 
  # constants take two constant pool entries was a poor choice.)

  if (($type == Long) || ($type == Double)) {
    $constant_pool[++$index] = 0;
  }
}

# we use a second pass for output because there might be forward-references
# in the pool, so we need to have read the whole thing in order to translate
# such entries
for (my $index = 1; $index < $constant_pool_count; $index++) {
  next if (! defined($constant_pool_str[$index]));

  my $ref = $constant_pool[$index];
  my %hash = %$ref;
  my $vstr;

  printf(STDOUT $constant_pool_str[$index]);

  if ($hash{'type'} eq 'class') {
    $vstr  = '  [' . &lookup_class_name($index) . ']';
    print(STDOUT $vstr);
  } elsif ($hash{'type'} eq 'fieldref') {
    $vstr  = '  [' . &lookup_class_name(${$hash{'values'}}[0]);
    $vstr .= ' '   . &lookup_nameandtype(${$hash{'values'}}[1]) . ']';
    print(STDOUT $vstr);
  } elsif ($hash{'type'} eq 'string') {
    $vstr  = '  [' . &lookup_utf8(${$hash{'values'}}[0]) . ']';
    print(STDOUT $vstr);
  } elsif ($hash{'type'} eq 'methodref') {
    $vstr  = '  [' . &lookup_class_name(${$hash{'values'}}[0]);
    $vstr .= ' '   . &lookup_nameandtype(${$hash{'values'}}[1]) . ']';
    print(STDOUT $vstr);
  } elsif ($hash{'type'} eq 'interfacemethodref') {
    $vstr  = '  [' . &lookup_class_name(${$hash{'values'}}[0]);
    $vstr .= ' '   . &lookup_nameandtype(${$hash{'values'}}[1]) . ']';
    print(STDOUT $vstr);
  } elsif ($hash{'type'} eq 'nameandtype') {
    $vstr .= '  [' . &lookup_nameandtype($index) . ']';
    print(STDOUT $vstr);
  }

  print(STDOUT "]\n");
}

if ($bytecountfile != $bytecountclas) { die("bytecounts are off [after constants pool] [file, class: $bytecountfile, $bytecountclas]"); }


print(STDOUT "\n#### class info\n\n");
$access_flags = &read_u2;
$bytecountclas += 2;
if (($access_flags & ACC_INTERFACE) != 0) {
    $access_flags |= ACC_ABSTRACT;
}
if ((($access_flags & ACC_ABSTRACT) != 0) &&
    (($access_flags & ACC_FINAL)    != 0 )) {
  die("class can't be both final and abstract");
}

my @flags;
my $bits = reverse unpack("B*", pack ("c*", $access_flags));
foreach my $index (0 .. length($bits)) {
  push @flags, $CLASSACCESS[$index] if substr($bits, $index, 1);
}
$vstr = 'access flags: ' . join(', ', @flags);

$indx = &read_u2;
$vstr .= '; this class: ' . &lookup_class_name($indx);

$indx = &read_u2;
$vstr .= '; super class: ' . &lookup_class_name($indx);
printf(STDOUT "[%-16s]  %s  [%s]\n", '', &getHexStr(), $vstr);
$bytecountclas += 4;


print(STDOUT "\n#### interfaces\n\n");
$interfaces_count = &read_u2;
$bytecountclas += 2;
$bytecountclas += ($interfaces_count * 2);
printf(STDOUT "[%-16s]  %s  [%s]\n", 'count', &getHexStr(), $interfaces_count);

foreach (1 .. $interfaces_count) {
  $indx = &read_u2;
  $vstr = &lookup_class_name($indx);
  printf(STDOUT "[%-16s]  %s  [%s]\n", 'iface name', &getHexStr(), $vstr);
}

if ($bytecountfile != $bytecountclas) { die("bytecounts are off [after interfaces] [file, class: $bytecountfile, $bytecountclas]"); }


print(STDOUT "\n#### fields\n\n");
$fields_count = &read_u2;
$bytecountclas += 2;
$bytecountclas += ($fields_count * 4);
printf(STDOUT "[%-16s]  %s  [%s]\n", 'count', &getHexStr(), $fields_count);

foreach $tick (1 .. $fields_count) {
  $vstr = 'access flags: ' . join(', ', &read_access_flags());

  $indx = &read_u2;
  $vstr .= '; name: ' . &lookup_utf8($indx);
  $indx = &read_u2;
  $vstr .= '; descriptor: ' . &lookup_utf8($indx);
  printf(STDOUT "[    % 8u    ]  %s  [%s]\n", $tick, &getHexStr(), $vstr);

  &read_attributes();
}

if ($bytecountfile != $bytecountclas) { die("bytecounts are off [after fields] [file, class: $bytecountfile, $bytecountclas]"); }


print(STDOUT "\n#### methods\n\n");
$method_count = &read_u2;
printf(STDOUT "[%-16s]  %s  [%s]\n", 'count', &getHexStr(), $method_count);

foreach $tick (1 .. $method_count) {
  $vstr = 'access flags: ' . join(', ', &read_access_flags());

  $indx = &read_u2;
  $vstr .= '; name: ' . &lookup_utf8($indx);
  $indx = &read_u2;
  $vstr .= '; descriptor: ' . &lookup_utf8($indx);
  printf(STDOUT "[    % 8u    ]  %s  [%s]\n", $tick, &getHexStr(), $vstr);
  $hex = '';

  &read_attributes();
}


print(STDOUT "\n#### class attributes\n\n");
&read_attributes();


my $junk = 0;
if (! $FH->eof) {
    $junk = 1;

    while (! $FH->eof) {
      my $byte = &read_u1();
    }
    my $r = $raw;
    $raw = 1;
    printf(STDOUT "[%-16s]  %s  [unknown]\n", 'junk raw bytes', &getHexStr());
    $raw = $r;
}

die "junk at end of file!\n" if $junk;
$FH->close;


#print(STDERR "done parsing class file $ARGV[0]\n");
exit(0);



#### subroutines

sub read_u1 {
  my $fh = $FH;
  local $/ = \1;
  my $byte;
  my $int = 0;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;

  $bytecountfile += 1;
  $bytecountattr[$attrdepth] += 1;

  return $int;
}

sub read_u2 {
  my $fh = $FH;
  local $/ = \1;
  my $byte;
  my $int = 0;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;
  $int *= 256;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;

  $bytecountfile += 2;
  $bytecountattr[$attrdepth] += 2;

  return $int;
}

sub read_u4 {
  my $fh = $FH;
  local $/ = \1;
  my $byte;
  my $int = 0;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;
  $int *= 256;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;
  $int *= 256;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;
  $int *= 256;

  $byte = unpack('C', <$fh>);
  $hex .= sprintf('%02x', $byte);
  $int += $byte;

  $bytecountfile += 4;
  $bytecountattr[$attrdepth] += 4;

  return $int;
}

sub read_IEEE754Double {
  my $fh = $FH;
  local $/ = \1;
  my $byte;
  my $dbl = 0;
  my $dblhex = '';

  $dblhex  = unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $dblhex .= unpack('H2', <$fh>);
  $hex .= $dblhex;

  my $dbl = unpack('d', reverse(pack('H*', $dblhex)));

  $bytecountfile += 8;
  $bytecountattr[$attrdepth] += 8;

  return $dbl;
}

# JVM Long format is ((long) high_bytes << 32) + low_bytes 
sub long_value {
  my ($high_bytes, $low_bytes) = @_;

  return ($high_bytes << 32) + $low_bytes;
}

# JVM Float format is IEEE 754 floating-point single-precision format
sub float_value {
  my ($bits) = @_;

  my $s = (($bits >> 31) == 0) ? 1 : -1;
  my $e = (($bits >> 23) & 0xff);
  my $m = ($e == 0) ? ($bits & 0x7fffff) << 1 : ($bits & 0x7fffff) | 0x800000;

  return $s * $m * (2 ** ($e - 150));
}

# JVM Float format is IEEE 754 floating-point double-precision format
sub double_value {
}

sub getHexStr {
  my $wdth = $_[0];
  my $rtrn = '';

  if (! defined($wdth)) { $wdth = 16; }

  $rtrn = sprintf('%-' . $wdth . 's', $hex);
  if ($raw == 0 && length($hex) > $wdth) { $rtrn = substr($hex, 0, ($wdth - 3)) . '...'; }
  $hex = '';

  return $rtrn
}

sub lookup_utf8 {
  my $index = $_[0];

  my $ref = $constant_pool[$index];
  my %hash = %$ref;
  my $type = $hash{'type'};
  my $valu;

  die('lookup_utf8 : index found is not a UTF8 [' . $index . ', ' . $type . ']') unless ($type eq 'utf8');
  $valu = ${$hash{'values'}}[1];

  return $valu;
}

sub lookup_string {
  my $index = $_[0];

  my $ref = $constant_pool[$index];
  my %hash = %$ref;
  my $type = $hash{'type'};
  my $valu;

  die('lookup_string : index found is not a string') unless ($type eq 'string');
  $valu = ${$hash{'values'}}[0];

  return &lookup_utf8($valu);
}

sub lookup_class_name {
  my $index = $_[0];

  my $ref = $constant_pool[$index];
  my %hash = %$ref;
  my $type = $hash{'type'};
  my $valu;

  die("lookup_class_name : index arg is not a class [$index]") unless ($type eq 'class');
  $valu = ${$hash{'values'}}[0];

  return &lookup_utf8($valu);
}

sub lookup_nameandtype {
  my $index = $_[0];

  my $ref = $constant_pool[$index];
  my %hash = %$ref;
  my $type = $hash{'type'};
  my $valuA;
  my $valuB;

  die('lookup_nameandtype : index arg is not a class') unless ($type eq 'nameandtype');
  $valuA = ${$hash{'values'}}[0];
  $valuB = ${$hash{'values'}}[1];

  return (&lookup_utf8($valuA) . ', ' . &lookup_utf8($valuB));
}

sub read_access_flags {
  my $access_flags = &read_u2;
  $bytecountclas += 2;
  my @flags;

  my $bits = reverse unpack("B*", pack ("c*", $access_flags));
    foreach my $index (0..length($bits)) {
      push @flags, $METHODACCESS[$index] if substr($bits, $index, 1);
    }

  return @flags;
}

sub read_attributes {

  my $attribute_count = &read_u2;
  $bytecountclas += 2;
  printf(STDOUT "[%-16s]  %s  [%s]\n", 'attribute count', &getHexStr(), $attribute_count);

  foreach (1 .. $attribute_count) {
    &read_attribute();
  }

  print(STDOUT "\n");
}

sub read_attribute {

  my $attribute_name_index = &read_u2();
  my $attribute_name = &lookup_utf8($attribute_name_index);
  my $attribute_length = &read_u4();
  $bytecountclas += 6;
  $bytecountclas += $attribute_length;
  $attrdepth++;
  $bytecountattr[$attrdepth] = 0;

  printf(STDOUT "[%-16s]  %s  [%s, %u]\n", 'attr name, len', &getHexStr(), $attribute_name, $attribute_length);

  if ($attribute_name eq 'Code') {
    my $max_stack = &read_u2;
    $vstr = 'max stack: ' . $max_stack;
    my $max_locals = &read_u2;
    $vstr .= '; max locals: ' . $max_locals;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'method info', &getHexStr(), $vstr);

    my $code_length = &read_u4;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'method size', &getHexStr(), $code_length);

    &read_code($code_length);

    my $exception_table_length = &read_u2;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'excptn tbl len', &getHexStr(), $exception_table_length);

    foreach (1 .. $exception_table_length) {
      my $start_pc = &read_u2; 
      my $end_pc = &read_u2;
      my $handler_pc = &read_u2;
      my $catch_type_index = &read_u2;

      my $catch_type = $catch_type_index ? &lookup_class_name($catch_type_index) : "*";
      $vstr = "$start_pc, $end_pc, $handler_pc, $catch_type_index, $catch_type";
      printf(STDOUT "[%-16s]  %s  [%s]\n", 'exception info', &getHexStr(), $vstr);
    }
    print(STDOUT "\n");
      
    &read_attributes();
  } elsif ($attribute_name eq 'LineNumberTable') {
    my $line_number_table_length = &read_u2;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'table length', &getHexStr(), $line_number_table_length);

    foreach (0..$line_number_table_length-1) {
      my $start_pc = &read_u2;
      my $line_number = &read_u2;
      $vstr = "$start_pc, $line_number";
      printf(STDOUT "[%-16s]  %s  [%s]\n", 'line nmbr info', &getHexStr(), $vstr);
    }
  } elsif ($attribute_name eq 'LocalVariableTypeTable') {
    my $local_variable_type_table_length = &read_u2;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'table length', &getHexStr(24), $local_variable_type_table_length);

    foreach (1 .. $local_variable_type_table_length) {
      my $start_pc = &read_u2;
      my $length = &read_u2;
      $indx = &read_u2;
      my $name = &lookup_utf8($indx);
      $indx = &read_u2;
      my $signature = &lookup_utf8($indx);
      my $index = &read_u2;
      $vstr = "$start_pc, $length, $name, $signature, $index";
      printf(STDOUT "[%-16s]  %s  [%s]\n", 'var type info', &getHexStr(24), $vstr);
    }
  } elsif ($attribute_name eq 'LocalVariableTable') {
    my $local_variable_table_length = &read_u2;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'table length', &getHexStr(24), $local_variable_table_length);

    foreach (1 .. $local_variable_table_length) {
      my $start_pc = &read_u2;
      my $length = &read_u2;
      $indx = &read_u2;
      my $name = &lookup_utf8($indx);
      $indx = &read_u2;
      my $descriptor = &lookup_utf8($indx);
      my $index = &read_u2;
      $vstr = "$start_pc, $length, $name, $descriptor, $index";
      printf(STDOUT "[%-16s]  %s  [%s]\n", 'var tbl info', &getHexStr(24), $vstr);
    }
  } elsif ($attribute_name eq 'SourceFile') {
    my $sourcefile_index = &read_u2;
    my $sourcefile_name = &lookup_utf8($sourcefile_index);

    printf(STDOUT "[%-16s]  %s  [%s]\n", 'name', &getHexStr(), $sourcefile_name);
  } elsif ($attribute_name eq 'Signature') {
    my $signature_index = &read_u2;
    my $signature_name = &lookup_utf8($signature_index);

    printf(STDOUT "[%-16s]  %s  [%s]\n", 'name', &getHexStr(), $signature_name);
  } elsif ($attribute_name eq 'StackMapTable') {
    my $stack_map_table_length = &read_u2;
    printf(STDOUT "[%-16s]  %s  [%s]\n", 'table length', &getHexStr(24), $stack_map_table_length);

    my $offset_total = 0;
    foreach (1 .. $stack_map_table_length) {
      my $frame_type = &read_u1; 
      my $frame_desc = 'unknown';
      my $offset_delta = 0;
      my $number_of_locals = 0;
      my $number_of_stack_items = 0;

      if ($frame_type >= 0 && $frame_type <= 63) {
        $frame_desc = 'SAME';
        $offset_delta = $frame_type;
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
      } elsif ($frame_type >= 64 && $frame_type <= 127) {
        $frame_desc = 'SAME_LOCALS_1_STACK_ITEM';
        $offset_delta = $frame_type - 64;
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
        &read_stack_map_entry('stack');
      } elsif ($frame_type >= 128 && $frame_type <= 246) {
        $frame_desc = 'RESERVED';
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
      } elsif ($frame_type == 247) {
        $frame_desc = 'SAME_LOCALS_1_STACK_ITEM_EXTENDED';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
        &read_stack_map_entry('stack');
      } elsif ($frame_type == 248) {
        $frame_desc = 'CHOP';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
      } elsif ($frame_type == 249) {
        $frame_desc = 'CHOP';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
      } elsif ($frame_type == 250) {
        $frame_desc = 'CHOP';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
      } elsif ($frame_type == 251) {
        $frame_desc = 'SAME_FRAME_EXTENDED';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
      } elsif ($frame_type == 252) {
        $frame_desc = 'APPEND';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
        &read_stack_map_entry('local');
      } elsif ($frame_type == 253) {
        $frame_desc = 'APPEND';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
        &read_stack_map_entry('local');
        &read_stack_map_entry('local');
      } elsif ($frame_type == 254) {
        $frame_desc = 'APPEND';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
        &read_stack_map_entry('local');
        &read_stack_map_entry('local');
        &read_stack_map_entry('local');
      } elsif ($frame_type == 255) {
        $frame_desc = 'FULL_FRAME';
        $offset_delta = &read_u2; 
        $offset_total += $offset_delta;
        $offset_total++;
        $vstr = sprintf('%3u', $frame_type) . ", $frame_desc, $offset_delta, " . ($offset_total - 1);
        printf(STDOUT "[%-16s]  %s  [%s]\n", 'stack map entry', &getHexStr(24), $vstr);
        $number_of_locals = &read_u2;
        printf(STDOUT "[%-16s]  %s  [%s]\n", '................', &getHexStr(24), ('full frame local items [' . $number_of_locals . ']'));
        for (1 .. $number_of_locals) {
          &read_stack_map_entry('local');
        }
        $number_of_stack_items = &read_u2;
        printf(STDOUT "[%-16s]  %s  [%s]\n", '................', &getHexStr(24), ('full frame stack items [' . $number_of_locals . ']'));
        for (1 .. $number_of_stack_items) {
          &read_stack_map_entry('stack');
        }
        printf(STDOUT "[%-16s]  %s  [%s]\n", '', &getHexStr(24), '');
      } else {
        $frame_desc = '!!! INVALID !!!';
      }
    }
  } else {
    foreach (1 .. $attribute_length) {
      my $byte = &read_u1();
    }
    my $r = $raw;
    $raw = 1;
    printf(STDOUT "[%-16s]  %s  [unknown]\n", 'raw bytes', &getHexStr());
    $raw = $r;
  }

  print(STDOUT "\n");

  if ($attribute_length != $bytecountattr[$attrdepth]) { die("bytecounts are off [attribute : $attribute_name] [attr, bytes: $attribute_length, " . $bytecountattr[$attrdepth] . "]"); }

  $attrdepth--;
  $bytecountattr[$attrdepth] += $bytecountattr[$attrdepth + 1];
}

sub read_code {
  my $code_length = $_[0];

  my $offset = 0;
  my $is_wide = 0;
  my $index = 0;

  my @instructions;
  my @fixups;
  my %offsets;
  my %offset;

  my $stackstr = '';

  while($offset < $code_length) {
    my $origoffset = $offset;

    my $u1 = &read_u1;
    $offset += 1;
    $hex .= ' ';

    my $op = $ops{$u1};
    my $opname = $op->{name};
    my $type = $op->{type};
    my $cpindex;
#   my @operands;
    my $opargs;

    my $pop = $op->{consumed};
    my $psh = $op->{produced};

    if ($type eq 'noargs') {
      # no operands
    } elsif ($type eq 'byte') {
      my $u1 = &read_u1;
      $offset += 1;
#     push @operands, $u1;
      $opargs = $u1;
    } elsif ($type eq 'bytevar') {
      my $u1 = &read_u1;
      $offset += 1;
#     push @operands, $u1;
      $opargs = $u1;
    } elsif ($type eq 'byteindex') {
      my $u1 = &read_u1;
      $offset += 1;
      $cpindex = $u1;
#     push @operands, &lookup_index($u1);
      $opargs = $u1 . '    [' . &lookup_index($u1) . ']';
    } elsif ($type eq 'twobytes') {
      my $u1 = &read_u1;
      $offset += 1;
#     push @operands, $u1;
      $opargs = $u1;
      $u1 = &read_u1;
      $offset += 1;
      $u1 = $u1 - 256 if $u1 > 128;
#     push @operands, $u1;
      $opargs .= ', ' . $u1;
    } elsif ($type eq 'int') {
      my $u2 = &read_u2;
      $offset += 2;
#     push @operands, $u2;
      $opargs = $u2;
    } elsif ($type eq 'intindex') {
      my $u2 = &read_u2;
      $offset += 2;
      $cpindex = $u2;
#     push @operands, &lookup_index($u2);
      $opargs = $u2 . '    [' . &lookup_index($u2) . ']';
    } elsif ($type eq 'intbranch') {
      my $u2 = &read_u2;
      $offset += 2;
      $u2 = $u2 - 65536 if $u2 > 31268;
#     push @operands, $u2;
      $opargs = $u2;
      push @fixups, $index;
    } elsif ($type eq 'longbranch') {
      my $u4 = &read_u4;
      $offset += 4;
    } else {
      die "uh-oh!  unknown type : [" . Dumper($op) . ", $opname, $type]";
    }

#   my $opers = join(' ', @operands);
    my $opers = $opargs;

if ($stk) {
    if (($type eq 'byteindex') || ($type eq 'intindex')) {
      if (${$constant_pool[$cpindex]}{'type'} eq 'float')    { $psh = 'F'; }
      if (${$constant_pool[$cpindex]}{'type'} eq 'double')   { $psh = 'D'; }
      if (${$constant_pool[$cpindex]}{'type'} eq 'string')   { $psh = 'o'; }
      if (${$constant_pool[$cpindex]}{'type'} eq 'fieldref')
        {
        $psh = $opers;
        $psh =~ s/\]$//;
        $psh =~ s/\[(.)$/$1/;
        $psh =~ s/^.* //;
        $psh =~ s/L.*;/o/g;
        }

      if ($opname eq 'putstatic') { $psh = ''; }
      if ($opname eq 'putfield')  { $psh = ''; }
    }
    if ($type eq 'byteindex') {
      if (${$constant_pool[$cpindex]}{'type'} eq 'class')    { $psh = 'o'; }
    }

    if (!defined($pop)) {
      $pop = $opers;
      $psh = $opers;

      $pop =~ s/\[././g;
      $pop =~ s/^.*\((.*)\).*$/$1/;
      $pop =~ s/L[^;]+;/o/g;
      $pop =~ s/Z/I/g;
      $pop =~ s/B/I/g;

      $psh =~ s/^.*\(.*\)\[*(.).*$/$1/;
      $psh =~ s/L/o/;
      $psh =~ s/Z/I/g;
      $psh =~ s/B/I/g;
    }
    if ($opname eq 'invokevirtual'  ) { $pop = 'o' . $pop; }
    if ($opname eq 'invokespecial'  ) { $pop = 'o' . $pop; }
    if ($opname eq 'invokeinterface') { $pop = 'o' . $pop; }

    if ($opname eq 'dup')       { $pop = substr($stackstr, -1); $psh = $pop x 2; }

    ## not sure if this is legit, but it seems to help
    if (($opname eq 'nop') && ($stackstr =~ /n$/)) { $pop = 'n'; }
    if (($opname ne 'nop') && ($stackstr =~ /n$/)) { $stackstr =~ s/n$/o/; }
    if (($opname eq 'nop') && ($stackstr =~ /-$/)) { $pop = '-'; }
    if (($opname ne 'nop') && ($stackstr =~ /-$/)) { $stackstr =~ s/-$/I/; }

    if ($pop eq 'Z') { $pop = 'I'; }
    if ($pop eq 'B') { $pop = 'I'; }
    if ($pop eq 'C') { $pop = 'I'; }
    if ($pop eq 'S') { $pop = 'I'; }

    if ($pop eq '0') { $pop = ''; }
    if ($psh eq '0') { $psh = ''; }

    if ($pop =~ /^(\d+)$/) { $pop = '.' x $1; }
    if ($psh =~ /^(\d+)$/) { $psh = '.' x $1; }

    if ($stackstr !~ /$pop$/) { $stackstr .= 'X'; }
    if ($pop ne '') { $stackstr =~ s/$pop$//; }
    $psh =~ s/V//g;
    $stackstr .= $psh;
    if ($stackstr =~ /R$/) { $stackstr = ''; }
}

#   my $i = {'hex' => &getHexStr(), 'op' => $opname, 'args' => \@operands, 'label' => 'L'.$origoffset, 'stack' => $stackstr};
    my $i = {'hex' => &getHexStr(), 'op' => $opname, 'args' => $opargs, 'label' => 'L'.$origoffset, 'stack' => $stackstr};
    push @instructions, $i;

    $offsets{$origoffset} = $index;
    $offset{$index} = $origoffset;
    $index++;
  }

  # Fix up pointers
  my %is_target;
  foreach my $fixup (@fixups) {
    my $i = $instructions[$fixup];
    my %hash = %$i;
#   my $offset = @{$hash{'args'}}[0] + $offset{$fixup};
    my $offset = $hash{'args'} + $offset{$fixup};
    my $target = $instructions[$offsets{$offset}];

    $instructions[$fixup] = {'hex' => $hash{'hex'}, 'op' => $hash{'op'}, 'args' => $hash{'args'}.'  >  L'.$offset, 'label' => $hash{'label'}, 'stack' => $hash{'stack'}};
    $i = $instructions[$fixup];
    $is_target{$target}++;
  }

  foreach my $i (@instructions) {
    my %hash = %$i;
    #$hash{'label'} = undef unless $is_target{$i};

#   my $opargs = '';
#   if (scalar(@{$hash{'args'}})) { $opargs = ' (' . join(', ', @{$hash{'args'}}) . ')'; }
    $vstr = $hash{'op'} . (($hash{'args'} eq '') ? '' : (' ' . $hash{'args'}));

    printf(STDOUT "[         %-5s  ]  %s  [%-16s]  [%s]\n", $hash{'label'}, $hash{'hex'}, $hash{'stack'}, $vstr) if ($stk);
    printf(STDOUT "[         %-5s  ]  %s "   .   " [%s]\n", $hash{'label'}, $hash{'hex'},                 $vstr) if (!$stk);
  }
}

sub lookup_index {
  my $index = $_[0];

  my $ref = $constant_pool[$index];
  my %hash = %$ref;
  my $vstr;

  if ($hash{'type'} eq 'integer') {
    $vstr  = ${$hash{'values'}}[0];
  } elsif ($hash{'type'} eq 'utf8') {
    $vstr  = ${$hash{'values'}}[1];
  } elsif ($hash{'type'} eq 'string') {
    $vstr  = &lookup_utf8(${$hash{'values'}}[0]);
  } elsif ($hash{'type'} eq 'float') {
    $vstr  = ${$hash{'values'}}[0];
  } elsif ($hash{'type'} eq 'double') {
    $vstr  = ${$hash{'values'}}[0];
  } elsif ($hash{'type'} eq 'long') {
    $vstr  = ${$hash{'values'}}[0];
  } elsif ($hash{'type'} eq 'class') {
    $vstr  = &lookup_class_name($index);
  } elsif ($hash{'type'} eq 'fieldref') {
    $vstr  = &lookup_class_name(${$hash{'values'}}[0]) . ' ';
    $vstr .= &lookup_nameandtype(${$hash{'values'}}[1]);
  } elsif ($hash{'type'} eq 'methodref') {
    $vstr  = &lookup_class_name(${$hash{'values'}}[0]) . ' ';
    $vstr .= &lookup_nameandtype(${$hash{'values'}}[1]);
  } elsif ($hash{'type'} eq 'interfacemethodref') {
    $vstr  = &lookup_class_name(${$hash{'values'}}[0]) . ' ';
    $vstr .= &lookup_nameandtype(${$hash{'values'}}[1]);
  } else {
    die "unknown index type $hash{'type'}!\n";
  }

  return $vstr;
}

sub read_stack_map_entry {
  my $kind = $_[0];
  my $type = '';
  my $extra = '';

  my $u1 = &read_u1;
  if ($u1 == 0) { $type = 'ITEM_Top'; }
  if ($u1 == 1) { $type = 'ITEM_Integer'; }
  if ($u1 == 2) { $type = 'ITEM_Float'; }
  if ($u1 == 3) { $type = 'ITEM_Double'; }
  if ($u1 == 4) { $type = 'ITEM_Long'; }
  if ($u1 == 5) { $type = 'ITEM_NULL'; }
  if ($u1 == 6) { $type = 'ITEM_UninitializedThis'; }
  if ($u1 == 7) { $type = 'ITEM_Object';
                  my $u2 = &read_u2;
                  $extra = &lookup_index($u2);
                }
  if ($u1 == 8) { $type = 'ITEM_Uninitialized';
                  my $u2 = &read_u2;
                  $extra = 'offset ' . $u2;
                }
  die "StackMapTable verification_type > 8\n" if ($u1 > 8);

  $vstr = "$type [$extra]";
  printf(STDOUT "[%-16s]  %s  [%s]\n", ('stack map ' . $kind), &getHexStr(32), $vstr);
}
