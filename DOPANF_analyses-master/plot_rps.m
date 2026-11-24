%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------


% subject codes... (we need em!)
fid=fopen('../subcodes.txt','r');
subcodes={};
while ~feof(fid)
    subcodes{end+1} = fgetl(fid);
end
fclose(fid);

conds = {'Practice','Run1','Run2','Run3','Transfer'};

matlabbatch={};

for i_subcode=1:numel(subcodes)
    subcode=subcodes{i_subcode};
    
    for i_cond = 1:numel(conds)
        cond = conds{i_cond};
        
        
        
        niifile = sprintf('/data3/toshare/AMYNF_7T/%s/functional/%s/anomoco_%s_%s.nii',subcode,cond,subcode,cond);
        
        rpfile_nomoco = regexprep(regexprep(niifile,'anomoco','rp_anomoco'),'\.nii','\.txt');
        rpfile_moco = regexprep(regexprep(niifile,'anomoco_','rp_a'),'\.nii','\.txt');
        
        rp_nomoco = load(rpfile_nomoco,'-ascii');
        rp_moco = load(rpfile_moco,'-ascii');
        
        fh=figure;
        subplot(2,1,1);
        plot(rp_nomoco(:,1:3));
        ylim([-3.0 3.0]);
        title(sprintf('rp_figs_%s_%s.jpg',subcode,cond),'interpreter','none');
        subplot(2,1,2);
        plot(rp_moco(:,1:3));
        ylim([-3.0 3.0]);

        
        fh_save_name = sprintf('/data3/toshare/AMYNF_7T/%s/functional/%s/rp_figs_%s_%s.jpg',subcode,cond,subcode,cond);
        print('-djpeg','-r300',fh_save_name);
        
        close(fh);
        
        fprintf('%s\n',niifile);
    end
end

save matlabbatch_realign_nomoco.mat matlabbatch
