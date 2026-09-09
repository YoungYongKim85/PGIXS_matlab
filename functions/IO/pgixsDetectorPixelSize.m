function pixel = pgixsDetectorPixelSize(detectorType)
%PGIXSDETECTORPIXELSIZE  Pixel pitch in mm for a detector type.
%
%   pixel = pgixsDetectorPixelSize('Eiger4M')  ->  0.075
%
%   Split out of loadPGIXSDetectorMask so the pixel size can be looked up
%   without loading a mask file. The incidence-angle pixel<->degree
%   conversion in GIXS_gui/GIXS2_gui needs the pitch before any image has
%   been loaded, and reading a multi-megabyte mask just to get one number
%   would be wasteful.
%
%   Unknown detectors fall back to 0.075 mm, matching loadPGIXSDetectorMask.
%   Keep the two in step -- loadPGIXSDetectorMask calls this function, so
%   the table lives here only.

    switch char(detectorType)
        case 'Eiger4M'
            pixel = 0.075;
        case {'MarCCD', 'SX165'}
            pixel = 0.079;
        case 'MX170HS'
            pixel = 0.0886;
        case {'PI-CCD', 'PI_CCD'}
            pixel = 0.1152;
        case 'MAR345'
            pixel = 0.1;
        otherwise
            pixel = 0.075;
    end
end
