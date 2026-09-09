function v = pgixsVersion()
%PGIXSVERSION  Release version of the PGIXS MATLAB suite.
%
%   v = pgixsVersion()   ->  '2.1.0'
%
%   Single source of truth for the version number. The console window
%   (PGIXS.m and dist/PGIXS.m) reads it, so the running application always
%   reports the same version as the git tag it was built from.
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
%   The individual tool windows still carry their own hard-coded "v2.0"/
%   "v2.1" strings in their titles; those are per-tool and predate this
%   function. Only the console reports the suite version.

    v = '2.1.0';
end
