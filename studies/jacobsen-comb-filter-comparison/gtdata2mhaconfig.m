function out = gtdata2mhaconfig(gtdata)
  % This function writes the gain table data into the correct layout to be fed
  % to the mhaconfig file.
  %
  % Variables:
  % - gtdata
  %
  % Returns:
  % - out
  
  out = '[';
  for i=1:size(gtdata, 1)
    out = [out '[' sprintf('%.1f ',gtdata(i,:)) '];'];
  end
  out = [out ']'];
end
