function dirName = getDirName()
name = getUsername();
  switch name
    case 'emtiyaz'
      dirName = '/cs/SCRATCH/emtiyaz/categoricalLGMOut/';
    case 'kpmurphy'
      if isunix
        dirName = '/home/kpmurphy/scratch/categoricalLGMOut/';
      end
      if ismac
        dirName = '/Users/kpmurphy/scratch/categoricalLGMOut/';
      end
    otherwise
      error(['unrecognized user ' name])
  end
end
