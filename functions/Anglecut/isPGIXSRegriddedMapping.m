function tf = isPGIXSRegriddedMapping(param)
% isPGIXSRegriddedMapping  True when param.Mapping selects a regridded image
% (Alpha, Qxy/Qz or Qy/Qz) rather than detector pixels.

    tf = isfield(param, 'Mapping') && any(strcmp(param.Mapping, {'Alpha', 'Qxy/Qz', 'Qy/Qz'}));
end
