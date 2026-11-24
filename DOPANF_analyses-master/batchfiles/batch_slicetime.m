function matlabbatch = batch_slicetime(metainfo, matlabbatch) 

    % Select functional and structural scans
    %--------------------------------------------------------------------------
    % Realign
    %--------------------------------------------------------------------------

    num_slices = metainfo.MaxSlices;
    tr = metainfo.RepetitionTime;

    ind = length(matlabbatch)+1;
    disp("slicetime - matlabbatch index:");
    disp(ind);
    matlabbatch{ind}.spm.temporal.st.scans{1} = cellstr(fullfile(metainfo.funcDir,  metainfo.boldFile));
    matlabbatch{ind}.spm.temporal.st.nslices = num_slices;
    matlabbatch{ind}.spm.temporal.st.tr = tr;
    matlabbatch{ind}.spm.temporal.st.ta = tr-tr/num_slices;
    if strcmp(metainfo.AscDesc, 'desc')
        matlabbatch{ind}.spm.temporal.st.so = num_slices:-1:1;
    elseif strcmp(metainfo.AscDesc, 'asc')
        matlabbatch{ind}.spm.temporal.st.so = 1:1:num_slices;
    elseif strcmp(metainfo.AscDesc, 'mixed')
        [~,idx] = sort(metainfo.SliceTiming);
        disp("Slice order:");
        disp(idx);
        matlabbatch{ind}.spm.temporal.st.so = idx;
    end
    matlabbatch{ind}.spm.temporal.st.refslice = 2; % TODO WHICH ONE?
    

    matlabbatch{ind}.spm.temporal.st.refslice = 17;
    matlabbatch{ind}.spm.temporal.st.prefix = metainfo.slicetime_prefix;
    
end