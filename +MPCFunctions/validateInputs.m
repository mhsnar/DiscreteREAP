function validateInputs(A, B, C, D, Qx, Qu, Qv)
    % Validate the input matrices for consistency
    assert(size(A, 1) == size(A, 2), 'Matrix A must be square');
    assert(size(B, 1) == size(A, 1), 'Matrix B must have the same number of rows as A');
    assert(size(C, 2) == size(A, 2), 'Matrix C must have the same number of columns as A');
    assert(size(D, 1) == size(C, 1) && size(D, 2) == size(B, 2), 'Matrix D dimensions must match with B and C');
    assert(size(Qx, 1) == size(A, 1) && size(Qx, 2) == size(A, 1), 'Matrix Qx dimensions must match with A');
    assert(size(Qu, 1) == size(B, 2) && size(Qu, 2) == size(B, 2), 'Matrix Qu dimensions must match with B');
    assert(size(Qv, 1) == size(C, 1) && size(Qv, 2) == size(C, 1), 'Matrix Qv dimensions must match with C');
end
