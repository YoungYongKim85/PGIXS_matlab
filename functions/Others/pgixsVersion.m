function v = pgixsVersion()
%PGIXSVERSION  Release version of the PGIXS MATLAB suite.
%
%   v = pgixsVersion()   ->  '2.4.0'
%
%   Single source of truth for the version number. Every window in the
%   suite reads it -- the console, all eight Tab 1 tools, the three Tab 3
%   tools, the 1D plot viewers -- and so does the Software tag the H5-to-TIFF
%   converter writes into each output file. A running application therefore
%   always reports the same version as the git tag it was built from.
%
%   When releasing:
%     1. bump the string below,
%     2. add the section to CHANGELOG.md,
%     3. regenerate dist/build (run dist/build_dist_package.m),
%     4. tag: git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z
%
%   Bump the minor version when results change. Several fixes in 2.1.0 move
%   numbers that users have already published from, which is exactly what a
%   version number is for.
%
%   The only version strings left hard-coded are the "_v2.0"-style notes in
%   a few file header comments. Those are internal and not shown to anyone.

    v = '2.4.0';
end
