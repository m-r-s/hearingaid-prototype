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
