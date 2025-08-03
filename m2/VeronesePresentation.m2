-- -*- coding: utf-8 -*-
newPackage(
    "VeronesePresentation",
    Version => "0.1",
    Date => "August 3, 2025",
    Headline => "A package that computes the Veronese subring of a graded polynomial or quotient ring.",
    Authors => {{ Name => "Jack Westbrook", Email => "jackswestbrook@gmail.com", HomePage => "https://westbrookjack.github.io/"}},
    Keywords => {"Veronese", "presentation", "commutative algebra"},
    AuxiliaryFiles => false,
    DebuggingMode => false
)

export {"veronesePresentation", "VariableName"}

-- Helper functions

writeInputFile = (degreeList, veroneseDegree) -> (
    (
        file := openOut "input.txt";
        file << "{" << toString degreeList << ", " << toString veroneseDegree << "}" << endl;
        close file;
    );
);

readPipelineOutput = () -> (
    (
        filename := "output.m2";
        if not fileExists filename then error "Output file not found";
        parsedOutput := value get filename;
        removeFile filename;
        parsedOutput
    )
);


FullPipelineBinaryPath = "bin/full_pipeline";

setPipelinePath = (s) -> (
    if not fileExists s then error("Binary not found at path: " | s);
    FullPipelineBinaryPath = s;
);

runPipeline = () -> (
    if not fileExists FullPipelineBinaryPath then error "Missing binary: " | FullPipelineBinaryPath;
    run FullPipelineBinaryPath;
)

getConeBasis = (degreeList, veroneseDegree) -> (
    writeInputFile(degreeList, veroneseDegree);
    runPipeline();
    readPipelineOutput()
);

minimalizeMonomialList = (R, candidateMonomials) -> (
    K := coefficientRing R;
    selectedMonomials := {};

    -- Group monomials by degree
    degreeGroups := new MutableHashTable;
    for monomial in candidateMonomials do (
        deg := degree monomial;
        if not isMember(deg, keys degreeGroups) then degreeGroups#deg = {};
        degreeGroups#deg = append(degreeGroups#deg, monomial);
    );

    -- Helper to convert monomial to coordinate vector in a given basis
    toCoordVector := (monomial, basisMonomials) -> (
        (monomialBasis, coeffs) := coefficients monomial;
        coordVec := {};
        j := 0;
        for i from 0 to #basisMonomials - 1 do (
            if j < numColumns monomialBasis and basisMonomials#i == monomialBasis_(0,j) then (
                coordVec = coordVec | {coeffs_(0,j)};
                j = j + 1;
            ) else (
                coordVec = coordVec | {0};
            );
        );
        coordVec
    );

    -- Loop over degree groups and prune linearly dependent elements
    for deg in keys degreeGroups do (
        monomialsOfDeg := degreeGroups#deg;
        basisMonomials := flatten entries basis(deg, R);
        coordVectors := apply(monomialsOfDeg, f -> toCoordVector(f, basisMonomials));

        linIndVectors := {};
        for v in coordVectors do (
            M := transpose matrix(linIndVectors | {v});
            if rank M == #linIndVectors + 1 then (
                linIndVectors = linIndVectors | {v};
            );
        );

        keptMonomials := apply(linIndVectors,
            v -> sum(0 .. #basisMonomials - 1, i -> v#i * basisMonomials#i)
        );
        selectedMonomials = selectedMonomials | keptMonomials;
    );

    selectedMonomials
);



getMonomialList = (R, monoidBasis) -> (
    apply(monoidBasis, exponentVector -> (
        monomial := 1_R;
        scan(#exponentVector, i -> monomial = monomial * ((gens R)#i)^(exponentVector#i));
        monomial
    ))
);

-- Main function to compute a presentation for the n-th Veronese subring of a graded ring R

veronesePresentation = method(Options => {VariableName => "p"});

veronesePresentation(Ring, ZZ):=o-> (R, veroneseDegree) -> (
    if not isHomogeneous R then error "R must be a graded ring.";
    if veroneseDegree < 1 then error "n must be a positive integer.";

    vPrefix := o#VariableName;
    degreeList := apply(gens R, g -> (degree g)#0);
    monoidBasis := getConeBasis(degreeList, veroneseDegree);
    monomialList := getMonomialList(R, monoidBasis);
    veroneseGenerators := minimalizeMonomialList(R, monomialList);
    numGenerators := #veroneseGenerators;

    K := coefficientRing R;
    genPolyRing := (r) -> K[apply(1..r, i -> value(vPrefix | "_" | toString i))];
    veroneseRing := genPolyRing(numGenerators);
    presentationMap := map(R, veroneseRing, veroneseGenerators);

    (presentationMap, veroneseRing / kernel presentationMap)
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
    l#0:Map -- a surjective ring homomorphism into {\t R}, such that its source modulo its kernel is a presentation of the Veronese subring
    l#1:Ring -- a presentation of the {\t n}-th Veronese subring of {\t R}
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
  In addition, this code uses a cloned version of the Normaliz C++ library, which is licensed under the GNU General Public License (GPL) version 2 or later. The original Normaliz library can be found at https://www.normaliz.uni-osnabrueck.de/.
Contributors
  Austyn Simpson
///

end