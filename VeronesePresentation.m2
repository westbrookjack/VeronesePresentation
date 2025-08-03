-- -*- coding: utf-8 -*-
newPackage(
    "VeronesePresentation",
    Version => "0.1",
    Date => "August 1, 2025",
    Headline => "A package that computes the Veronese subring of a graded polynomial or quotient ring.",
    Authors => {{ Name => "Jack Westbrook", Email => "jackswestbrook@gmail.com", HomePage => "https://westbrookjack.github.io/"}},
    Keywords => {"Veronese", "presentation", "commutative algebra"},
    AuxiliaryFiles => false,
    DebuggingMode => false
)

export {"veronesePresentation"}

-- Helper functions

writeInputFile = (degreeList, veroneseDegree) -> (
    file = openOut "input.txt";
    file << "{" << toString degreeList << ", " << toString veroneseDegree << "}" << endl;
    close file;
)

readPipelineOutput = () -> (
    filename = "output.m2";
    if not fileExists filename then error "Output file not found";
    parsedOutput = value get filename;
    removeFile filename;
    parsedOutput
)

runPipeline = () -> (
    run "./bin/full_pipeline"
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

    -- Create coordinate vector
    toCoordVector = (monomial, basisMonomials) -> (
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

    -- Reduce each degree group to K-linearly independent monomials
    for deg in keys degreeGroups do (
        monomialsOfDeg := degreeGroups#deg;
        basisMonomials := flatten entries basis(deg, R);
        coordVectors := apply(monomialsOfDeg, monomial -> toCoordVector(monomial, basisMonomials));

        linearlyIndependentVecs := {};
        for vec in coordVectors do (
            M := transpose matrix(linearlyIndependentVecs | {vec});
            if rank M == #linearlyIndependentVecs + 1 then (
                linearlyIndependentVecs = linearlyIndependentVecs | {vec};
            );
        );

        keptMonomials := apply(linearlyIndependentVecs,
            vec -> sum(0 .. #basisMonomials - 1, i -> vec#i * basisMonomials#i)
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

veronesePresentation = (R, veroneseDegree) -> (
    if not isRing R then error "R must be a ring.";
    if not isHomogeneous R then error "R must be a graded ring (i.e., its variables must have degrees).";
    if not (class veroneseDegree === ZZ and veroneseDegree > 0) then error "n must be a positive integer.";

    degreeList := apply(gens R, g -> (degree g)#0);
    monoidBasis := getConeBasis(degreeList, veroneseDegree);
    monomialList := getMonomialList(R, monoidBasis);
    veroneseGenerators := minimalizeMonomialList(R, monomialList);
    numGenerators := #veroneseGenerators;

    S := coefficientRing R;
    veroneseRing := S[v_1 .. v_numGenerators];
    presentationMap := map(R, veroneseRing, veroneseGenerators);

    (presentationMap, veroneseRing / kernel presentationMap)
)
