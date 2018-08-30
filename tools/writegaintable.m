% Copyright 2018 Marc René Schädler
%
% This file is part of the mobile hearing aid prototype project
% The the mobile hearing aid prototype project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% The mobile hearing aid prototype project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with the mobile hearing aid prototype project. If not, see http://www.gnu.org/licenses/.

function writegaintable(filename, gt_data)
  fid = fopen(filename,'w');
  gt_min = -10;
  gt_step = 1;
  if fid > 0
    fprintf(fid,'gtdata = [');
    [num_rows, num_cols] = size(gt_data);
    for i=1:num_rows
      fprintf(fid,'[');
      for j=1:num_cols
        fprintf(fid,'%.2f',gt_data(i,j));
        if j < num_cols
          fprintf(fid,' ');
        else
          fprintf(fid,']');
        end
      end
      if i < num_rows
        fprintf(fid,';');
      else
        fprintf(fid,']');
      end
    end
    fprintf(fid,'\n');
    fprintf(fid,'gtmin = [');
    for i=1:num_rows
      fprintf(fid,'%.2f',gt_min);
      if i < num_rows
        fprintf(fid,' ');
      else
        fprintf(fid,']');
      end
    end
    fprintf(fid,'\n');
    fprintf(fid,'gtstep = [');
    for i=1:num_rows
      fprintf(fid,'%.2f',gt_step);
      if i < num_rows
        fprintf(fid,' ');
      else
        fprintf(fid,']');
      end
    end
    fprintf(fid,'\n');
    fclose(fid);
  end
end
