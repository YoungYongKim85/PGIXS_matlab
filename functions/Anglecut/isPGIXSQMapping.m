function tf = isPGIXSQMapping(param)
% isPGIXSQMapping  True when param.Mapping selects a Q-remapped image.

    tf = isfield(param, 'Mapping') && any(strcmp(param.Mapping, {'Qxy/Qz', 'Qy/Qz'}));
end
