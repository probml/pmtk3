function dirName = getDirNameData()
name = getUsername();
  switch name
    case 'emtiyaz'
      dirName = '/cs/SCRATCH/emtiyaz/datasets/';
    case 'kpmurphy'
      if isunix
        dirName = '/home/kpmurphy/Dropbox/Students/Emt/datasets/';
      end
      if ismac
        dirName = '/Users/kpmurphy/Dropbox/Students/Emt/datasets/';
      end
    otherwise
      error(['unrecognized user ' name])
  end
end
