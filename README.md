[![Unmaintained as of 2017,](https://img.shields.io/maintenance/no/2016.svg)](https://github.com/jsmaniac/preexpanded/issues)

preexpanded
===========

This project was an attempt at making it possible to write efficient macros which produce code using other macros.
The goal was to statically pre-expand parts the generated code within the generator, so that the produced code consists mostly of primitives (`let-values`, `if`, …), but can still be specified in a concise way (`let`, `cond`, …).

To do this properly, one would need to consider the generated macros as source-to-source functions which can be partially applied.

This attempt however only consisted in hard-coding the expanded form of a few common macros, in a way which could easily and efficiently be injected in the generated code.
