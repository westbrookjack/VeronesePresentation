VeronesePresentation
====================

**VeronesePresentation** is a Macaulay2 package that computes minimal presentations of Veronese subrings
of graded polynomial or quotient rings.


Getting Started
---------------

1. Clone the repository:

    ```bash
    git clone https://github.com/westbrookjack/VeronesePresentation.git
    cd VeronesePresentation
    ```

2. Load the package in Macaulay2:

    ```macaulay2
    needsPackage("VeronesePresentation", FileName => "VeronesePresentation.m2")
    ```

3. Run a simple example:

    ```macaulay2
    R = GF(3,1)[x, y, z, Degrees => {{2}, {3}, {5}}];
    phi = veronesePresentation(R, 6, VariableName => "v");
    phi -- the presentation map from a polynomial ring onto the 6-th Veronese subring of R
    ```

Why Use This?
-------------

- Pure Macaulay2 implementation
- Computes minimal generating sets for Veronese subrings
- Compatible with weighted graded rings and quotient rings
- Modular, extensible design for algebraic geometry and commutative algebra
- Optional `VariableName` input allows customizable generators

License
-------

This project currently has no license.

Acknowledgements
----------------

This project was developed by **Jack Westbrook** as part of the 2025 REU program in mathematics at the
University of Michigan, Ann Arbor. It was supervised by **Austyn Simpson**, who proposed the core idea
of computing minimal presentations of Veronese subrings.

Links
-----

Jack Westbrook's website: https://westbrookjack.github.io
