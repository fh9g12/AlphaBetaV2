function LoadEncoderDatum(obj,filename)
arguments
    obj
    filename (1,:) char = '__LCOencOffsets__.mat';
end
load(filename,'res');
obj.CalibMeta.EncAOffset = res.EncAOffset;
obj.CalibMeta.EncBOffset = res.EncBOffset;
fprintf('Loaded Encoder datums from file: %s\n',filename);
end

