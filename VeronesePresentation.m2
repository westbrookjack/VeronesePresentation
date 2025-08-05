-- -*- coding: utf-8 -*-
newPackage(
    "VeronesePresentation",
    Version => "0.1",
    Date => "August 3, 2025",
    Headline => "A package that computes the Veronese subring of a graded polynomial or quotient ring.",
    Authors => {{ Name => "Jack Westbrook", Email => "jackswestbrook@gmail.com", HomePage => "https://westbrookjack.github.io/"}},
    Keywords => {"Veronese", "presentation", "commutative algebra"},
    AuxiliaryFiles => false,
    DebuggingMode => false,
    PackageImports => {"Normaliz"},
)

export {"veronesePresentation", "VariableName"}

-- Helper functions



getMonomialList = (R, monoidBasis) -> (
    RGens := gens R;
    if numgens R != numcols monoidBasis then error "Number of generators of R does not match number of columns in the monoid basis.";
    r := numrows monoidBasis;
    monomialList := new List;
    for i to r-1 do (
        monomial := 1_R;
        for j to (#RGens)-1 do (
            monomial *= (RGens#j)^(monoidBasis_(i,j));
        );
        monomialList = append(monomialList, monomial);
    );

    monomialList

);

-- Main function to compute a presentation for the n-th Veronese subring of a graded ring R

veronesePresentation = method(Options => {VariableName => "p"});

veronesePresentation(Ring, ZZ):=o-> (R, veroneseDegree) -> (
    if not isHomogeneous R then error "R must be a graded ring.";
    if veroneseDegree < 1 then error "n must be a positive integer.";

    vPrefix := o#VariableName;
    degreeList := apply(gens R, g -> (degree g)#0);
    degreeList = append(degreeList, veroneseDegree);

    --This rCone represents the set of all nonnegative integer solutions (x_1, \dots, x_r) to the congruence x_1 d_1 + ... + x_r d_r equiv 0 (n)
    -- where d_i is the degree of the i-th generator of R.
    rCone := normaliz({(matrix{degreeList}, "congruences")});
    monoidBasis := rCone#"gen";
    monomialList := getMonomialList(R, monoidBasis);
    numMonomials := #monomialList;

    K := coefficientRing R;
    --I believe this is correct by test code with ZZ/2 vs GF(2,1), but I could not find documentation confirming this.
    if isQuotientRing K then error "kernel(RingMap) is not supported when class (coefficientRing R)==QuotientRing.";
    genPolyRing := (r) -> K[apply(1..r, i -> value(vPrefix | "_" | toString i))];
    --This ring has a generator for each monomial corresponding to an element of the monoid basis.
    polyRing := genPolyRing(numMonomials);
    presentationMap := map(R, polyRing, monomialList);

    myKernel := kernel presentationMap;
    --This ring is a presentation of the Veronese subring of R, just with poor variable indexing.
    prunedRing := prune (polyRing/myKernel);

    --This map takes each pruned generator to a lift in polyRing of the corresponding generator in polyRing/myKernel
    pruneMap := map(polyRing, prunedRing);

    outRing := genPolyRing(numgens prunedRing);

    reindexMap := map(prunedRing, outRing, gens prunedRing);

    compositeMap := presentationMap * pruneMap * reindexMap;

    

    (compositeMap, outRing/kernel compositeMap)
);

beginDocumentation()

doc ///
Key
  VeronesePresentation
Headline
  Computes presentations of Veronese subrings of weighted graded rings
Description
  Text
    This package computes a presentation of a Veronese subring of a graded ring.
///

doc ///
Key
  veronesePresentation
Headline
  Compute a presentation of the Veronese subring
Usage
  veronesePresentation(R, n)
Inputs
  R:Ring -- a graded ring
  n:ZZ  -- positive
Outputs
  l:List
    l#0:Map -- a ring homomorphism from a polynomial ring into {\t R}, such that its source modulo its kernel is a presentation of the Veronese subring
    l#1:QuotientRing -- a presentation of the {\t n}-th Veronese subring of {\t R}, given by the source of l#0 modulo its kernel
Description
  Text
    Returns a presentation of the n-th Veronese subring of R.
  Example
    R = QQ[x, y, z];
    (f, P) = veronesePresentation(R, 2);
    f -- the map
    P -- the quotient ring
Acknowledgement
  This code was partially created during the 2025 REU program in mathematics at the University of Michigan, Ann Arbor.
  In addition, this code relies on the Normaliz package. The original Normaliz library can be found at https://www.normaliz.uni-osnabrueck.de/.
Contributors
  Austyn Simpson
///

end