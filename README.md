LudumScribe
===========

LudumScribe is a language designed specifically for games, namely it gives users the performance of native code while being easily portable to any platform.

LudumScribe takes the form of a transcompiler, a compiler that rather than compiling to native assembly, instead compiles to an established language, such as C++/C#/JavaScript/etc. This allows the user to have the benefit of using mature compilers on each platform, optimized to get the best performance, whilst still allowing easy cross-platform support. This also resolves some issues that are common for indie game developers, and take up great time, having to target multiple languages if you want to run on multiple platforms, C# for XNA, ObjC for iOS, JS for HTML5, etc.

The standard library of LudumScribe is targeted specifically at games, with support for commonly used code: graphics, audio, math, physics, etc.

LudumScribe is designed to be self-hosting (though its not quite there yet!), meaning the compiler can compile the compiler.

The language takes great inspiration from the Monkey language (http://www.monkeycoder.co.nz/), a language with similar goals but with a BASIC syntax and commericial orientation.

Platforms
=========

Targets aimed for our 1.0 release are; XBox360, Playstation Mobile, HTML5, Win32, Metro, MacOS and Linux. 

Compiling
=========

The compiler currently takes the form of a bootstrapper compiler which is available as a visual studio solution and is compiled on windows. As the language becomes self-hosting it will be possible to compile it on any platform it supports.
